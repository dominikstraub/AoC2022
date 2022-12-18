import Foundation
import Utils

// let input = try Utils.getInput(bundle: Bundle.module, file: "test")
let input = try Utils.getInput(bundle: Bundle.module)

func prepare() -> [Point3D] {
    return input
        .components(separatedBy: "\n")
        .compactMap { line -> Point3D? in
            if line == "" {
                return nil
            }
            let numbers = line
                .components(separatedBy: ",")
                .compactMap { number -> Int? in
                    if number == "" {
                        return nil
                    }
                    return Int(number)
                }

            return Point3D(numbers[0], numbers[1], numbers[2])
        }
}

let points = run(part: "Input parsing", closure: prepare)

func part1() -> Int {
    // print(points)
    var grid = Set<Point3D>()
    for point in points {
        grid.insert(point)
    }

    var surfaceArea = 0
    for point in points {
        for dimension in 0 ..< 3 {
            for direction in [-1, 1] {
                var neighbour = point
                neighbour[dimension] += direction
                if !grid.contains(neighbour) {
                    surfaceArea += 1
                }
            }
        }
    }
    return surfaceArea
}

_ = run(part: 1, closure: part1)

// func part2() -> Int {
//     return -1
// }

// _ = run(part: 2, closure: part2)
