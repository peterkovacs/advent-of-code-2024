import ArgumentParser
import Foundation
import Parsing


struct Day1: ParsingCommand {
    static var parser: some Parser<Substring.UTF8View, [(Int, Int)]> {
        Parse(input: Substring.UTF8View.self) {
            Many {
                Int.parser()
                Whitespace(.horizontal)
                Int.parser()
            } separator: {
                Whitespace(.vertical)
            } terminator: {
                Whitespace(.vertical)
            }
        }
    }


    func run() throws {
        let numbers = try parsed()
        let first = numbers.map(\.0)
        let second = numbers.map(\.1)

        let part1 = zip(first.sorted(), second.sorted()).map { abs($0.0 - $0.1) }.reduce(0, +)
        print("Part 1", part1)

        let frequencies: [Int:Int] = second.reduce(into: [:]) { $0[$1, default: 0] += 1 }
        let part2 = first.map { $0 * frequencies[$0, default: 0] }.reduce(0, +)
        print("Part 2", part2)
    }
}
