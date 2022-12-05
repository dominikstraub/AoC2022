import Foundation
import Utils

let input = try Utils.getInput(bundle: Bundle.module, file: "test")
// let input = try Utils.getInput(bundle: Bundle.module)

func prepare() -> (stacks: [String], instructions: [(count: Int, src: Int, dst: Int)]) {
    let parts = input
        .components(separatedBy: "\n\n")
        .compactMap { part -> String? in
            if part == "" {
                return nil
            }
            return part
        }
    var stacks = parts[0].components(separatedBy: "\n")
        .compactMap { line -> String? in
            if line == "" {
                return nil
            }
            return line
        }
    stacks.removeLast()
    let instructions = parts[1].components(separatedBy: "\n")
        .compactMap { line -> (count: Int, src: Int, dst: Int)? in
            if line == "" {
                return nil
            }
            let pattern = "move ([0-9]+) from ([0-9]+) to ([0-9]+)"
            let regex = try? NSRegularExpression(pattern: pattern)
            guard let match = regex?.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.utf8.count)) else { return nil }
            guard let count = Int(line[Range(match.range(at: 1), in: line)!]) else { return nil }
            guard let src = Int(line[Range(match.range(at: 2), in: line)!]) else { return nil }
            guard let dst = Int(line[Range(match.range(at: 3), in: line)!]) else { return nil }

            return (count: count, src: src, dst: dst)
        }
    return (stacks: stacks, instructions: instructions)
}

let parts = run(part: "Input parsing", closure: prepare)

func part1() -> Int {
    print(parts)
    return -1
}

_ = run(part: 1, closure: part1)

// func part2() -> Int {
//     return -1
// }

// _ = run(part: 2, closure: part2)
