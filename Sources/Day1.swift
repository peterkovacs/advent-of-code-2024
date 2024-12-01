import ArgumentParser
import Foundation
import Parsing

struct Day1: ParsableCommand {
    static var parser: some Parser<Substring, (Int, Int)> {
        Parse(input: Substring.self) {
            Int.parser()
            Skip {
                Whitespace()
            }
            Int.parser()
        }
    }


    func run() throws {
        let numbers = try input.map { try Self.parser.parse($0) }
        let first = numbers.map(\.0)
        let second = numbers.map(\.1)

        let part1 = zip(first.sorted(), second.sorted()).map { abs($0.0 - $0.1) }.reduce(0, +)
        print("Part 1", part1)

        let frequencies: [Int:Int] = second.reduce(into: [:]) { $0[$1, default: 0] += 1 }
        let part2 = first.map { $0 * frequencies[$0, default: 0] }.reduce(0, +)
        print("Part 2", part2)
    }
}
