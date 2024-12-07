import ArgumentParser
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
        let input = try parsed()

        let (p2input, p1input) = input.partitioned { (target, operands) in
            solve(target: target, operands: operands[1...], accumulator: operands[0])
        }

        let part1 = p1input
            .map(\.0)
            .reduce(0, +)

        print("Part 1", part1)

        let part2 = p2input
            .filter { (target, operands) in solve2(target: target, operands: operands[1...], accumulator: operands[0]) }
            .map(\.0)
            .reduce(0, +)

        print("Part 2", part1 + part2)

    }

    func solve(target: Int, operands: ArraySlice<Int>, accumulator: Int) -> Bool {
        guard !operands.isEmpty else { return accumulator == target }
        let nextOperands = operands[operands.index(after: operands.startIndex)...]

        let multiply = accumulator * operands[operands.startIndex]
        let add = accumulator + operands[operands.startIndex]

        if multiply <= target && solve(target: target, operands: nextOperands, accumulator: multiply) {
            return true
        } else if add <= target && solve(target: target, operands: nextOperands, accumulator: add) {
            return true
        } else {
            return false
        }
    }
    func solve2(target: Int, operands: ArraySlice<Int>, accumulator: Int) -> Bool {
        guard !operands.isEmpty else { return accumulator == target }
        let nextOperands = operands[operands.index(after: operands.startIndex)...]

        let multiply = accumulator * operands[operands.startIndex]
        let add = accumulator + operands[operands.startIndex]
        let concat = accumulator || operands[operands.startIndex]

        if multiply <= target && solve2(target: target, operands: nextOperands, accumulator: multiply) {
            return true
        } else if add <= target && solve2(target: target, operands: nextOperands, accumulator: add) {
            return true
        } else if concat <= target && solve2(target: target, operands: nextOperands, accumulator: concat) {
            return true
        } else {
            return false
        }
    }

}

infix operator ||
func || (lhs: Int, rhs: Int) -> Int {
    switch rhs {
    case 0..<10: return lhs * 10 + rhs
    case 10..<100: return lhs * 100 + rhs
    case 100..<1000: return lhs * 1000 + rhs
    case 1000..<10000: return lhs * 10000 + rhs
    case 10000..<100000: return lhs * 100000 + rhs
    case 100000..<1000000: return lhs * 1000000 + rhs
    default: fatalError("Invalid operand")
    }
}
