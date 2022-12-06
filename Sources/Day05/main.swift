import Foundation
import Utils

// let input = try Utils.getInput(bundle: Bundle.module, file: "test")
let input = try Utils.getInput(bundle: Bundle.module)

func prepare() -> (stacks: [[String?]], instructions: [(count: Int, src: Int, dst: Int)]) {
    let parts = input
        .components(separatedBy: "\n\n")
        .compactMap { part -> String? in
            if part == "" {
                return nil
            }
            return part
        }
    var stacks = parts[0].components(separatedBy: "\n")
        .compactMap { line -> [String?]? in
            if line == "" {
                return nil
            }
            let pattern = "((\\[([A-Z])\\] ?)| {3,4})"
            let regex = try? NSRegularExpression(pattern: pattern)
            guard let matches = regex?.matches(in: line, options: [], range: NSRange(location: 0, length: line.utf8.count)) else { return nil }
            var stackLine = [String?]()

            for match in matches {
                if let range = Range(match.range(at: 3), in: line) {
                    stackLine.append(String(line[range]))
                } else {
                    stackLine.append(nil)
                }
            }

            return stackLine
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

            return (count: count, src: src - 1, dst: dst - 1)
        }
    return (stacks: stacks, instructions: instructions)
}

let parts = run(part: "Input parsing", closure: prepare)
let (stacksOrig, instructions) = parts

func part1() -> String {
    var stacks = stacksOrig
    // print(instructions: instructions)
    // print(stacks: stacks)
    for instruction in instructions {
        // print(instruction: instruction)
        for _ in 0 ..< instruction.count {
            src: for srcHeight in 0 ..< stacks.count {
                if let value = stacks[srcHeight][safe: instruction.src], let value = value {
                    // print("value: \(value)")
                    for dstHeight in (0 ..< stacks.count).reversed() {
                        guard let tmp = stacks[dstHeight][safe: instruction.dst], let _ = tmp else {
                            while stacks[safe: dstHeight]!.count <= instruction.dst {
                                stacks[dstHeight].append(nil)
                            }
                            // print("src height: \(srcHeight), stack: \(instruction.src)")
                            // print("dst height: \(dstHeight), stack: \(instruction.dst)")
                            stacks[dstHeight][instruction.dst] = value
                            stacks[srcHeight][instruction.src] = nil
                            // print(stacks: stacks)
                            break src
                        }
                    }
                    stacks.insert([String?](), at: 0)
                    let dstHeight = 0
                    while stacks[safe: dstHeight]!.count <= instruction.dst {
                        stacks[dstHeight].append(nil)
                    }
                    // print("src height: \(srcHeight), stack: \(instruction.src)")
                    // print("dst height: \(dstHeight - 1), stack: \(instruction.dst)")
                    stacks[dstHeight][instruction.dst] = value
                    stacks[srcHeight + 1][instruction.src] = nil
                    // print(stacks: stacks)
                    break src
                }
            }
        }
    }

    var result = ""
    for stack in 0 ..< stacks[stacks.count - 1].count {
        for srcHeight in 0 ..< stacks.count {
            if let value = stacks[srcHeight][safe: stack], let value = value {
                result.append(value)
                break
            }
        }
    }

    return result
}

func print(stacks: [[String?]]) {
    for stackLine in stacks {
        for value in stackLine {
            if let value {
                print("[\(value)]", terminator: "")
            } else {
                print("   ", terminator: "")
            }
            print(" ", terminator: "")
        }
        print("")
    }
}

func print(instructions: [(count: Int, src: Int, dst: Int)]) {
    for instruction in instructions {
        print(instruction: instruction)
    }
}

func print(instruction: (count: Int, src: Int, dst: Int)) {
    print("move \(instruction.count) from \(instruction.src) to \(instruction.dst)")
}

_ = run(part: 1, closure: part1)

func part2() -> String {
    var stacks = stacksOrig
    // print(instructions: instructions)
    // print(stacks: stacks)
    for instruction in instructions {
        // print(instruction: instruction)
        for offset in (0 ..< instruction.count).reversed() {
            src: for srcHeight in 0 ..< stacks.count {
                if let tmp = stacks[srcHeight][safe: instruction.src], let _ = tmp, let value = stacks[srcHeight + offset][safe: instruction.src], let value = value {
                    // print("value: \(value)")
                    for dstHeight in (0 ..< stacks.count).reversed() {
                        guard let tmp = stacks[dstHeight][safe: instruction.dst], let _ = tmp else {
                            while stacks[safe: dstHeight]!.count <= instruction.dst {
                                stacks[dstHeight].append(nil)
                            }
                            // print("src height: \(srcHeight + offset), stack: \(instruction.src)")
                            // print("dst height: \(dstHeight), stack: \(instruction.dst)")
                            stacks[dstHeight][instruction.dst] = value
                            stacks[srcHeight + offset][instruction.src] = nil
                            // print(stacks: stacks)
                            break src
                        }
                    }
                    stacks.insert([String?](), at: 0)
                    let dstHeight = 0
                    while stacks[safe: dstHeight]!.count <= instruction.dst {
                        stacks[dstHeight].append(nil)
                    }
                    // print("src height: \(srcHeight + offset), stack: \(instruction.src)")
                    // print("dst height: \(dstHeight - 1), stack: \(instruction.dst)")
                    stacks[dstHeight][instruction.dst] = value
                    stacks[srcHeight + offset + 1][instruction.src] = nil
                    // print(stacks: stacks)
                    break src
                }
            }
        }
    }

    var result = ""
    for stack in 0 ..< stacks[stacks.count - 1].count {
        for srcHeight in 0 ..< stacks.count {
            if let value = stacks[srcHeight][safe: stack], let value = value {
                result.append(value)
                break
            }
        }
    }

    return result
}

_ = run(part: 2, closure: part2)
