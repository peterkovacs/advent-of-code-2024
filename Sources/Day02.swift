import Foundation
import ArgumentParser
import Parsing
import Algorithms

struct Day2: ParsingCommand {
    static var parser: some Parser<Substring.UTF8View, [[Int]]> {
        Parse {
            Many {
                Many(1...) {
                    Int.parser()
                } separator: {
                    Whitespace(.horizontal)
                } terminator: {
                    Peek { Whitespace(.vertical) }
                }
            } separator: {
                Whitespace(.vertical)
            } terminator: {
                Whitespace(.vertical)
                End()
            }
        }
    }

    func run() throws {
        let input = try parsed()

        let part1 = input.count(where: \.isSafe)
        print("Part 1", part1)

        let part2 = input.count(where: \.isSafeWithDampener)
        print("Part 2", part2)

    }
}

fileprivate extension Array where Element == Int {
    var isSafe: Bool {
        adjacentPairs().allSatisfy {
            $0.0 < $0.1 && $0.0 + 3 >= $0.1
        } || adjacentPairs().allSatisfy {
            $0.1 < $0.0 && $0.1 + 3 >= $0.0
        }
    }

    var isSafeWithDampener: Bool {
        guard !isSafe else { return true }

        for i in indices {
            var copy = self
            copy.remove(at: i)
            if copy.isSafe { return true }
        }

        return false
    }
}
