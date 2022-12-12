import Foundation
import Utils

let input = try Utils.getInput(bundle: Bundle.module, file: "test")
// let input = try Utils.getInput(bundle: Bundle.module)

func prepare() -> [[Square]] {
    return input
        .components(separatedBy: CharacterSet(charactersIn: "\n"))
        .compactMap { line -> [Square]? in
            if line == "" {
                return nil
            }
            return line
                .compactMap { square -> Square? in
                    if String(square) == "" {
                        return nil
                    }
                    var height = 0
                    var start = false
                    var end = false
                    if square == "S" {
                        height = 0
                        start = true
                    } else if square == "E" {
                        height = 25
                        end = true
                    } else {
                        guard let asciiUint = square.asciiValue else { return nil }
                        let ascii = Int(asciiUint)
                        height = ascii - 97
                    }
                    return Square(start: start, end: end, height: height)
                }
        }
}

let lines = run(part: "Input parsing", closure: prepare)

var grid = [Point: Square]()

class Square {
    let start: Bool
    let end: Bool
    let height: Int
    var visited = false
    var shortestDistance: Int?
    var shortestPoint: Point?

    init(start: Bool, end: Bool, height: Int) {
        self.start = start
        self.end = end
        self.height = height
    }
}

func part1() -> Int {
    var startPoint: Point?
    var endPoint: Point?
    // find S & E
    for (lineIndex, line) in lines.enumerated() {
        for (squareIndex, square) in line.enumerated() {
            let point = Point(squareIndex, lineIndex)
            grid[point] = square
            if square.start {
                startPoint = point
            } else if square.end {
                square.shortestDistance = 0
                square.visited = true
                endPoint = point
            }
        }
    }
    guard let startPoint, let endPoint else { return -1 }
    var squaresToCheck = getUnvisitedNeighbours(point: endPoint)
    while !squaresToCheck.isEmpty {
        let point = squaresToCheck[0]
        squaresToCheck.removeFirst()
        squaresToCheck += checkSquare(point: point)
    }

    var path = [Point]()
    var next = grid[startPoint]!.shortestPoint
    print("\(next!) \(grid[next!]!.height)")
    while true {
        path.append(next!)
        next = grid[next!]!.shortestPoint
        if next == nil {
            break
        }
        print("\(next!) \(grid[next!]!.height)")
    }

    for (lineIndex, line) in lines.enumerated() {
        for (squareIndex, _) in line.enumerated() {
            let point = Point(squareIndex, lineIndex)
            if path.contains(point) {
                print("█", terminator: "")
            } else {
                print(" ", terminator: "")
            }
        }
        print()
    }

    return grid[startPoint]!.shortestDistance!
}

func checkSquare(point: Point) -> [Point] {
    let square = grid[point]!
    if square.visited {
        return []
    }
    print("\(point)", terminator: "")
    let climableNeighbours = getClimableNeighbours(point: point)
    let sortedNeighbours = climableNeighbours.sorted { grid[$0]!.shortestDistance ?? Int.max < grid[$1]!.shortestDistance ?? Int.max }
//    let mappedNeighbours = sortedNeighbours.map { grid[$0]! }
    guard let firstNeighbours = sortedNeighbours.first else { print(); square.visited = true; return [] }
    let neighbourSquare = grid[firstNeighbours]!
    guard let shortestDistance = neighbourSquare.shortestDistance else { print(); return [] }
    if shortestDistance < square.shortestDistance ?? Int.max {
        square.shortestDistance = shortestDistance + 1
    }
    square.shortestPoint = firstNeighbours
    print(" \(square.shortestDistance ?? -1)")
    square.visited = true
    return getNeighbours(point: point).filter {
        let tmpSquare = grid[$0]!
        if tmpSquare.height >= square.height - 1 {
            tmpSquare.visited = false
            return true
        } else if !tmpSquare.visited {
            return true
        } else {
            return false
        }
    }
    // square.shortestDistance = (grid[getClimableNeighbours(point: point).sorted { grid[$0]!.height > grid[$1]!.height }.first!]?.shortestDistance)! + 1
}

func getClimableNeighbours(point: Point) -> [Point] {
    return getNeighbours(point: point).filter { grid[$0]!.height <= grid[point]!.height + 1 }
}

func getUnvisitedNeighbours(point: Point) -> [Point] {
    return getNeighbours(point: point).filter { !grid[$0]!.visited }
}

func getNeighbours(point: Point) -> [Point] {
    return [
        // Point(point.x - 1, point.y - 1),
        Point(point.x, point.y - 1),
        // Point(point.x + 1, point.y - 1),
        Point(point.x - 1, point.y),
        Point(point.x + 1, point.y),
        // Point(point.x - 1, point.y + 1),
        Point(point.x, point.y + 1),
        // Point(point.x + 1, point.y + 1),
    ].filter { !($0.x < 0 || $0.y < 0 || $0.x >= lines[0].count || $0.y >= lines.count) }
}

_ = run(part: 1, closure: part1)

// func part2() -> Int {
//     return -1
// }

// _ = run(part: 2, closure: part2)
