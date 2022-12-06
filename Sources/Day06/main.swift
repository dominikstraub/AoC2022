import Foundation
import Utils

// let input = try Utils.getInput(bundle: Bundle.module, file: "test")
let input = try Utils.getInput(bundle: Bundle.module)

func part1() -> Int {
    input: for (inputIndex, _) in input.enumerated() where inputIndex >= 3 {
        for searchIndex in inputIndex - 3 ..< inputIndex {
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
    return -1
}

_ = run(part: 1, closure: part1)

func part2() -> Int {
    input: for (inputIndex, _) in input.enumerated() where inputIndex >= 13 {
        for searchIndex in inputIndex - 13 ..< inputIndex {
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
    return -1
}

_ = run(part: 2, closure: part2)
