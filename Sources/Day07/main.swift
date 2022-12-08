import Foundation
import Utils

// let input = try Utils.getInput(bundle: Bundle.module, file: "test")
let input = try Utils.getInput(bundle: Bundle.module)

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

class FsObject: CustomStringConvertible {
    var fileSize: Int?
    var name: String
    var subObjects: [String: FsObject]?
    var type: FsObjectType
    var parent: FsObject?

    var size: Int {
        if case .file = type, let fileSize {
            return fileSize
        } else if case .dir = type, let subObjects {
            return subObjects.map { $0.value.size }.sum()
        } else {
            return -1
        }
    }

    var description: String {
        return toString()
    }

    var totalSizeLessThanMaxSizeWithSugarOnTop: Int {
        var totalSize = 0
        if case .dir = type {
            if size <= 100_000 {
                totalSize += size
            }
            for (_, fsObject) in subObjects! {
                totalSize += fsObject.totalSizeLessThanMaxSizeWithSugarOnTop
            }
        }
        return totalSize
    }

    init(name: String, fileSize: Int) {
        self.name = name
        self.fileSize = fileSize
        type = FsObjectType.file
    }

    init(name: String, subObjects: [String: FsObject] = [String: FsObject]()) {
        self.name = name
        self.subObjects = subObjects
        type = FsObjectType.dir
    }

    func toString(indent: String = "") -> String {
        var description = "\(indent)\(name) \(size)\n"
        switch type {
        case .dir:
            for (_, fsObject) in subObjects! {
                description += fsObject.toString(indent: "\(indent)  ")
            }
        case .file:
            break
        }
        return description
    }
}

enum FsObjectType {
    case file
    case dir
}

func part1() -> Int {
    let rootDir = FsObject(name: "/")
    var currentDir = rootDir
    for line in lines {
        print("line: \(line)")
        let parts = line.components(separatedBy: CharacterSet(charactersIn: " "))
        if parts[0] == "$" {
            // cmd
            switch parts[1] {
            case "cd":
                switch parts[2] {
                case "/":
                    currentDir = rootDir
                case "..":
                    currentDir = currentDir.parent!
                default:
                    currentDir = currentDir.subObjects![parts[2]]!
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
                let newDir = FsObject(name: parts[1])
                newDir.parent = currentDir
                currentDir.subObjects![parts[1]] = newDir
            } else {
                // file
                let newFile = FsObject(name: parts[1], fileSize: Int(parts[0]) ?? -1)
                currentDir.subObjects![parts[1]] = newFile
            }
        }
        print(rootDir)
        print()
        print()
    }
    return rootDir.totalSizeLessThanMaxSizeWithSugarOnTop
}

_ = run(part: 1, closure: part1)

// func part2() -> Int {
//     return -1
// }

// _ = run(part: 2, closure: part2)
