import Foundation
import OrderedCollections
import Utils

// let input = try Utils.getInput(bundle: Bundle.module, file: "test")
let input = try Utils.getInput(bundle: Bundle.module)

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
    var shortestDistance = Int.max
    var shortestPoint: Point?

    init(start: Bool, end: Bool, height: Int) {
        self.start = start
        self.end = end
        self.height = height
    }
}

var pointsToCheck = OrderedSet<Point>()

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
                endPoint = point
                pointsToCheck.insert(point, at: 0)
            } else {}
        }
    }
    guard let startPoint, let endPoint else { return -1 }
    while !pointsToCheck.isEmpty {
        let point = pointsToCheck.first!
        pointsToCheck.removeFirst()
        checkPoint(point: point)
    }

    // var path = [Point]()
    // var next = grid[startPoint]!.shortestPoint
    // print("\(next!) \(grid[next!]!.height)")
    // while true {
    //     path.append(next!)
    //     next = grid[next!]!.shortestPoint
    //     if next == nil {
    //         break
    //     }
    //     print("\(next!) \(grid[next!]!.height)")
    // }

    // for (lineIndex, line) in lines.enumerated() {
    //     for (squareIndex, _) in line.enumerated() {
    //         let point = Point(squareIndex, lineIndex)
    //         if path.contains(point) {
    //             print("█", terminator: "")
    //         } else {
    //             print(" ", terminator: "")
    //         }
    //     }
    //     print()
    // }

    return grid[startPoint]!.shortestDistance
}

func checkPoint(point: Point) {
    let square = grid[point]!
    if square.visited {
        return
    }
    for neighbourPoint in getNeighbours(point: point) {
        let neighbourSquare = grid[neighbourPoint]!
        if neighbourSquare.shortestDistance - 1 > square.shortestDistance {
            neighbourSquare.shortestDistance = square.shortestDistance + 1
            neighbourSquare.shortestPoint = point
        }
        pointsToCheck.insert(neighbourPoint, at: pointsToCheck.count)
    }
    square.visited = true
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
    ].filter {
        // point inside grid
        !($0.x < 0 || $0.y < 0 || $0.x >= lines[0].count || $0.y >= lines.count) &&
            // points climable from
            grid[$0]!.height >= grid[point]!.height - 1 &&
            // point unvisited
            !grid[$0]!.visited
    }
}

_ = run(part: 1, closure: part1)

// func part2() -> Int {
//     return -1
// }

// _ = run(part: 2, closure: part2)
