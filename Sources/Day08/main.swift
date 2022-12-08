import Foundation
import Utils

// let input = try Utils.getInput(bundle: Bundle.module, file: "test")
let input = try Utils.getInput(bundle: Bundle.module)

func prepare() -> [[Int]] {
    return input
        .components(separatedBy: CharacterSet(charactersIn: "\n"))
        .compactMap { line -> [Int]? in
            if line == "" {
                return nil
            }
            return line
                .compactMap { tree -> Int? in
                    Int(String(tree))
                }
        }
}

let grid = run(part: "Input parsing", closure: prepare)

func part1() -> Int {
    var visibleCount = (grid.count + grid[0].count - 2) * 2
    for currentY in 1 ..< grid.count - 1 {
        let row = grid[currentY]
        for currentX in 1 ..< grid[0].count - 1 {
            let tree = row[currentX]
            var visible = true
            for y in 0 ..< currentY where grid[y][currentX] >= tree {
                visible = false
                break
            }
            if visible {
                visibleCount += 1
                continue
            } else {
                visible = true
            }
            for y in currentY + 1 ..< grid.count where grid[y][currentX] >= tree {
                visible = false
                break
            }
            if visible {
                visibleCount += 1
                continue
            } else {
                visible = true
            }
            for x in 0 ..< currentX where row[x] >= tree {
                visible = false
                break
            }
            if visible {
                visibleCount += 1
                continue
            } else {
                visible = true
            }
            for x in currentX + 1 ..< grid.count where row[x] >= tree {
                visible = false
                break
            }
            if visible {
                visibleCount += 1
                continue
            } else {
                visible = true
            }
        }
    }
    return visibleCount
}

_ = run(part: 1, closure: part1)

// func part2() -> Int {
//     return -1
// }

// _ = run(part: 2, closure: part2)
