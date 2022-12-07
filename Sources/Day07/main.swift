import Foundation
import Utils

let input = try Utils.getInput(bundle: Bundle.module, file: "test")
// let input = try Utils.getInput(bundle: Bundle.module)

func prepare() -> [String] {
    return input
        .components(separatedBy: CharacterSet(charactersIn: "\n"))
        .compactMap { line -> String? in
            if line == "" {
                return nil
            }
            return line
        }
}

let lines = run(part: "Input parsing", closure: prepare)

enum FsObject {
    case file(Int)
    case dir([String: FsObject])
}

func part1() -> Int {
    var fs = [String: FsObject]()
    var currentDir = &fs
    for line in lines {
        let parts = line.components(separatedBy: CharacterSet(charactersIn: " "))
        if parts[0] == "$" {
            // cmd
            switch parts[1] {
            case "cd":
                switch parts[2] {
                case "/":
                    currentDir = fs
                case "..":
                    if case let .dir(dir) = currentDir[".."] {
                        currentDir = dir
                    }
                default:
                    if case let .dir(dir) = currentDir[parts[2]] {
                        currentDir = dir
                    }
                }
            case "ls":
                //
                break
            default:
                return -1
            }
        } else {
            // result
            if parts[0] == "dir" {
                // dir
                var newDir = [String: FsObject]()
                newDir[".."] = FsObject.dir(currentDir)
                currentDir[parts[1]] = FsObject.dir(newDir)
            } else {
                // file
                currentDir[parts[1]] = FsObject.file(Int(parts[0]) ?? -1)
            }
        }
    }
    return -1
}

_ = run(part: 1, closure: part1)

// func part2() -> Int {
//     return -1
// }

// _ = run(part: 2, closure: part2)
