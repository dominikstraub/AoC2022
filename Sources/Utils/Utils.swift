import Foundation

public extension StringProtocol {
    subscript(_ offset: Int) -> Element { self[index(startIndex, offsetBy: offset)] }
    subscript(_ range: Range<Int>) -> SubSequence { prefix(range.lowerBound + range.count).suffix(range.count) }
    subscript(_ range: ClosedRange<Int>) -> SubSequence { prefix(range.lowerBound + range.count).suffix(range.count) }
    subscript(_ range: PartialRangeThrough<Int>) -> SubSequence { prefix(range.upperBound.advanced(by: 1)) }
    subscript(_ range: PartialRangeUpTo<Int>) -> SubSequence { prefix(range.upperBound) }
    subscript(_ range: PartialRangeFrom<Int>) -> SubSequence { suffix(Swift.max(0, count - range.lowerBound)) }

    func contains(_ elements: Set<Character>) -> Bool {
        for element in elements where !contains(element) {
            return false
        }
        return true
    }

    func hexToBin() -> String {
        return compactMap { $0.hexToBin() }.joined(separator: "")
    }

    func binToDec() -> Int? {
        return Int(self, radix: 2)
    }

    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}

public extension Character {
    func hexToDec() -> Int? {
        return Int(string, radix: 16)
    }

    func hexToBin() -> String? {
        guard let dec = hexToDec() else { return nil }
        return String(String(dec, radix: 2).paddingToLeft(upTo: 4, using: "0"))
    }
}

public extension LosslessStringConvertible {
    var string: String { .init(self) }
}

public extension BidirectionalCollection {
    subscript(safe offset: Int) -> Element? {
        guard !isEmpty,
              offset >= 0,
              let index = index(startIndex, offsetBy: offset, limitedBy: index(before: endIndex))
        else { return nil }
        return self[index]
    }
}

// modulo in swift can return negative numbers, so we make our own modulo operator
infix operator %%
public extension Int {
    static func %% (_ lhs: Int, _ rhs: Int) -> Int {
        if lhs >= 0 { return lhs % rhs }
        if lhs >= -rhs { return (lhs + rhs) }
        return ((lhs % rhs) + rhs) % rhs
    }
}

precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ^^: PowerPrecedence
public func ^^ (radix: Int, power: Int) -> Int {
    return Int(pow(Double(radix), Double(power)))
}

public func ^^ (radix: Int, power: Int) -> Double {
    return pow(Double(radix), Double(power))
}

public func ^^ (radix: Double, power: Double) -> Double {
    return pow(radix, power)
}

public enum DefaultError: Error {
    case message(String)
}

public func print(string: String) {
    Swift.print(string)
}

public extension Sequence where Element: AdditiveArithmetic {
    func sum() -> Element { reduce(.zero, +) }
}

public extension Sequence where Element: Numeric {
    func product() -> Element { reduce(1, *) }
}

public extension RangeReplaceableCollection where Self: StringProtocol {
    func paddingToLeft(upTo length: Int, using element: Element = " ") -> SubSequence {
        return repeatElement(element, count: Swift.max(0, length - count)) + suffix(Swift.max(count, count - length))
    }
}

public extension Array {
    subscript(safe range: Range<Index>) -> ArraySlice<Element>? {
        if range.endIndex > endIndex {
            if range.startIndex >= endIndex {
                return nil
            } else {
                return self[range.startIndex ..< endIndex]
            }
        } else {
            return self[range]
        }
    }
}

public class Ref<T> {
    public var val: T

    public init(_ val: T) {
        self.val = val
    }
}

public extension Ref where T: CustomStringConvertible {
    var description: String {
        return "\(val.description)"
    }
}

public struct Point {
    public var x: Int
    public var y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    public init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

extension Point: CustomStringConvertible {
    public var description: String {
        return "(\(x), \(y))"
    }
}

extension Point: Hashable {
    public static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}
