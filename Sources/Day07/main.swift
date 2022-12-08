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
    case dir([String: Ref<FsObject>])
}

func part1() -> Int {
    let fs = Ref(FsObject.dir([String: Ref<FsObject>]()))
    var currentDir = fs
    for line in lines {
        print("line: \(line)")
        let parts = line.components(separatedBy: CharacterSet(charactersIn: " "))
        if parts[0] == "$" {
            // cmd
            switch parts[1] {
            case "cd":
                switch parts[2] {
                case "/":
                    currentDir = fs
                case "..":
                    if case let .dir(dir) = currentDir.val {
                        currentDir = dir[".."]!
                    }
                default:
                    if case let .dir(dir) = currentDir.val {
                        currentDir = dir[parts[2]]!
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
                var newDir = [String: Ref<FsObject>]()
                newDir[".."] = currentDir
                if case var .dir(dir) = currentDir.val {
                    dir[parts[1]] = Ref(FsObject.dir(newDir))
                    currentDir = Ref(FsObject.dir(dir))
                }
            } else {
                // file
                if case var .dir(dir) = currentDir.val {
                    dir[parts[1]] = Ref(FsObject.file(Int(parts[0]) ?? -1))
                    currentDir = Ref(FsObject.dir(dir))
                }
            }
        }
        print(fs: fs)
        print()
        print()
    }
    return -1
}

func print(fs: Ref<FsObject>, indent: String = "") {
    if case let .dir(dir) = fs.val {
        for (name, fsObject) in dir {
            switch fsObject.val {
            case .dir:
                if name == ".." {
                    continue
                }
                print("\(indent)\(name)")
                print(fs: fsObject, indent: "\(indent)  ")
            case let .file(size):
                print("\(indent)\(name) \(size)")
            }
        }
    }
}

_ = run(part: 1, closure: part1)

// func part2() -> Int {
//     return -1
// }

// _ = run(part: 2, closure: part2)
