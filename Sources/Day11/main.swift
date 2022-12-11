import Foundation
import Utils

// let input = try Utils.getInput(bundle: Bundle.module, file: "test")
let input = try Utils.getInput(bundle: Bundle.module)

func prepare() -> [Monkey] {
    return input
        .components(separatedBy: "\n\n")
        .compactMap { monkeyString -> Monkey? in
            if monkeyString == "" {
                return nil
            }

            let pattern = """
            Monkey ([0-9]+):
              Starting items: (([0-9]+(, )?)+)
              Operation: (((new)|(old)|([0-9]+)|([+\\-*/])| |=)+)
              Test: divisible by ([0-9]+)
                If true: throw to monkey ([0-9]+)
                If false: throw to monkey ([0-9]+)
            """

            var number: Int?
            var items: [Int]?
            var operation: ((Int) -> Int)?
            var test: Int?
            var trueMonkey: Int?
            var falseMonkey: Int?

            let regex = try? NSRegularExpression(pattern: pattern)
            guard let match = regex?.firstMatch(in: monkeyString, options: [], range: NSRange(location: 0, length: monkeyString.utf8.count)) else { return nil }

            if let range = Range(match.range(at: 1), in: monkeyString) {
                number = Int(monkeyString[range])
            }
            if let range = Range(match.range(at: 2), in: monkeyString) {
                items = String(monkeyString[range]).components(separatedBy: ", ").compactMap(Int.init)
            }
            if let opRange = Range(match.range(at: 10), in: monkeyString),
               let secondValueRange = Range(match.range(at: 6), in: monkeyString)
            {
                let opString = String(monkeyString[opRange])
                let secondValueString = String(monkeyString[secondValueRange])
                func tmpOperation(oldValue: Int) -> Int {
                    let secondValue = secondValueString == "old" ? oldValue : Int(secondValueString)!
                    switch opString {
                    case "*":
                        return oldValue * secondValue
                    case "/":
                        return oldValue / secondValue
                    case "+":
                        return oldValue + secondValue
                    case "-":
                        return oldValue - secondValue
                    default:
                        return oldValue * secondValue
                    }
                }
                operation = tmpOperation
            }
            if let range = Range(match.range(at: 11), in: monkeyString) {
                test = Int(monkeyString[range])!
            }
            if let range = Range(match.range(at: 12), in: monkeyString) {
                trueMonkey = Int(monkeyString[range])
            }
            if let range = Range(match.range(at: 13), in: monkeyString) {
                falseMonkey = Int(monkeyString[range])
            }

            return Monkey(number: number!, items: items!, operation: operation!, test: test!, trueMonkey: trueMonkey!, falseMonkey: falseMonkey!)
        }
}

let monkeys = run(part: "Input parsing", closure: prepare)

class Monkey {
    let number: Int
    var items: [Int]
    let operation: (Int) -> Int
    let test: Int
    let trueMonkey: Int
    let falseMonkey: Int

    var inspectionCount = 0

    init(number: Int, items: [Int], operation: @escaping (Int) -> Int, test: Int, trueMonkey: Int, falseMonkey: Int) {
        self.number = number
        self.items = items
        self.operation = operation
        self.test = test
        self.trueMonkey = trueMonkey
        self.falseMonkey = falseMonkey
    }
}

func part1() -> Int {
    for roundIndex in 0 ..< 20 {
        for (monkeyIndex, monkey) in monkeys.enumerated() {
            // print("Monkey \(monkeyIndex):")
            while monkey.items.count > 0 {
                var item = monkey.items[0]
                // print("  Monkey inspects an item with a worry level of \(item).")
                monkey.inspectionCount += 1
                // item = monkey.operation(item) / 3
                item = monkey.operation(item)
                // print("    Worry level to \(item).")
                item /= 3
                // print("    Monkey gets bored with item. Worry level is divided by 3 to \(item).")
                if item % monkey.test == 0 {
                    // print("    Current worry level is divisible by \(monkey.test).")
                    // print("    Item with worry level \(item) is thrown to monkey \(monkey.trueMonkey).")
                    monkeys[monkey.trueMonkey].items.append(item)
                } else {
                    // print("    Current worry level is not divisible by \(monkey.test).")
                    // print("    Item with worry level \(item) is thrown to monkey \(monkey.falseMonkey).")
                    monkeys[monkey.falseMonkey].items.append(item)
                }
                monkey.items.removeFirst()
            }
        }
        // print("After round \(roundIndex + 1), the monkeys are holding items with these worry levels:")
        for (monkeyIndex, monkey) in monkeys.enumerated() {
            // print("Monkey \(monkeyIndex): \(monkey.items)")
        }
    }
    for (monkeyIndex, monkey) in monkeys.enumerated() {
        // print("Monkey \(monkeyIndex) inspected items \(monkey.inspectionCount) times.")
    }
    return monkeys.map { $0.inspectionCount }.sorted().reversed()[0 ..< 2].product()
}

_ = run(part: 1, closure: part1)

// func part2() -> Int {
//     return -1
// }

// _ = run(part: 2, closure: part2)
