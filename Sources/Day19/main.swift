import Foundation
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

struct Blueprint {
    let id: Int
    let recipes: [Material: Recipe]
}

extension Blueprint: CustomStringConvertible {
    public var description: String {
        return "Blueprint \(id): \(recipes)"
    }
}

func part1() -> Int {
    print(blueprints)
    var quality = 0
    for blueprint in blueprints {
        var materials: [Material: Int] = [
            .ore: 0,
            .clay: 0,
            .obsidian: 0,
            .geode: 0,
        ]
        var robots: [Material: Int] = [
            .ore: 1,
            .clay: 0,
            .obsidian: 0,
            .geode: 0,
        ]
        for minutesLeft in (1 ... 24).reversed() {
            defer {
                for (robot, count) in robots {
                    materials[robot]! += count
                }
                print(materials)
                print(robots)
            }
            if canBuildRobot(.geode, materials, blueprint) {
                if shouldBuildRobot(.geode, &materials, &robots, minutesLeft, blueprint) {
                    buildRobot(.geode, &materials, &robots, blueprint)
                    continue
                }
            }
            if canBuildRobot(.obsidian, materials, blueprint) {
                if shouldBuildRobot(.obsidian, &materials, &robots, minutesLeft, blueprint) {
                    buildRobot(.obsidian, &materials, &robots, blueprint)
                    continue
                }
            }
            if canBuildRobot(.clay, materials, blueprint) {
                if shouldBuildRobot(.clay, &materials, &robots, minutesLeft, blueprint) {
                    buildRobot(.clay, &materials, &robots, blueprint)
                    continue
                }
            }
            if canBuildRobot(.ore, materials, blueprint) {
                if shouldBuildRobot(.ore, &materials, &robots, minutesLeft, blueprint) {
                    buildRobot(.ore, &materials, &robots, blueprint)
                    continue
                }
            }
        }

        quality += blueprint.id * materials[.geode]!
    }
    return quality
}

func canBuildRobot(_ robot: Material, _ materials: [Material: Int], _ blueprint: Blueprint) -> Bool {
    for ingedient in blueprint.recipes[robot]! {
        if materials[ingedient.material]! < ingedient.amount {
            return false
        }
    }
    return true
}

func shouldBuildRobot(_ robot: Material, _ materials: inout [Material: Int], _ robots: inout [Material: Int], _ minutesLeft: Int, _ blueprint: Blueprint) -> Bool {
    print(robot)
    print(materials)
    print(robots)
    print(minutesLeft)
    print(blueprint)
    return true
}

func buildRobot(_ robot: Material, _ materials: inout [Material: Int], _ robots: inout [Material: Int], _ blueprint: Blueprint) {
    for ingedient in blueprint.recipes[robot]! {
        materials[ingedient.material]! -= ingedient.amount
    }
    robots[robot]! += 1
}

_ = run(part: 1, closure: part1)

// func part2() -> Int {
//     return -1
// }

// _ = run(part: 2, closure: part2)
