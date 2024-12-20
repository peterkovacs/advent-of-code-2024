import ArgumentParser
import Foundation
import Parsing

struct Day11: ParsingCommand {
    @Argument var file: String = "11.txt"

    static var parser: some Parser<Substring.UTF8View, [Int]> {
        Many { Int.parser(of: Substring.UTF8View.self) }
        separator: { Whitespace() }
        terminator: {
            Whitespace()
            End()
        }
    }

    func run() throws {
        let input = try parsed(file: file).reduce(into: [Int:Int]()) { partialResult, i in
            partialResult[i, default: 0] += 1
        }

        func iteration(partialResult: inout [Int: Int], i: (key: Int, value: Int)) {
            if i.key == 0 { partialResult[1, default: 0] += i.value }
            else if i.key.digits % 2 == 0 {
                let (l, r) = i.key.split
                partialResult[l, default: 0] += i.value
                partialResult[r, default: 0] += i.value
            } else {
                partialResult[i.key * 2024, default: 0] += i.value
            }
        }

        let part1 = (0..<25).reduce(into: input) { input, _ in
            input = input.reduce(into: [Int:Int](), iteration)
        }

        print("Part 1", part1.map(\.value).reduce(0, +))


        let part2 = (25..<75).reduce(into: part1) { input, i in
            input = input.reduce(into: [Int:Int](), iteration)
        }

        print("Part 2", part2.map(\.value).reduce(0, +))
    }
}

fileprivate extension Int {
    var digits: Int {
        return Int(log10(Double(self + 1)).rounded(.awayFromZero))
    }

    var split: (Int, Int) {
        let digits = self.digits
        let factor = Int(pow(10, Double(digits / 2)).rounded())
        let left = self / factor
        let right = self % factor
        return (left, right)
    }
}
