import Foundation
import Utils

// let input = try Utils.getInput(bundle: Bundle.module, file: "test")
let input = try Utils.getInput(bundle: Bundle.module)

func prepare() -> [[String]] {
    return input
        .components(separatedBy: CharacterSet(charactersIn: "\n"))
        .compactMap { line -> [String]? in
            if line == "" {
                return nil
            }
            return line.components(separatedBy: CharacterSet(charactersIn: " "))
                .compactMap { char -> String? in
                    if char == "" {
                        return nil
                    }
                    return char
                }
        }
}

let lines = run(part: "Input parsing", closure: prepare)

func part1() -> Int {
    return lines.compactMap { round -> Int in
        var points = 0
        switch round[1] {
        case "X":
            points += 1
            switch round[0] {
            case "A":
                points += 3
            case "C":
                points += 6
            default:
                break
            }
        case "Y":
            points += 2
            switch round[0] {
            case "A":
                points += 6
            case "B":
                points += 3
            default:
                break
            }
        case "Z":
            points += 3
            switch round[0] {
            case "B":
                points += 6
            case "C":
                points += 3
            default:
                break
            }
        default:
            break
        }
        return points
    }.sum()
}

_ = run(part: 1, closure: part1)

func part2() -> Int {
    return lines.compactMap { round -> Int in
        var points = 0
        switch round[1] {
        case "X":
            switch round[0] {
            case "A":
                points += 3
            case "B":
                points += 1
            case "C":
                points += 2
            default:
                break
            }
        case "Y":
            points += 3
            switch round[0] {
            case "A":
                points += 1
            case "B":
                points += 2
            case "C":
                points += 3
            default:
                break
            }
        case "Z":
            points += 6
            switch round[0] {
            case "A":
                points += 2
            case "B":
                points += 3
            case "C":
                points += 1
            default:
                break
            }
        default:
            break
        }
        return points
    }.sum()
}

_ = run(part: 2, closure: part2)
