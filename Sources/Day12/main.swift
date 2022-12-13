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

func findPathTo(endPoint: Point, inGrid grid: inout [Point: Square], withPointsToCheck pointsToCheck: inout OrderedSet<Point>) -> Int {
    while !pointsToCheck.isEmpty {
        let point = pointsToCheck.first!
        pointsToCheck.removeFirst()
        checkPoint(point, inGrid: &grid, withPointsToCheck: &pointsToCheck)
    }

    return grid[endPoint]!.shortestDistance
}

func checkPoint(_ point: Point, inGrid grid: inout [Point: Square], withPointsToCheck pointsToCheck: inout OrderedSet<Point>) {
    let square = grid[point]!
    if square.visited {
        return
    }
    for neighbourPoint in getNeighboursOfPoint(point, inGrid: &grid) {
        let neighbourSquare = grid[neighbourPoint]!
        if neighbourSquare.shortestDistance - 1 > square.shortestDistance {
            neighbourSquare.shortestDistance = square.shortestDistance + 1
            neighbourSquare.shortestPoint = point
        }
        pointsToCheck.insert(neighbourPoint, at: pointsToCheck.count)
    }
    square.visited = true
}

func getNeighboursOfPoint(_ point: Point, inGrid grid: inout [Point: Square]) -> [Point] {
    return [
        Point(point.x, point.y - 1),
        Point(point.x - 1, point.y),
        Point(point.x + 1, point.y),
        Point(point.x, point.y + 1),
    ].filter {
        // point inside grid
        !($0.x < 0 || $0.y < 0 || $0.x >= lines[0].count || $0.y >= lines.count) &&
            // points climable
            grid[$0]!.height <= grid[point]!.height + 1 &&
            // point unvisited
            !grid[$0]!.visited
    }
}

func part1() -> Int {
    var grid = [Point: Square]()
    var pointsToCheck = OrderedSet<Point>()
    var endPoint: Point?
    // find S & E
    for (lineIndex, line) in lines.enumerated() {
        for (squareIndex, square) in line.enumerated() {
            let point = Point(squareIndex, lineIndex)
            grid[point] = square
            square.visited = false
            square.shortestDistance = Int.max
            square.shortestPoint = nil
            if square.start {
                square.shortestDistance = 0
                pointsToCheck.insert(point, at: 0)
            } else if square.end {
                endPoint = point
            }
        }
    }
    let result = findPathTo(endPoint: endPoint!, inGrid: &grid, withPointsToCheck: &pointsToCheck)

    var path = [Point]()
    var next = grid[endPoint!]!.shortestPoint
    while true {
        path.append(next!)
        next = grid[next!]!.shortestPoint
        if next == nil {
            break
        }
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

    return result
}

_ = run(part: 1, closure: part1)

func part2() -> Int {
    var grid = [Point: Square]()
    var pointsToCheck = OrderedSet<Point>()
    var endPoint: Point?
    // find S & E
    for (lineIndex, line) in lines.enumerated() {
        for (squareIndex, square) in line.enumerated() {
            let point = Point(squareIndex, lineIndex)
            grid[point] = square
            square.visited = false
            square.shortestDistance = Int.max
            square.shortestPoint = nil
            if square.height == 0 {
                square.shortestDistance = 0
                pointsToCheck.insert(point, at: 0)
            } else if square.end {
                endPoint = point
            }
        }
    }
    let result = findPathTo(endPoint: endPoint!, inGrid: &grid, withPointsToCheck: &pointsToCheck)

    var path = [Point]()
    var next = grid[endPoint!]!.shortestPoint
    while true {
        path.append(next!)
        next = grid[next!]!.shortestPoint
        if next == nil {
            break
        }
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

    return result
}

_ = run(part: 2, closure: part2)
