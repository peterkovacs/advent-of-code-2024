import Algorithms
import ArgumentParser
import Parsing
import Foundation

struct Day17: ParsingCommand {
    static var parser: some Parser<Substring.UTF8View, CPU> {
        Parse {
            CPU(a: $0.0, b: $0.1, c: $0.2, program: $0.3, pc: 0)
        } with: {
            "Register A: ".utf8
            Int.parser()
            Whitespace(.vertical)

            "Register B: ".utf8
            Int.parser()
            Whitespace(.vertical)

            "Register C: ".utf8
            Int.parser()
            Whitespace(.vertical)

            "Program: ".utf8
            Many { Int.parser() } separator: { ",".utf8 } terminator: { End() }
        }
    }

    struct CPU {
        var a: Int
        var b: Int
        var c: Int
        var program: [Int]
        var pc: Int
        var output: [Int] = []

        @inlinable func combo(_ operand: Int) -> Int {
            switch operand {
            case 0, 1, 2, 3: operand
            case 4: a
            case 5: b
            case 6: c
            default: fatalError()
            }
        }

        mutating func execute() -> Bool {
            guard program.indices.contains(pc) else { return false }
            switch program[pc] {
            case 0: a >>= combo(program[pc + 1])
            case 1: b = b ^ program[pc + 1]
            case 2: b = combo(program[pc + 1]) & 7
            case 3:
                pc = (a == 0) ? pc + 2 : program[pc + 1]
                return true
            case 4: b = b ^ c
            case 5: output.append(combo(program[pc + 1]) & 7)
            case 6: b = a >> combo(program[pc + 1])
            case 7: c = a >> combo(program[pc + 1])
            default: fatalError()
            }

            pc += 2
            return true
        }
    }

    func run() throws {
        let input = try parsed(file: "17.txt")

        do {
            var cpu = input
            while cpu.execute() {}
            print("Part 1", cpu.output.map { String($0) }.joined(separator: ","))
        }


        func find(i: Int, rest: some Collection<Int>, bits: [[Int]]) -> Int? {
            guard let output = rest.first else {
                return (0..<64).map { bits[$0][0] << $0 }.reduce(0, |)
            }

            var results: [Int] = []

            for (j, (k, l)) in product(bits[i+2], product(bits[i+1], bits[i])) {
                let a = j << 2 | k << 1 | l
                let b = a ^ 0b010

                var bits = bits

                // set bits of our chosen a value
                bits[i] = [l]
                bits[i+1] = [k]
                bits[i+2] = [j]

                // given the value of b, we need to find an a such that
                // c = a >> b
                // (b ^ c) ^ 0b111 == output

                let c = (output ^ 0b111) ^ b
                assert( (b ^ c) ^ 0b111 == output )

                // Check that bits can support this value of c
                guard (0..<3).allSatisfy({ bits[i + b + $0].contains((c >> $0) & 1) }) else { continue }

                // restricting future bits as appropriate
                bits[i + b] = [c & 1]
                bits[i + b + 1] = [(c >> 1) & 1]
                bits[i + b + 2] = [(c >> 2) & 1]

                if let result = find(i: i + 3, rest: rest.dropFirst(), bits: bits) {
                    results.append(result)
                }
            }

            return results.min()
        }

        let part2 = find(i: 0, rest: input.program, bits: (0..<64).map { _ in [0, 1] })
        guard let part2 else { return }

        // Sanity Check
        do {
            var cpu = input
            cpu.a = part2
            while cpu.execute() {}
            guard cpu.output.elementsEqual(input.program) else { fatalError() }
        }
        print("Part 2", part2)
    }

}
