import Foundation
import Utils

// let input = try Utils.getInput(bundle: Bundle.module, file: "test")
let input = try Utils.getInput(bundle: Bundle.module)

func prepare() -> [(sensor: Point, beacon: Point)] {
    return input
        .components(separatedBy: "\n")
        .compactMap { line -> (sensor: Point, beacon: Point)? in
            if line == "" {
                return nil
            }

            let pattern = "Sensor at x=(-?[0-9]+), y=(-?[0-9]+): closest beacon is at x=(-?[0-9]+), y=(-?[0-9]+)"

            var sensorX: Int?
            var sensorY: Int?
            var beaconX: Int?
            var beaconY: Int?

            let regex = try? NSRegularExpression(pattern: pattern)
            guard let match = regex?.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.utf8.count)) else { return nil }

            if let range = Range(match.range(at: 1), in: line) {
                sensorX = Int(line[range])
            }
            if let range = Range(match.range(at: 2), in: line) {
                sensorY = Int(line[range])
            }
            if let range = Range(match.range(at: 3), in: line) {
                beaconX = Int(line[range])
            }
            if let range = Range(match.range(at: 4), in: line) {
                beaconY = Int(line[range])
            }

            return (sensor: Point(sensorX!, sensorY!), beacon: Point(beaconX!, beaconY!))
        }
}

let lines = run(part: "Input parsing", closure: prepare)

enum Position {
    case sensor
    case beacon
    case empty
    case noBeacon
}

extension Position: CustomStringConvertible {
    public var description: String {
        switch self {
        case .sensor:
            return "S"
        case .beacon:
            return "B"
        case .empty:
            return "."
        case .noBeacon:
            return "#"
        }
    }
}

func part1() -> Int {
    print(lines)
    var grid = [Point: Position]()

    var minX = Int.max
    var maxX = Int.min
    // var minY = Int.max
    // var maxY = Int.min

    // let row = 10
    let row = 2_000_000

    for line in lines {
        grid[line.sensor] = .sensor
        grid[line.beacon] = .beacon

        minX = min(minX, line.sensor.x, line.beacon.x)
        maxX = max(maxX, line.sensor.x, line.beacon.x)
        // minY = min(minY, line.sensor.y, line.beacon.y)
        // maxY = max(maxY, line.sensor.y, line.beacon.y)

        let dist = max(line.sensor.x, line.beacon.x) - min(line.sensor.x, line.beacon.x) +
            max(line.sensor.y, line.beacon.y) - min(line.sensor.y, line.beacon.y)

        for offsetY in -dist ... dist {
            let y = line.sensor.y + offsetY
            if y != row {
                continue
            }
            let remainder = dist - abs(offsetY)
            for offsetX in -remainder ... remainder {
                let point = Point(line.sensor.x + offsetX, line.sensor.y + offsetY)
                if grid[point] == nil {
                    grid[point] = .noBeacon
                    minX = min(minX, point.x, point.x)
                    maxX = max(maxX, point.x, point.x)
                    // minY = min(minY, point.y, point.y)
                    // maxY = max(maxY, point.y, point.y)
                }
            }
        }
    }

    var noBeaconCount = 0

    for xIndex in minX ... maxX {
        let point = Point(xIndex, row)
        let position = grid[point] ?? .empty
        if position == .noBeacon {
            noBeaconCount += 1
        }
    }

    // for labelIndex in 0 ..< 3 {
    //     print("   ", terminator: "")
    //     for xIndex in minX ... maxX {
    //         let label = String(xIndex).paddingToLeft(upTo: 3)
    //         print(label[labelIndex], terminator: "")
    //     }
    //     print("")
    // }
    // for yIndex in minY ... maxY {
    //     print(String(yIndex).paddingToLeft(upTo: 3), terminator: "")
    //     for xIndex in minX ... maxX {
    //         let point = Point(xIndex, yIndex)
    //         print(grid[point] ?? .empty, terminator: "")
    //     }
    //     print("")
    // }

    return noBeaconCount
}

_ = run(part: 1, closure: part1)

// func part2() -> Int {
//     return -1
// }

// _ = run(part: 2, closure: part2)
