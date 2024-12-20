import ArgumentParser
import Atomics
import Dispatch
import Parsing

struct Day7: ParsingCommand {
    static var parser: some Parser<Substring.UTF8View, [(Int, [Int])]> {
        Many(1...) {
            Int.parser()
            ": ".utf8
            Many { Int.parser() } separator: { Whitespace(1..., .horizontal) }
        } separator: {
            Whitespace(1, .vertical)
        }
    }

    func run() throws {
        let input = try parsed(file: "07.txt")

        let (p2input, p1input) = input.partitioned { (target, operands) in
            solve(target: target, operands: operands[...].reversed())
        }

        let part1 = p1input
            .map(\.0)
            .reduce(0, +)

        print("Part 1", part1)

        let part2 = ManagedAtomic<Int>(0)

        DispatchQueue.concurrentPerform(iterations: p2input.count) { index in
            let (target, operands) = p2input[index]
            if solveWithConcatenation(target: target, operands: operands[...].reversed()) {
                part2.wrappingIncrement(by: target, ordering: .relaxed)
            }
        }

        print("Part 2", part1 + part2.load(ordering: .relaxed))
    }

    func solve(target: Int, operands: some RandomAccessCollection<Int>) -> Bool {
        guard let operand = operands.first else { return target == 0 }
        let nextOperands = operands[operands.index(after: operands.startIndex)...]

        if (target % operand) == 0 && solve(target: target / operand, operands: nextOperands) {
            return true
        } else if (target - operand) >= 0 && solve(target: target - operand, operands: nextOperands) {
            return true
        } else { return false }
    }

    func solveWithConcatenation(target: Int, operands: some RandomAccessCollection<Int>) -> Bool {
        guard let operand = operands.first else { return target == 0 }
        let nextOperands = operands[operands.index(after: operands.startIndex)...]

        if (target % operand) == 0 && solveWithConcatenation(target: target / operand, operands: nextOperands) {
            return true
        } else if (target - operand) >= 0 && solveWithConcatenation(target: target - operand, operands: nextOperands) {
            return true
        } else if target > operand {
            let magnitude = Int(
                pow(
                    10,
                    ((log2(Double(operand)) / log2(10.0)) + 0.00001).rounded(.awayFromZero)
                )
            )

            return (target % magnitude) == operand && solveWithConcatenation(target: target / magnitude, operands: nextOperands)
        } else {
            return false
        }
    }
}
