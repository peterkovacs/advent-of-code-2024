import Foundation
import Parsing

struct Day5: ParsingCommand {
    static var parser: some Parser<Substring.UTF8View, ([(Int, Int)], [[Int]])> {
        Many(1...) {
            Int.parser()
            "|".utf8
            Int.parser()
        } separator: {
            Whitespace(1, .vertical)
        } terminator: {
            Whitespace(2, .vertical)
        }

        Many(1...) {
            Many(1...) {
                Int.parser()
            } separator: {
                ",".utf8
            } terminator: {
                Whitespace(1, .vertical)
            }
        } terminator: {
            End()
        }
    }

    func run() throws {
        let (rules, order) = try parsed()
        let dependencies = rules.reduce(into: [Int: Set<Int>]()) {
            $0[$1.1, default: .init()].insert($1.0)
        }

        let (incorrect, correct) = order.partitioned {
            $0.isOrderedBy(rules: dependencies)
        }

        let part1 = correct
            .map(\.mid)
            .reduce(0, +)

        print("Part 1", part1)

        let part2 = incorrect.map {
            var i = $0
            i.fixOrder(rules: dependencies)
            return i.mid
        }
        .reduce(0, +)
        print("Part 2", part2)
    }
}

extension Array where Element == Int {
    func isOrderedBy(rules: [Int: Set<Int>]) -> Bool {
        let specificRules = rules.mapValues { $0.intersection(self) }
        var printed: Set<Int> = .init()

        for i in indices {
            let dependencies = specificRules[self[i], default: .init()]
            guard dependencies.isSubset(of: printed) else {
                return false
            }
            printed.insert(self[i])
        }

        return true
    }

    mutating func fixOrder(rules: [Int: Set<Int>]) {
        let specificRules = rules.mapValues { $0.intersection(self) }
        var printed: Set<Int> = .init()

        for var i in indices {
            printed.insert(self[i])

            let dependencies = specificRules[self[i], default: .init()]
            var notYetPrinted = Array(dependencies.subtracting(printed))
            notYetPrinted.fixOrder(rules: rules)
            insert(contentsOf: notYetPrinted, at: i)
            printed.formUnion(notYetPrinted)
            i = i.advanced(by: notYetPrinted.count)
            self[i...].removeAll(where: { notYetPrinted.contains($0) })
        }
    }

    var mid: Element {
        return self[self.count / 2]
    }
}
