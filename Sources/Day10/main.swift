import Foundation
import Utils

// let input = try Utils.getInput(bundle: Bundle.module, file: "test")
let input = try Utils.getInput(bundle: Bundle.module)

func prepare() -> [(String, Int?)] {
    return input
        .components(separatedBy: CharacterSet(charactersIn: "\n"))
        .compactMap { line -> (String, Int?)? in
            if line == "" {
                return nil
            }
            let parts = line.components(separatedBy: CharacterSet(charactersIn: " "))
            var instruction: (String, Int?) = (parts[0], nil)
            if parts.count > 1 {
                instruction.1 = Int(parts[1])
            }
            return instruction
        }
}

let instructions = run(part: "Input parsing", closure: prepare)

func part1() -> Int {
    // print(instructions)
    var cycle = 0
    var x = 1
    var nextAmplitude = 20
    var signalStrengthSum = 0
    for instruction in instructions {
        let currentSignalStrength = x * nextAmplitude
        switch instruction.0 {
        case "addx":
            x += instruction.1!
            cycle += 2
        case "noop":
            cycle += 1
        default:
            return -1
        }
        if cycle >= nextAmplitude {
            nextAmplitude += 40
            signalStrengthSum += currentSignalStrength
        }
    }
    return signalStrengthSum
}

_ = run(part: 1, closure: part1)

func part2() -> Int {
    var cycle = 0
    var x = 1
    print("")
    print("")
    print("")
    for instruction in instructions {
        var cyclesLeft = 0
        var incrementLeft = 0
        switch instruction.0 {
        case "addx":
            incrementLeft += instruction.1!
            cyclesLeft += 2
        case "noop":
            cyclesLeft += 1
        default:
            return -1
        }
        for _ in 0 ..< cyclesLeft {
            if cycle == x - 1 || cycle == x || cycle == x + 1 {
                print("█", terminator: "")
            } else {
                print(" ", terminator: "")
            }
            cycle += 1
            if cycle % 40 == 0 {
                print("")
                cycle = 0
            }
        }
        x += incrementLeft
    }
    print("")
    print("")
    print("")
    return -1
}

_ = run(part: 2, closure: part2)
