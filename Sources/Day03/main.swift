import Foundation
import Utils

// let input = try Utils.getInput(bundle: Bundle.module, file: "test")
let input = try Utils.getInput(bundle: Bundle.module)

let lines = input
    .components(separatedBy: CharacterSet(charactersIn: "\n"))
    .compactMap { line -> String? in
        if line == "" {
            return nil
        }
        return line
    }

func part1() -> Int {
    return lines.map { line in
        let first = line[0 ..< line.count / 2]
        let second = line[line.count / 2 ..< line.count]
        var char: Character?
        outerLoop: for firstChar in first {
            for secondChar in second where firstChar == secondChar {
                char = firstChar
                break outerLoop
            }
        }
        if let asciiUint = char?.asciiValue {
            let ascii = Int(asciiUint)
            var priority: Int?
            if ascii >= 97 {
                priority = ascii - 96
            } else if ascii >= 65 {
                priority = ascii - 64 + 26
            }
            if let priority {
                return priority
            }
        }
        return 0
    }.sum()
}

print("Part 1: \(part1())")

func part2() -> Int {
    var result = 0
    var lineNr = 0
    while lineNr < lines.count - 2 {
        var char: Character?
        firstLoop: for firstChar in lines[lineNr] {
            for secondChar in lines[lineNr + 1] where firstChar == secondChar {
                for thirdChar in lines[lineNr + 2] where secondChar == thirdChar {
                    char = firstChar
                    break firstLoop
                }
            }
        }
        lineNr += 3
        if let asciiUint = char?.asciiValue {
            let ascii = Int(asciiUint)
            var priority: Int?
            if ascii >= 97 {
                priority = ascii - 96
            } else if ascii >= 65 {
                priority = ascii - 64 + 26
            }
            if let priority {
                result += priority
            }
        }
    }
    return result
}

print("Part 2: \(part2())")
