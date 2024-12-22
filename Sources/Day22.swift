import ArgumentParser
import Algorithms
import Atomics
import Collections
import Foundation
import Parsing

struct PseudoRandom: IteratorProtocol, Sequence {
    var secretNumber: Int

    mutating func next() -> Int? {
        secretNumber ^= (secretNumber << 6)
        secretNumber %= 16777216
        secretNumber ^= (secretNumber >> 5)
        secretNumber %= 16777216
        secretNumber ^= (secretNumber << 11)
        secretNumber %= 16777216

        return secretNumber
    }
}

struct Price: IteratorProtocol, Sequence {
    var pseudoRandom: PseudoRandom
    var previous: Int

    init(pseudoRandom: PseudoRandom) {
        self.pseudoRandom = pseudoRandom
        self.previous = pseudoRandom.secretNumber
    }

    mutating func next() -> (Int, Int)? {
        guard let next = pseudoRandom.next() else { return nil }
        defer { previous = next }

        return (next % 10, (next % 10) - (previous % 10))
    }
}

struct Day22: ParsingCommand {
    static var parser: some Parser<Substring.UTF8View, [PseudoRandom]> {
        Many {
            Parse(PseudoRandom.init) {
                Int.parser()
            }
        } separator: {
            Whitespace(.vertical)
        }
    }

    func run() throws {
        let input = try parsed(file: "22.txt")

        do {
            let part1 = input.reduce(into: 0) { partialResult, i in
                partialResult += Array(i.dropFirst(1999).prefix(1))[0]
            }
            print("Part 1", part1)
        }

        do {
            let changes: Grid<(Int, Int)> = Grid(
                input.map(Price.init).flatMap { $0.prefix(2000) },
                size: .init(x: 2000, y: input.count)
            )

            struct Seq: Hashable {
                let _0, _1, _2, _3: Int
            }

            let s = Dictionary.init(
                grouping: product((0..<changes.size.y), (0..<(changes.size.x - 3))).map { y, x in
                    return (
                        Seq(
                            _0: changes[Coord(x: x, y: y)].1,
                            _1: changes[Coord(x: x + 1, y: y)].1,
                            _2: changes[Coord(x: x + 2, y: y)].1,
                            _3: changes[Coord(x: x + 3, y: y)].1
                        ),
                        Coord(x: x, y: y),
                        changes[Coord(x: x + 3, y: y)].0
                    )
                },
                by: \(Seq, Coord, Int).0
            )
            // sequence: [all appearances of this sequence in each row]
                .mapValues { (sequenceMatches: [(Seq, Coord, Int)]) in

                    // row: [all appearances of this sequence in the given row]
                    Dictionary(grouping: sequenceMatches, by: \.1.y)

                    // row: first appearince of sequence in given row -> number of bananas.
                        .mapValues { values in
                            values.min { a, b in a.1.x < b.1.x }!.2
                        }
                        .values
                        .reduce(0, +)
                }

            print("Part 2", s.values.max())

        }
    }
}
