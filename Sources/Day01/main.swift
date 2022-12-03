import Foundation
import Utils

// let input = try Utils.getInput(bundle: Bundle.module, file: "test")
let input = try Utils.getInput(bundle: Bundle.module)

func prepare() -> [[Int]] {
    return input
        .components(separatedBy: "\n\n")
        .compactMap { elve -> [Int]? in
            if elve == "" {
                return nil
            }
            return elve.components(separatedBy: CharacterSet(charactersIn: "\n"))
                .compactMap { food -> Int? in
                    if food == "" {
                        return nil
                    }
                    return Int(food)
                }
        }
}

let elves = run(part: "Input parsing", closure: prepare)

func part1() -> Int {
    var mostFoodElve: Int?
    for elve in elves {
        if mostFoodElve == nil || elve.sum() > mostFoodElve! {
            mostFoodElve = elve.sum()
        }
    }
    return mostFoodElve!
}

_ = run(part: 1, closure: part1)

func part2() -> Int {
    return elves.compactMap { $0.sum() }.sorted().reversed()[0 ... 2].sum()
}

_ = run(part: 2, closure: part2)
