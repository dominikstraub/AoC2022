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
    // print(lines)
    var grid = [Point: Position]()

    var minX = Int.max
    var maxX = Int.min
    // var minY = Int.max
    // var maxY = Int.min

    // let row = 10
    let row = 2_000_000

    for (sensor, beacon) in lines {
        grid[sensor] = .sensor
        grid[beacon] = .beacon

        minX = min(minX, sensor.x, beacon.x)
        maxX = max(maxX, sensor.x, beacon.x)
        // minY = min(minY, sensor.y, beacon.y)
        // maxY = max(maxY, sensor.y, beacon.y)

        let dist = max(sensor.x, beacon.x) - min(sensor.x, beacon.x) +
            max(sensor.y, beacon.y) - min(sensor.y, beacon.y)

        for offsetY in -dist ... dist {
            let y = sensor.y + offsetY
            if y != row {
                continue
            }
            let remainder = dist - abs(offsetY)
            for offsetX in -remainder ... remainder {
                let point = Point(sensor.x + offsetX, sensor.y + offsetY)
                if grid[point] == nil {
                    grid[point] = .noBeacon
                    minX = min(minX, point.x)
                    maxX = max(maxX, point.x)
                    // minY = min(minY, point.y)
                    // maxY = max(maxY, point.y)
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

func part2() -> Int {
    let minX = 0
    // let maxX = 20
    let maxX = 4_000_000
    let minY = 0
    // let maxY = 20
    let maxY = 4_000_000

    for (sensor, beacon) in lines {
        let sensorRange = max(sensor.x, beacon.x) - min(sensor.x, beacon.x) +
            max(sensor.y, beacon.y) - min(sensor.y, beacon.y)

        search: for offsetX in 0 ... sensorRange + 1 {
            let offsetY = sensorRange + 1 - offsetX
            let x = sensor.x + offsetX
            let y = sensor.y + offsetY
            if x < minX || x > maxX || y < minY || y > maxY {
                continue
            }

            for (sensor2, beacon2) in lines {
                let sensor2Range = max(sensor2.x, beacon2.x) - min(sensor2.x, beacon2.x) +
                    max(sensor2.y, beacon2.y) - min(sensor2.y, beacon2.y)

                let dist = max(x, sensor2.x) - min(x, sensor2.x) +
                    max(y, sensor2.y) - min(y, sensor2.y)

                if dist <= sensor2Range {
                    continue search
                }
            }
            return x * 4_000_000 + y
        }
    }

    return -1
}

_ = run(part: 2, closure: part2)
