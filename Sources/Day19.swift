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

        let part1 = LockIsolated([Bool](repeating: false, count: desired.count))
        DispatchQueue.concurrentPerform(iterations: desired.count) { i in
            let pattern = desired[i]
            var cache = [[UInt8]:Bool]()
            let result = isPossible(pattern: pattern, cache: &cache, patterns: patterns)
            part1.withLock {
                $0[i] = result
            }
        }

        let possiblePatterns = part1.withLock {
            zip(desired, $0).filter(\.1).map(\.0)
        }
        print("Part 1", possiblePatterns.count)

        let part2 = ManagedAtomic(0)

        DispatchQueue.concurrentPerform(iterations: possiblePatterns.count) {
            var cache = [[UInt8]:Int]()
            let count = count(pattern: possiblePatterns[$0], cache: &cache, patterns: patterns)
            part2.wrappingIncrement(by: count, ordering: .relaxed)
        }

        print("Part 2", part2.load(ordering: .relaxed))
    }
}

final class LockIsolated<Value>: @unchecked Sendable {
  private var _value: Value
  private let lock = NSRecursiveLock()
  init(_ value: @autoclosure @Sendable () throws -> Value) rethrows {
    self._value = try value()
  }
  func withLock<T: Sendable>(
    _ operation: @Sendable (inout Value) throws -> T
  ) rethrows -> T {
    lock.lock()
    defer { lock.unlock() }
    var value = _value
    defer { _value = value }
    return try operation(&value)
  }
}
