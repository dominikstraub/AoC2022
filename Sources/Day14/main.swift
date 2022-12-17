import Foundation
import Utils

// let input = try Utils.getInput(bundle: Bundle.module, file: "test")
let input = try Utils.getInput(bundle: Bundle.module)

func prepare() -> [[Point]] {
    return input
        .components(separatedBy: "\n")
        .compactMap { line -> [Point]? in
            if line == "" {
                return nil
            }
            return line
                .components(separatedBy: " -> ")
                .compactMap { rockPoint -> Point? in
                    if rockPoint == "" {
                        return nil
                    }
                    let rockPointCoords = rockPoint
                        .components(separatedBy: ",")
                        .compactMap { rockPointCoord -> Int? in
                            if rockPointCoord == "" {
                                return nil
                            }
                            return Int(rockPointCoord)
                        }
                    return Point(rockPointCoords[0], rockPointCoords[1])
                }
        }
}

let rocks = run(part: "Input parsing", closure: prepare)

enum Material {
    case air
    case rock
    case sand
    case source
}

extension Material: CustomStringConvertible {
    public var description: String {
        switch self {
        case .air:
            return "."
        case .rock:
            return "#"
        case .sand:
            return "o"
        case .source:
            return "+"
        }
    }
}

func part1() -> Int {
    var grid = [Point: Material]()
    let source = Point(500, 0)
    grid[source] = .source
    var minX = 500
    var maxX = 500
    var minY = 0
    var maxY = 0
    for rock in rocks {
        for index in 0 ..< rock.count - 1 {
            let src = rock[index]
            let dst = rock[index + 1]
            let currentMinX = min(src.x, dst.x)
            let currentMaxX = max(src.x, dst.x)
            let currentMinY = min(src.y, dst.y)
            let currentMaxY = max(src.y, dst.y)
            if currentMinX < minX {
                minX = currentMinX
            }
            if currentMaxX > maxX {
                maxX = currentMaxX
            }
            if currentMinY < minY {
                minY = currentMinY
            }
            if currentMaxY > maxY {
                maxY = currentMaxY
            }
            for yIndex in currentMinY ... currentMaxY {
                for xIndex in currentMinX ... currentMaxX {
                    let point = Point(xIndex, yIndex)
                    grid[point] = .rock
                }
            }
        }
    }

    var sandCount = 0

    sand: while true {
        var newSand = source
        falling: while true {
            if newSand.y > maxY {
                break sand
            }
            if grid[Point(newSand.x, newSand.y + 1)] ?? .air == .air {
                newSand.y += 1
                continue falling
            }
            if grid[Point(newSand.x - 1, newSand.y + 1)] ?? .air == .air {
                newSand.y += 1
                newSand.x -= 1
                continue falling
            }
            if grid[Point(newSand.x + 1, newSand.y + 1)] ?? .air == .air {
                newSand.y += 1
                newSand.x += 1
                continue falling
            }
            break falling
        }
        grid[newSand] = .sand
        sandCount += 1
    }

    for yIndex in minY ... maxY {
        for xIndex in minX ... maxX {
            let point = Point(xIndex, yIndex)
            print(grid[point] ?? .air, terminator: "")
        }
        print("")
    }

    return sandCount
}

_ = run(part: 1, closure: part1)

// func part2() -> Int {
//     return -1
// }

// _ = run(part: 2, closure: part2)
