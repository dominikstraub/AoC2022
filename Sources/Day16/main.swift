import Foundation
import OrderedCollections
import Utils

// let input = try Utils.getInput(bundle: Bundle.module, file: "test")
let input = try Utils.getInput(bundle: Bundle.module)

func prepare() -> [Valve] {
    return input
        .components(separatedBy: "\n")
        .compactMap { line -> Valve? in
            if line == "" {
                return nil
            }
            let pattern = "Valve ([A-Z]{2}) has flow rate=([0-9]{1,2}); tunnels? leads? to valves? ((([A-Z]{2}),? ?)*)"

            var label: String?
            var flowRate: Int?
            var connections: [String]?

            let regex = try? NSRegularExpression(pattern: pattern)
            guard let match = regex?.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.utf8.count)) else { return nil }

            if let range = Range(match.range(at: 1), in: line) {
                label = String(line[range])
            }
            if let range = Range(match.range(at: 2), in: line) {
                flowRate = Int(line[range])
            }
            if let range = Range(match.range(at: 3), in: line) {
                connections = String(line[range]).components(separatedBy: ", ")
            }

            return Valve(label: label!, flowRate: flowRate!, connections: connections!)
        }
}

struct Valve {
    let label: String
    let flowRate: Int
    let connections: [String]

    func getValves() -> [Valve] {
        connections.map { valvesMap[$0]! }
    }
}

extension Valve: CustomStringConvertible {
    public var description: String {
        return "\(label) (\(flowRate), \(connections)))"
    }
}

extension Valve: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(label)
    }
}

struct MinutesLeftOpenValves {
    let minutesLeft: Int
    let openedValves: Set<String>
}

extension MinutesLeftOpenValves: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(minutesLeft)
        hasher.combine(openedValves)
    }
}

class Node<T> where T: Hashable {
    let start = false
    var pressure = [MinutesLeftOpenValves: Int]()
    var pressureNode = [MinutesLeftOpenValves: Node]()

    let value: T

    init(_ value: T) {
        self.value = value
    }
}

func findMaxPath(inGraph graph: inout [String: Node<Valve>], withNodesToCheck nodesToCheck: inout OrderedSet<String>) -> Int {
    while !nodesToCheck.isEmpty {
        let node = graph[nodesToCheck.first!]!
        nodesToCheck.removeFirst()
        checkNode(node, inGraph: &graph, withNodesToCheck: &nodesToCheck)
    }

    var maxPressure = Int.min
    for node in graph.values {
        for (minutesLeftOpenedValves, pressure) in node.pressure {
            let minutesLeft = minutesLeftOpenedValves.minutesLeft
            let openedValves = minutesLeftOpenedValves.openedValves
            let addedPressure = (minutesLeft > 0 && !openedValves.contains(node.value.label)) ? node.value.flowRate * (minutesLeft - 1) : 0
            if pressure + addedPressure > maxPressure {
                maxPressure = pressure + addedPressure
            }
        }
    }

    return maxPressure
}

func checkNode(_ node: Node<Valve>, inGraph graph: inout [String: Node<Valve>], withNodesToCheck nodesToCheck: inout OrderedSet<String>) {
    for neighbourNode in getNeighboursOfNode(node, inGraph: &graph) {
        for (minutesLeftOpenedValves, pressure) in node.pressure {
            let minutesLeft = minutesLeftOpenedValves.minutesLeft
            let openedValves = minutesLeftOpenedValves.openedValves
            let notOpenMinutesValves = MinutesLeftOpenValves(minutesLeft: minutesLeft - 1, openedValves: openedValves)
            var openOpenedValves = openedValves
            openOpenedValves.insert(node.value.label)
            let openMinutesValves = MinutesLeftOpenValves(minutesLeft: minutesLeft - 2, openedValves: openOpenedValves)
            if minutesLeft > 0, neighbourNode.pressure[notOpenMinutesValves] ?? Int.min < pressure {
                neighbourNode.pressure[notOpenMinutesValves] = pressure
                neighbourNode.pressureNode[notOpenMinutesValves] = node
                nodesToCheck.insert(neighbourNode.value.label, at: nodesToCheck.count)
            }
            if minutesLeft > 1, node.value.flowRate > 0, !openedValves.contains(node.value.label), neighbourNode.pressure[openMinutesValves] ?? Int.min < pressure + node.value.flowRate * (minutesLeft - 1) {
                neighbourNode.pressure[openMinutesValves] = pressure + node.value.flowRate * (minutesLeft - 1)
                neighbourNode.pressureNode[openMinutesValves] = node
                nodesToCheck.insert(neighbourNode.value.label, at: nodesToCheck.count)
            }
        }
    }
}

func getNeighboursOfNode(_ node: Node<Valve>, inGraph graph: inout [String: Node<Valve>]) -> [Node<Valve>] {
    return node.value.connections.map { graph[$0]! }
}

let valves = run(part: "Input parsing", closure: prepare)

var valvesMap = [String: Valve]()
for valve in valves {
    valvesMap[valve.label] = valve
}

func part1() -> Int {
    var graph = [String: Node<Valve>]()
    var nodesToCheck = OrderedSet<String>()
    for valve in valves {
        let node = Node(valve)
        graph[valve.label] = node
    }
    let startNode = graph["AA"]!
    startNode.pressure[MinutesLeftOpenValves(minutesLeft: 30, openedValves: [])] = 0
    nodesToCheck.insert(startNode.value.label, at: 0)

    let result = findMaxPath(inGraph: &graph, withNodesToCheck: &nodesToCheck)

    return result
}

_ = run(part: 1, closure: part1)

// func part2() -> Int {
//     return -1
// }

// _ = run(part: 2, closure: part2)
