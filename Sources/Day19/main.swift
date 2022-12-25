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

struct StateKey {
    let materials: [Material: Int]
    let robots: [Material: Int]
}

extension StateKey: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(materials)
        hasher.combine(robots)
    }
}

extension StateKey: CustomStringConvertible {
    public var description: String {
        return "materials: \(materials), robots: \(robots)"
    }
}

typealias StateValue = [Int: Int]

typealias State = Dictionary<StateKey, StateValue>.Element

typealias States = [StateKey: StateValue]

func findMaxPath(withStatesToCheck statesToCheck: inout States, blueprint: Blueprint) -> Int {
    var states = States()
    let (key, value) = statesToCheck.first!
    states[key] = value

    while !statesToCheck.isEmpty {
        let state = statesToCheck.first!
        let key = state.key
        statesToCheck.removeValue(forKey: key)
        checkState(state, withStates: &states, andStatesToCheck: &statesToCheck, blueprint: blueprint)
    }

    var maxGeodes = Int.min

    print("states.count \(states.count)")
    for (key, value) in states {
        for (minutesLeft, geodes) in value {
            if geodes > maxGeodes {
                print("minutesLeft \(minutesLeft)")
                print("value.geodes \(geodes)")
                print("blueprint.id \(blueprint.id)")
                print("quality \(blueprint.id * geodes)")
                print("materials \(key.materials)")
                print("robots \(key.robots)")
                print()

                maxGeodes = geodes
            }
        }
    }
    return maxGeodes
}

func checkState(_ state: State, withStates states: inout States, andStatesToCheck statesToCheck: inout States, blueprint: Blueprint) {
    if state.value.isEmpty { return }
    var materials = state.key.materials
    materials[.geode] = 0
    let robots = state.key.robots

    let buildableRobots = getBuildableRobots(materials: materials, blueprint: blueprint)
    for buildableRobot in buildableRobots {
        var materials = materials
        var robots = robots

        for (material, amount) in robots {
            materials[material]! += amount
        }

        buildRobot(robot: buildableRobot, materials: &materials, robots: &robots, blueprint: blueprint)

        let addedGeodes = materials[.geode]!
        materials.removeValue(forKey: .geode)
        let key = StateKey(materials: materials, robots: robots)

        var newValue = states[key] ?? StateValue()
        var newToCheckValue = statesToCheck[key] ?? StateValue()
        for (minutesLeft, geodes) in state.value {
            let oldGeodes = newValue[minutesLeft - 1] ?? -1
            if oldGeodes < geodes + addedGeodes {
                newValue[minutesLeft - 1] = geodes + addedGeodes
                if minutesLeft - 1 > 0 {
                    newToCheckValue[minutesLeft - 1] = geodes + addedGeodes
                }
            }
        }
        states[key] = newValue
        statesToCheck[key] = newToCheckValue
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
        print("===blueprint.id \(blueprint.id)===")
        let materials: [Material: Int] = [
            .ore: 0,
            .clay: 0,
            .obsidian: 0,
        ]
        let robots: [Material: Int] = [
            .ore: 1,
            .clay: 0,
            .obsidian: 0,
            .geode: 0,
        ]

        var statesToCheck = States()
        let key = StateKey(materials: materials, robots: robots)
        var value = StateValue()
        value[24] = 0
        statesToCheck[key] = value

        let geodes = findMaxPath(withStatesToCheck: &statesToCheck, blueprint: blueprint)

        quality += blueprint.id * geodes

        break
    }
    print("total quality \(quality)")
    return quality
}

_ = run(part: 1, closure: part1)
