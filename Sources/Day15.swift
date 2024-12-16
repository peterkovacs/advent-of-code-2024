import ArgumentParser
import Foundation
import Parsing

struct Day15: ParsingCommand {
    @Argument var file: String = "15.txt"

    static var parser: some Parser<Substring.UTF8View, (Grid<Character>, [KeyPath<Coord, Coord>])> {
        Parse {
            Grid($0.joined(), size: .init(x: $0[0].count, y: $0.count))
        } with: {
            Many(1..., into: [String]()) {
                $0.append(String($1) ?? "")
            } element: {
                Prefix(1...) { $0 != 0xa }
            } separator: {
                Whitespace(1, .vertical)
            } terminator: {
                Whitespace(2, .vertical)
            }
        }

        Many(1..., into: [KeyPath<Coord, Coord>]()) {
            $0.append(contentsOf: $1)
        } element: {
            Many {
                OneOf {
                    "^".utf8.map { \Coord.up }
                    ">".utf8.map { \Coord.right }
                    "v".utf8.map { \Coord.down }
                    "<".utf8.map { \Coord.left }
                }
            }
        } separator: {
            Whitespace(1, .vertical)
        } terminator: {
            End()
        }
    }

    func run() throws {
        let (grid, directions) = try parsed(file: file)

        do {
            var grid = grid
            var robot = grid.indices.first { grid[$0] == "@" }!

            directions.forEach {
                if grid.move(from: robot, direction: $0) {
                    robot = robot[keyPath: $0]
                }
            }

            print("Part 1", grid.indices.filter { grid[$0] == "O" }.map { $0.y * 100 + $0.x }.reduce(0, +) )
        }

        do {
            var grid = Grid(
                grid.flatMap {
                    switch $0 {
                    case "#": return ["#", "#" as Character]
                    case "O": return ["[", "]"]
                    case ".": return [".", "."]
                    case "@": return ["@", "."]
                    default: fatalError()
                    }
                },
                size: .init(x: grid.size.x * 2, y: grid.size.y)
            )

            var robot = grid.indices.first { grid[$0] == "@" }!

            directions.forEach {
                let moved = switch $0 {
                case \.up, \.down:
                    grid.moveVertical(from: [robot], direction: $0)
                case \.left, \.right:
                    grid.move(from: robot, direction: $0)
                default: false
                }

                if moved {
                    robot = robot[keyPath: $0]
                }
            }

            let part2 = grid.indices
                .filter { grid[$0] == "[" }
                .map { $0.y * 100 + $0.x }
                .reduce(0, +)
            print("Part 2", part2 )
        }
    }
}

fileprivate extension Grid where Element == Character {
    mutating func move(from: Coord, direction: KeyPath<Coord, Coord>) -> Bool {
        let newCoord = from[keyPath: direction]
        switch self[newCoord] {
        case "#": return false
        case ".":
            swapAt(from, newCoord)
            return true
        case "O", "[", "]":
            if move(from: newCoord, direction: direction) {
                swapAt(from, newCoord)
                return true
            } else {
                return false
            }
        default: fatalError("Unknown character \(self[newCoord])")
        }
    }

    mutating func moveVertical(from: Set<Coord>, direction: KeyPath<Coord, Coord>) -> Bool {
        let newCoords = Set(from.map { $0[keyPath: direction] })

        if newCoords.contains(where: { self[$0] == "#" }) {
            return false
        }

        if newCoords.allSatisfy({ self[$0] == "." }) {
            from.forEach { swapAt($0, $0[keyPath: direction]) }
            return true
        }

        var pushing = Set<Coord>()

        for c in newCoords {
            switch (self[c], direction) {
            case ("[", \.up), ("[", \.down):
                pushing.insert(c)
                pushing.insert(c.right)
            case ("]", \.up), ("]", \.down):
                pushing.insert(c)
                pushing.insert(c.left)
            default: break
            }
        }

        if moveVertical(from: pushing, direction: direction) {
            from.forEach { swapAt($0, $0[keyPath: direction]) }
            return true
        } else {
            return false
        }
    }
}
