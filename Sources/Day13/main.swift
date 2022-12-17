import Foundation
import Utils

// let input = try Utils.getInput(bundle: Bundle.module, file: "test")
let input = try Utils.getInput(bundle: Bundle.module)

func prepare() -> [(List, List)] {
    return input
        .components(separatedBy: "\n\n")
        .compactMap { pair -> (List, List)? in
            if pair == "" {
                return nil
            }
            let tmp = pair
                .components(separatedBy: "\n")
                .compactMap { line -> List? in
                    if line == "" {
                        return nil
                    }
                    return List(line)
                }
            return (tmp[0], tmp[1])
        }
}

struct List {
    let values: [Value]
    let stringLength: Int

    init(_ int: Int) {
        stringLength = 1
        values = [Value.integer(int)]
    }

    init(_ string: String) {
        var values = [Value]()
        var charIndex = 1
        while charIndex < string.count {
            if string[charIndex] == "[" {
                let list = List(String(string[charIndex ..< string.count]))
                values.append(Value.list(list))
                charIndex += list.stringLength
            } else if string[charIndex] == "," {
                charIndex += 1
            } else if string[charIndex] == "]" {
                charIndex += 1
                break
            } else {
                values.append(Value.integer(Int(String(string[charIndex]))!))
                charIndex += 1
            }
        }
        stringLength = charIndex
        self.values = values
    }
}

extension List: CustomStringConvertible {
    var description: String {
        return "[\(values.map { $0.description }.joined(separator: ","))]"
    }
}

extension List: Equatable {
    static func == (lhs: List, rhs: List) -> Bool {
        compare(lhs, rhs) == 0
    }
}

extension List: Comparable {
    static func < (lhs: List, rhs: List) -> Bool {
        compare(lhs, rhs) == -1
    }
}

enum Value {
    case integer(Int)
    case list(List)
}

extension Value: CustomStringConvertible {
    var description: String {
        switch self {
        case let .integer(int):
            return "\(int)"
        case let .list(list):
            return "\(list)"
        }
    }
}

func compare(_ lhs: Value, _ rhs: Value) -> Int {
    // print("Compare \(lhs) vs \(rhs)")
    switch (lhs, rhs) {
    case let (.integer(lhs), .integer(rhs)):
        return compare(lhs, rhs)
    case let (.list(lhs), .list(rhs)):
        return compare(lhs, rhs)
    case let (.integer(lhs), .list(rhs)):
        // print("- Compare \(lhs) vs \(rhs)")
        // print("- Mixed types; convert left to \(List(lhs)) and retry comparison")
        return compare(List(lhs), rhs)
    case let (.list(lhs), .integer(rhs)):
        // print("- Compare \(lhs) vs \(rhs)")
        // print("- Mixed types; convert right to \(List(rhs)) and retry comparison")
        return compare(lhs, List(rhs))
    }
}

func compare(_ lhs: List, _ rhs: List) -> Int {
    // print("- Compare \(lhs) vs \(rhs)")
    for listIndex in 0 ..< min(lhs.values.count, rhs.values.count) {
        let result = compare(lhs.values[listIndex], rhs.values[listIndex])
        if result != 0 {
            return result
        }
    }
    if lhs.values.count < rhs.values.count {
        // print("- Left side ran out of items, so inputs are in the right order")
        return -1
    } else if lhs.values.count > rhs.values.count {
        // print("- Right side ran out of items, so inputs are not in the right order")
        return 1
    } else {
        return 0
    }
}

func compare(_ lhs: Int, _ rhs: Int) -> Int {
    // print("- Compare \(lhs) vs \(rhs)")
    if lhs < rhs {
        // print("- Left side is smaller, so inputs are in the right order")
        return -1
    } else if lhs > rhs {
        // print("- Right side is smaller, so inputs are not in the right order")
        return 1
    } else {
        return 0
    }
}

var pairs = run(part: "Input parsing", closure: prepare)

// func part1() -> Int {
//     var sum = 0
//     for (pairIndex, pair) in pairs.enumerated() {
//         print("== Pair \(pairIndex + 1) ==")
//         if compare(pair.0, pair.1) != 1 {
//             // print(pairIndex + 1)
//             sum += pairIndex + 1
//         }
//         // print(pair.0)
//         // print(pair.1)
//         print()
//     }
//     return sum
// }

// _ = run(part: 1, closure: part1)

func part2() -> Int {
    let divider = (List("[[2]]"), List("[[6]]"))
    var packets = [List]()
    packets.append(divider.0)
    packets.append(divider.1)
    for pair in pairs {
        packets.append(pair.0)
        packets.append(pair.1)
    }
    packets.sort()
    var key = 1
    for (index, packet) in packets.enumerated() {
        print(packet)
        if packet == divider.0 || packet == divider.1 {
            print("divider")
            print(key)
            print(index + 1)
            key *= index + 1
            print(key)
        }
    }
    return key
}

_ = run(part: 2, closure: part2)
