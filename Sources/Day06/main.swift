import Foundation
import Utils

// let input = try Utils.getInput(bundle: Bundle.module, file: "test")
let input = try Utils.getInput(bundle: Bundle.module)

func loopSearch(length: Int) -> Int? {
    input: for (inputIndex, _) in input.enumerated() where inputIndex >= (length - 1) {
        for searchIndex in inputIndex - (length - 1) ..< inputIndex {
            let searchChar = input[searchIndex]
            for matchIndex in searchIndex + 1 ... inputIndex {
                let matchChar = input[matchIndex]
                if searchChar == matchChar {
                    continue input
                }
            }
        }
        return inputIndex + 1
    }
    return nil
}

func rangeSearch(length: Int) -> Int? {
    for index in length - 1 ..< input.count where Set(input[index - (length - 1) ... index].map(String.init)).count == length {
        return index + 1
    }
    return nil
}

func part1() -> Int {
    return loopSearch(length: 4) ?? -1
}

func part1Range() -> Int {
    return rangeSearch(length: 4) ?? -1
}

_ = run(part: 1, closure: part1)
_ = run(part: 1, closure: part1Range)

func part2() -> Int {
    return loopSearch(length: 4) ?? -1
}

func part2Range() -> Int {
    return rangeSearch(length: 4) ?? -1
}

_ = run(part: 2, closure: part2)
_ = run(part: 2, closure: part2Range)
