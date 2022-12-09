import Foundation
import Utils

// let input = try Utils.getInput(bundle: Bundle.module, file: "test")
// let input = try Utils.getInput(bundle: Bundle.module, file: "test2")
let input = try Utils.getInput(bundle: Bundle.module)

func prepare() -> [(direction: String, steps: Int)] {
    return input
        .components(separatedBy: CharacterSet(charactersIn: "\n"))
        .compactMap { line -> (direction: String, steps: Int)? in
            if line == "" {
                return nil
            }
            let parts = line
                .components(separatedBy: CharacterSet(charactersIn: " "))

            return (direction: parts[0], steps: Int(parts[1])!)
        }
}

let instructions = run(part: "Input parsing", closure: prepare)

func simulateRope(length: Int = 2) -> Int {
    var rope = [Point]()
    for _ in 0 ..< length {
        rope.append(Point(0, 0))
    }
    // print(rope: rope)
    // print(rope[length - 1])
    var tailPositions = Set<Point>()
    tailPositions.insert(rope[length - 1])
    for instruction in instructions {
        // print(instruction)
        for _ in 0 ..< instruction.steps {
            switch instruction.direction {
            case "U":
                rope[0].y += 1
            case "R":
                rope[0].x += 1
            case "D":
                rope[0].y -= 1
            case "L":
                rope[0].x -= 1
            default:
                break
            }
            for i in 0 ..< length - 1 {
                if abs(rope[i].x - rope[i + 1].x) > 1 || abs(rope[i].y - rope[i + 1].y) > 1 {
                    if rope[i].x > rope[i + 1].x {
                        rope[i + 1].x += min(rope[i].x - rope[i + 1].x, 1)
                    } else {
                        rope[i + 1].x += max(rope[i].x - rope[i + 1].x, -1)
                    }
                    if rope[i].y > rope[i + 1].y {
                        rope[i + 1].y += min(rope[i].y - rope[i + 1].y, 1)
                    } else {
                        rope[i + 1].y += max(rope[i].y - rope[i + 1].y, -1)
                    }
                }
            }
            tailPositions.insert(rope[length - 1])
        }
        // print(rope: rope)
        // print(rope[length - 1])
    }
    // print(positions: tailPositions)
    return tailPositions.count
}

func print(rope: [Point]) {
    let minX = min(rope.map { $0.x }.min() ?? 0, 0)
    let maxX = max(rope.map { $0.x }.max() ?? 0, 0)
    let minY = min(rope.map { $0.y }.min() ?? 0, 0)
    let maxY = max(rope.map { $0.y }.max() ?? 0, 0)
    for y in (minY ... maxY).reversed() {
        position: for x in minX ... maxX {
            for i in 0 ..< rope.count where Point(x, y) == rope[i] {
                print("\(i)", terminator: "")
                continue position
            }
            if Point(x, y) == Point(0, 0) {
                print("s", terminator: "")
            } else {
                print(".", terminator: "")
            }
        }
        print("")
    }
}

func print(positions: Set<Point>) {
    let minX = min(positions.map { $0.x }.min() ?? 0, 0)
    let maxX = max(positions.map { $0.x }.max() ?? 0, 0)
    let minY = min(positions.map { $0.y }.min() ?? 0, 0)
    let maxY = max(positions.map { $0.y }.max() ?? 0, 0)
    for y in (minY ... maxY).reversed() {
        for x in minX ... maxX {
            if positions.contains(Point(x, y)) {
                print("#", terminator: "")
            } else if Point(x, y) == Point(0, 0) {
                print("s", terminator: "")
            } else {
                print(".", terminator: "")
            }
        }
        print("")
    }
}

func part1() -> Int {
    return simulateRope()
}

_ = run(part: 1, closure: part1)

func part2() -> Int {
    return simulateRope(length: 10)
}

_ = run(part: 2, closure: part2)
