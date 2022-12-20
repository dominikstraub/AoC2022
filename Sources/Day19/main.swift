import Foundation
import OrderedCollections
import Utils

let input = try Utils.getInput(bundle: Bundle.module, file: "test")
// let input = try Utils.getInput(bundle: Bundle.module)

func prepare() -> [Blueprint] {
    return input
        .components(separatedBy: "\n")
        .compactMap { line -> Blueprint? in
            if line == "" {
                return nil
            }

            let pattern = "Blueprint ([0-9]+): Each ore robot costs ([0-9]+) ore. Each clay robot costs ([0-9]+) ore. Each obsidian robot costs ([0-9]+) ore and ([0-9]+) clay. Each geode robot costs ([0-9]+) ore and ([0-9]+) obsidian."

            var id: Int?
            var oreRobotOreCost: Int?
            var clayRobotOreCost: Int?
            var obsidianRobotOreCost: Int?
            var obsidianRobotClayCost: Int?
            var geodeRobotOreCost: Int?
            var geodeRobotobsidianCost: Int?

            let regex = try? NSRegularExpression(pattern: pattern)
            guard let match = regex?.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.utf8.count)) else { return nil }

            if let range = Range(match.range(at: 1), in: line) {
                id = Int(line[range])
            }
            if let range = Range(match.range(at: 2), in: line) {
                oreRobotOreCost = Int(line[range])
            }
            if let range = Range(match.range(at: 3), in: line) {
                clayRobotOreCost = Int(line[range])
            }
            if let range = Range(match.range(at: 4), in: line) {
                obsidianRobotOreCost = Int(line[range])
            }
            if let range = Range(match.range(at: 5), in: line) {
                obsidianRobotClayCost = Int(line[range])
            }
            if let range = Range(match.range(at: 6), in: line) {
                geodeRobotOreCost = Int(line[range])
            }
            if let range = Range(match.range(at: 7), in: line) {
                geodeRobotobsidianCost = Int(line[range])
            }

            return Blueprint(id: id!, recipes: [
                .ore: [(material: .ore, amount: oreRobotOreCost!)],
                .clay: [(material: .ore, amount: clayRobotOreCost!)],
                .obsidian: [
                    (material: .ore, amount: obsidianRobotOreCost!),
                    (material: .clay, amount: obsidianRobotClayCost!),
                ],
                .geode: [
                    (material: .ore, amount: geodeRobotOreCost!),
                    (material: .obsidian, amount: geodeRobotobsidianCost!),
                ],
            ])
        }
}

let blueprints = run(part: "Input parsing", closure: prepare)

enum Material {
    case ore
    case clay
    case obsidian
    case geode
}

extension Material: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ore:
            return "ore"
        case .clay:
            return "clay"
        case .obsidian:
            return "obsidian"
        case .geode:
            return "geode"
        }
    }
}

typealias Recipe = [Ingredient]
typealias Ingredient = (material: Material, amount: Int)
let mats: [Material] = [.ore, .clay, .obsidian, .geode]

struct Blueprint {
    let id: Int
    let recipes: [Material: Recipe]
}

extension Blueprint: CustomStringConvertible {
    public var description: String {
        return "Blueprint \(id): \(recipes)"
    }
}

// #########################

struct State {
    let minutesLeft: Int
    let materials: [Material: Int]
    let robots: [Material: Int]
}

extension State: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(minutesLeft)
        hasher.combine(materials)
        hasher.combine(robots)
    }
}

class Node {
    var value = Set<State>()
}

func findMaxPath(inGraph graph: [Material?: Node], blueprint: Blueprint) -> Int {
    var nodesToCheck = OrderedSet<Material?>()
    nodesToCheck.insert(nil, at: 0)
    while !nodesToCheck.isEmpty {
        let node = graph[nodesToCheck.first!]!
        nodesToCheck.removeFirst()
        checkNode(node, inGraph: graph, withNodesToCheck: &nodesToCheck, blueprint: blueprint)
    }

    var maxGeodes = Int.min
    for node in graph.values {
        for state in node.value where state.materials[.geode]! > maxGeodes {
            maxGeodes = state.materials[.geode]!
        }
    }

    return maxGeodes
}

func checkNode(_ node: Node, inGraph graph: [Material?: Node], withNodesToCheck nodesToCheck: inout OrderedSet<Material?>, blueprint: Blueprint) {
    for state in node.value {
        let minutesLeft = state.minutesLeft
        if minutesLeft >= 0 {
            let materials = state.materials
            for buildableRobot in getNeighboursOfNode(materials: materials, blueprint: blueprint) {
                var materials = state.materials
                var robots = state.robots

                for (material, ammount) in robots {
                    materials[material]! += ammount
                }

                buildRobot(buildableRobot, &materials, &robots, blueprint)

                let key = State(minutesLeft: minutesLeft - 1, materials: materials, robots: robots)
                let neighbourNode = graph[buildableRobot]!
                if !neighbourNode.value.contains(key) {
                    neighbourNode.value.insert(key)
                    nodesToCheck.insert(buildableRobot, at: nodesToCheck.count)
                }
            }
        }
    }
}

func getNeighboursOfNode(materials: [Material: Int], blueprint: Blueprint) -> [Material?] {
    var neighbours = [Material?]()
    neighbours.append(nil)
    if canBuildRobot(.ore, materials, blueprint) {
        neighbours.append(.ore)
    }
    if canBuildRobot(.clay, materials, blueprint) {
        neighbours.append(.clay)
    }
    if canBuildRobot(.obsidian, materials, blueprint) {
        neighbours.append(.obsidian)
    }
    if canBuildRobot(.geode, materials, blueprint) {
        neighbours.append(.geode)
    }
    return neighbours
}

func canBuildRobot(_ robot: Material, _ materials: [Material: Int], _ blueprint: Blueprint) -> Bool {
    for ingedient in blueprint.recipes[robot]! {
        if materials[ingedient.material]! < ingedient.amount {
            return false
        }
    }
    return true
}

func buildRobot(_ robot: Material?, _ materials: inout [Material: Int], _ robots: inout [Material: Int], _ blueprint: Blueprint) {
    guard let robot else { return }
    // print("Spend ", terminator: "")
    for ingedient in blueprint.recipes[robot]! {
        materials[ingedient.material]! -= ingedient.amount
        // print("\(ingedient.amount) \(ingedient.material)", terminator: "")
    }
    robots[robot]! += 1

    // print(" to start building a \(robot)-cracking robot.")
}

func part1() -> Int {
    var quality = 0
    for blueprint in blueprints {
        let materials: [Material: Int] = [
            .ore: 0,
            .clay: 0,
            .obsidian: 0,
            .geode: 0,
            // TODO: remove geode from materials and move to possible max value
        ]
        let robots: [Material: Int] = [
            .ore: 1,
            .clay: 0,
            .obsidian: 0,
            .geode: 0,
        ]
        var graph = [Material?: Node]()
        graph[.ore] = Node()
        graph[.clay] = Node()
        graph[.obsidian] = Node()
        graph[.geode] = Node()
        graph[nil] = Node()
        let startNode = graph[nil]!
        startNode.value.insert(State(minutesLeft: 24, materials: materials, robots: robots))

        let geodes = findMaxPath(inGraph: graph, blueprint: blueprint)

        quality += blueprint.id * geodes
        break
    }
    return quality
}

_ = run(part: 1, closure: part1)
