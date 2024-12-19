import ArgumentParser
import Atomics
import Foundation
import Parsing

struct Day19: ParsingCommand {
    static var parser: some Parser<Substring.UTF8View, ([[UInt8]], [[UInt8]])> {
        Many {
            Prefix { $0 != 0x2c && $0 != 0x0a }.map { Array($0) }
        } separator: {
            ", ".utf8
        } terminator: {
            Whitespace(2, .vertical)
        }

        Many {
            Prefix { $0 != 0x0a }.map { Array($0) }
        } separator: {
            Whitespace(1, .vertical)
        } terminator: {
            End()
        }
    }

    func isPossible(pattern: some Collection<UInt8>, cache: inout [[UInt8]:Bool], patterns: [[UInt8]]) -> Bool {
        guard !pattern.isEmpty else { return true }
        if let cached = cache[Array(pattern)] { return cached }

        let matchingPatterns = patterns
            .filter { pattern.starts(with: $0) }

        for p in matchingPatterns {
            if isPossible(pattern: pattern.dropFirst(p.count), cache: &cache, patterns: patterns) {
                cache[Array(pattern)] = true
                return true
            } else {
                cache[Array(pattern)] = false
            }
        }

        return false
    }

    func count(pattern: some Collection<UInt8>, cache: inout [[UInt8]:Int], patterns: [[UInt8]]) -> Int {
        guard !pattern.isEmpty else { return 1 }
        if let cached = cache[Array(pattern)] { return cached }

        let matchingPatterns = patterns
            .filter { pattern.starts(with: $0) }

        var result = 0
        for p in matchingPatterns {
            result += count(pattern: pattern.dropFirst(p.count), cache: &cache, patterns: patterns)
        }

        cache[Array(pattern)] = result
        return result
    }

    func run() throws {
        let (patterns, desired) = try parsed(file: "19.txt")

        var cache = [Array<UInt8>:Bool]()
        let possiblePatterns = desired.filter {
            isPossible(pattern: $0, cache: &cache, patterns: patterns)
        }

        print("Part 1", possiblePatterns.count)

        do {
            var cache = [[UInt8]:Int]()
            let part2 = possiblePatterns.reduce(0) { $0 + count(pattern: $1, cache: &cache, patterns: patterns) }

            print("Part 2", part2)
        }
    }
}
