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
                .ore: [.ore: oreRobotOreCost!],
                .clay: [.ore: clayRobotOreCost!],
                .obsidian: [
                    .ore: obsidianRobotOreCost!,
                    .clay: obsidianRobotClayCost!,
                ],
                .geode: [
                    .ore: geodeRobotOreCost!,
                    .obsidian: geodeRobotobsidianCost!,
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

typealias Recipe = [Material: Int]
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

extension State: CustomStringConvertible {
    public var description: String {
        return "minutesLeft: \(minutesLeft), materials: \(materials), robots: \(robots)"
    }
}

typealias States = Set<State>

func findMaxPath(withStatesToCheck statesToCheck: inout States, blueprint: Blueprint) -> Int {
    var states = States()
    states.insert(statesToCheck.first!)

    while !statesToCheck.isEmpty {
        let state = statesToCheck.first!
        statesToCheck.remove(state)
        checkState(state, withStates: &states, andStatesToCheck: &statesToCheck, blueprint: blueprint)
    }

    var maxGeodes = Int.min
    for state in states where state.materials[.geode]! > maxGeodes {
        print("minutesLeft \(state.minutesLeft)")
        print("materials[.geode] \(state.materials[.geode]!)")
        print("blueprint.id \(blueprint.id)")
        print("quality \(blueprint.id * state.materials[.geode]!)")
        print("materials \(state.materials)")
        print("robots \(state.robots)")
        print()

        maxGeodes = state.materials[.geode]!
    }

    return maxGeodes
}

func checkState(_ state: State, withStates states: inout States, andStatesToCheck statesToCheck: inout States, blueprint: Blueprint) {
    let minutesLeft = state.minutesLeft
    guard minutesLeft > 0 else { return }
    let materials = state.materials
    let robots = state.robots
    let latestToBuildGeode = 5
    guard
        minutesLeft - latestToBuildGeode >= 0 || canHaveAtLeastOneRobotInMinutes(robot: .geode, materials: materials, robots: robots, blueprint: blueprint, minutes: minutesLeft - latestToBuildGeode),
        minutesLeft - latestToBuildGeode - 1 >= 0 || canHaveAtLeastOneRobotInMinutes(robot: .obsidian, materials: materials, robots: robots, blueprint: blueprint, minutes: minutesLeft - latestToBuildGeode - 1),
        minutesLeft - latestToBuildGeode - 2 >= 0 || canHaveAtLeastOneRobotInMinutes(robot: .clay, materials: materials, robots: robots, blueprint: blueprint, minutes: minutesLeft - latestToBuildGeode - 2)
    else { return }
    let buildableRobots = getBuildableRobots(materials: materials, blueprint: blueprint)
    for buildableRobot in buildableRobots {
        var materials = materials
        var robots = robots

        for (material, amount) in robots {
            materials[material]! += amount
        }

        buildRobot(robot: buildableRobot, materials: &materials, robots: &robots, blueprint: blueprint)

        let key = State(minutesLeft: minutesLeft - 1, materials: materials, robots: robots)
        if !states.contains(key) {
            states.insert(key)
            if key.minutesLeft > 0 {
                statesToCheck.insert(key)
            }
        }
    }
}

func getBuildableRobots(materials: [Material: Int], blueprint: Blueprint) -> [Material?] {
    var neighbours = [Material?]()
    if canBuildRobot(.ore, withMaterials: materials, blueprint: blueprint) {
        neighbours.append(.ore)
    }
    if canBuildRobot(.clay, withMaterials: materials, blueprint: blueprint) {
        neighbours.append(.clay)
    }
    if canBuildRobot(.obsidian, withMaterials: materials, blueprint: blueprint) {
        neighbours.append(.obsidian)
    }
    if canBuildRobot(.geode, withMaterials: materials, blueprint: blueprint) {
        neighbours.append(.geode)
    }
    if neighbours.count < 4 {
        neighbours.append(nil)
    }
    return neighbours
}

func canHaveAtLeastOneRobotInMinutes(robot: Material, materials: [Material: Int], robots: [Material: Int], blueprint: Blueprint, minutes: Int) -> Bool {
    return robots[robot]! > 0 || canBuildRobotInMinutes(robot: robot, materials: materials, robots: robots, blueprint: blueprint, minutes: minutes)
}

func canBuildRobotInMinutes(robot: Material, materials: [Material: Int], robots: [Material: Int], blueprint: Blueprint, minutes: Int) -> Bool {
    var materials = materials
    guard minutes >= 0 else { return false }
    for _ in 0 ..< minutes {
        for (material, amount) in robots {
            materials[material]! += amount
        }
    }
    return canBuildRobot(robot, withMaterials: materials, blueprint: blueprint)
}

func canBuildRobot(_ robot: Material, withMaterials materials: [Material: Int], blueprint: Blueprint) -> Bool {
    for (material, amount) in blueprint.recipes[robot]! where materials[material]! < amount {
        return false
    }
    return true
}

func buildRobot(robot: Material?, materials: inout [Material: Int], robots: inout [Material: Int], blueprint: Blueprint) {
    guard let robot else { return }
    // print("Spend ", terminator: "")
    for (material, amount) in blueprint.recipes[robot]! {
        materials[material]! -= amount
        // print("\(amount) \(material)", terminator: "")
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
        ]
        let robots: [Material: Int] = [
            .ore: 1,
            .clay: 0,
            .obsidian: 0,
            .geode: 0,
        ]

        var statesToCheck = States()
        statesToCheck.insert(State(minutesLeft: 24, materials: materials, robots: robots))

        let geodes = findMaxPath(withStatesToCheck: &statesToCheck, blueprint: blueprint)

        quality += blueprint.id * geodes
    }
    print("total quality \(quality)")
    return quality
}

_ = run(part: 1, closure: part1)
