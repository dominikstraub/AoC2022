import Foundation
import Utils

if #available(macOS 13.0, *) {
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
                guard let regex = try? Regex("a(.*)(b)") else { return nil }
                let match = "cbaxb".wholeMatch(of: regex)
                print(match.0) // "axb"
//                print(match!.1) // "x"
                // guard let regex = try? Regex("move ([0-9]+) from ([0-9]+) to ([0-9]+)") else { return nil }
                // guard let test = try? regex.wholeMatch(in: line) else { return nil }
                // print(test)
                // print("====")
                // let tmp = test[1]
                // print(tmp)
                // print("====")
                // let matches = line.matches(of: regex)
//                let matchOne = matches[0]
                return (count: Int(1), src: Int(2), dst: Int(3))
            }
        return (stacks: stacks, instructions: instructions)
    }

    let lines = run(part: "Input parsing", closure: prepare)

    func part1() -> Int {
        return -1
    }

    _ = run(part: 1, closure: part1)

    // func part2() -> Int {
//     return -1
    // }

    // _ = run(part: 2, closure: part2)

} else {
    // Fallback on earlier versions
}
