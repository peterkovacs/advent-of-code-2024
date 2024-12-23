import ArgumentParser
import Algorithms
import Atomics
import Collections
import Foundation
import Parsing

struct PRNG: IteratorProtocol, Sequence {
    var seed: Int

    mutating func next() -> Int? {
        seed ^= (seed << 6)
        seed %= 16777216
        seed ^= (seed >> 5)
        seed %= 16777216
        seed ^= (seed << 11)
        seed %= 16777216

        return seed
    }
}

struct Price: IteratorProtocol, Sequence {
    var rng: PRNG
    var previous: (Int, Int, Int, Int, Int)

    init(_ rng: PRNG) {
        self.rng = rng
        self.previous = (
            rng.seed,
            self.rng.next()!,
            self.rng.next()!,
            self.rng.next()!,
            self.rng.next()!
        )
    }

    // Returns Sequence of diffs
    mutating func next() -> (Int, Int, Int)? {
        guard let next = rng.next() else { return nil }
        defer { previous = (previous.1, previous.2, previous.3, previous.4, next) }

        return (
            (((10 + (previous.1 % 10) - (previous.0 % 10)) << 24) & 0x0000ff000000) |
            (((10 + (previous.2 % 10) - (previous.1 % 10)) << 16) & 0x000000ff0000) |
            (((10 + (previous.3 % 10) - (previous.2 % 10)) <<  8) & 0x00000000ff00) |
             ((10 + (previous.4 % 10) - (previous.3 % 10))        & 0x0000000000ff),
            previous.4 % 10,
            previous.4
        )
    }
}

struct Day22: ParsingCommand {
    @Argument var file = "22.txt"
    static var parser: some Parser<Substring.UTF8View, [PRNG]> {
        Many {
            Parse(PRNG.init) {
                Int.parser()
            }
        } separator: {
            Whitespace(.vertical)
        }
    }

    func run() throws {
        let input = try parsed(file: file)

        let sequences = Grid<(Int, Int, Int)>(
            input.map(Price.init).flatMap { $0.prefix(2000-3) },
            size: .init(x: 2000-3, y: input.count)
        )

        do {
            let part1 = sequences.column(2000-4).map(\.2).reduce(0, +)
            print("Part 1", part1)
        }

        do {
            typealias Seq = Int
            typealias Y = Int
            typealias X = Int

            var result = [Seq: Int]()
            for y in 0..<sequences.size.y {

                // use the fact that we're iterating in increasing X order
                // so we can throw away the set of seen sequences after processing
                var seen: Set<Seq> = []
                seen.reserveCapacity(sequences.size.x)

                for x in 0..<sequences.size.x {
                    let (sequence, bananas, _) = sequences[.init(x: x, y: y)]

                    if seen.insert(sequence).inserted {
                        // if this is the first time we've seen this sequence for this monkey,
                        // we can add our bananas to the sequence total.
                        result[sequence, default: 0] += bananas
                    }
                }
            }

            let part2 = result
                .values
                .max()

            print("Part 2", part2!)
        }
    }
}

//extension Collection where Self: Sendable {
//    public func concurrentlyReduce(_ initialResult: Int, _ nextPartialResult: @Sendable (ManagedAtomic<Int>, Element) -> ()) -> Int {
//        let partialResult = ManagedAtomic(initialResult)
//        DispatchQueue.concurrentPerform(iterations: count) { index in
//            nextPartialResult(partialResult, self[self.index(self.startIndex, offsetBy: index)])
//        }
//        return partialResult.load(ordering: .relaxed)
//    }
//}
