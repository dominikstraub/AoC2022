import Foundation
import Utils

// let input = try Utils.getInput(bundle: Bundle.module, file: "test")
let input = try Utils.getInput(bundle: Bundle.module)

func prepare() -> [[[Int]]] {
    return input
        .components(separatedBy: CharacterSet(charactersIn: "\n"))
        .compactMap { line -> [[Int]]? in
            if line == "" {
                return nil
            }
            return line.components(separatedBy: CharacterSet(charactersIn: ","))
                .compactMap { sections -> [Int]? in
                    if sections == "" {
                        return nil
                    }
                    return sections.components(separatedBy: CharacterSet(charactersIn: "-"))
                        .compactMap { section -> Int? in
                            if section == "" {
                                return nil
                            }
                            return Int(section)
                        }
                }
        }
}

let pairs = run(part: "Input parsing", closure: prepare)

func part1() -> Int {
    return pairs.filter { pair -> Bool in
        pair[0][0] <= pair[1][0] && pair[0][1] >= pair[1][1] || pair[0][0] >= pair[1][0] && pair[0][1] <= pair[1][1]
    }.count
}

_ = run(part: 1, closure: part1)

// func part2() -> Int {
//     return -1
// }

// _ = run(part: 2, closure: part2)
