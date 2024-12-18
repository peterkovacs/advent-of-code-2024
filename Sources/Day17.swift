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

        mutating func execute() -> Bool {
            guard program.indices.contains(pc) else { return false }
            switch program[pc] {
            case 0:
                // The adv instruction (opcode 0) performs division. The numerator is the value in the A register.
                // The denominator is found by raising 2 to the power of the instruction's combo operand.
                // (So, an operand of 2 would divide A by 4 (2^2); an operand of 5 would divide A by 2^B.)
                // The result of the division operation is truncated to an integer and then written to the A register.
                let operand = Int(program[pc + 1])
                switch operand {
                case 0, 1, 2, 3:
//                    print("[pc:\(pc)] a = a >> \(String(operand, radix: 2))")
                    a = a >> operand
                case 4:
//                    print("[pc:\(pc)] a = a >> a")
                    a = a >> a

                case 5:
//                    print("[pc:\(pc)] a = a >> b")
                    a = a >> b
                case 6:
//                    print("[pc:\(pc)] a = a >> c")
                    a = a >> c
                default: fatalError()
                }
                pc += 2

            case 1:
                // The bxl instruction (opcode 1) calculates the bitwise XOR of register B and the
                // instruction's literal operand, then stores the result in register B.
                let operand = Int(program[pc + 1])
//                print("[pc:\(pc)] b = b ^ \(String(operand, radix: 2))")
                b = b ^ operand
                pc += 2


            case 2:
                // The bst instruction (opcode 2) calculates the value of its combo operand modulo 8
                // (thereby keeping only its lowest 3 bits), then writes that value to the B register.

                let operand = Int(program[pc + 1])
                switch operand {
                case 0, 1, 2, 3:
//                    print("[pc:\(pc)] b = \(String(operand, radix: 2))")
                    b = operand
                case 4:
//                    print("[pc:\(pc)] b = a & 111")
                    b = a & 7
                case 5:
//                    print("[pc:\(pc)] b = b & 111")
                    b = b & 7
                case 6:
//                    print("[pc:\(pc)] b = c & 111")
                    b = c & 7
                default: fatalError()
                }

                pc += 2
            case 3:
                // The jnz instruction (opcode 3) does nothing if the A register is 0.
                // However, if the A register is not zero, it jumps by setting the instruction pointer to
                // the value of its literal operand; if this instruction jumps, the instruction pointer
                // is not increased by 2 after this instruction.

//                print("[pc:\(pc)] if \(a) != 0, jump \(program[pc + 1])")

                if a == 0 { pc += 2 }
                else { pc = Int(program[pc + 1]) }

            case 4:
                // The bxc instruction (opcode 4) calculates the bitwise XOR of register B and register C,
                // then stores the result in register B. (For legacy reasons, this instruction reads an operand but ignores it.)
//                print("[pc:\(pc)] b = b ^ c")
                b = b ^ c
                pc += 2

            case 5:
                // The out instruction (opcode 5) calculates the value of its combo operand modulo 8,
                // then outputs that value. (If a program outputs multiple values, they are separated by commas.)

                let operand = Int(program[pc + 1])
                switch operand {
                case 0, 1, 2, 3:
//                    print("[pc:\(pc)] output \(String(operand, radix: 2)))")
                    output.append(operand)
                case 4:
//                    print("[pc:\(pc)] output a & 7: \(String(a & 7, radix: 2))")
                    output.append(a & 7)
                case 5:
//                    print("[pc:\(pc)] output b & 7: \(String(b & 7, radix: 2))")
                    output.append(b & 7)
                case 6:
//                    print("[pc:\(pc)] output c & 7: \(String(c & 7, radix: 2))")
                    output.append(c & 7)
                default : fatalError()
                }
                pc += 2

            case 6:
                let operand = Int(program[pc + 1])
                switch operand {
                case 0, 1, 2, 3:
//                    print("[pc:\(pc)] b = a >> \(String(operand, radix: 2))")
                    b = a >> operand
                case 4:
//                    print("[pc:\(pc)] b = a >> a")
                    b = a >> a

                case 5:
//                    print("[pc:\(pc)] b = a >> b")
                    b = a >> b
                case 6:
//                    print("[pc:\(pc)] b = a >> c")
                    b = a >> c
                default: fatalError()
                }
                pc += 2

            case 7:
                let operand = Int(program[pc + 1])
                switch operand {
                case 0, 1, 2, 3:
//                    print("[pc:\(pc)] c = a >> \(String(operand, radix: 2))")
                    c = a >> operand
                case 4:
//                    print("[pc:\(pc)] c = a >> a")
                    c = a >> a
                case 5:
//                    print("[pc:\(pc)] c = a >> b")
                    c = a >> b
                case 6:
//                    print("[pc:\(pc)] c = a >> c")
                    c = a >> c
                default: fatalError()
                }
                pc += 2

            default: fatalError()
            }

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

            for j in bits[i+2] {
                for k in bits[i+1] {
                nextA:
                    for l in bits[i] {
                        let aBits = j << 2 | k << 1 | l

                        let b = aBits ^ 0b010
                        var bits = bits

                        bits[i] = [l]
                        bits[i+1] = [k]
                        bits[i+2] = [j]

                        // given the value of b, we need to find an a such that
                        // c = a >> b
                        // (b ^ c) ^ 0b111 == output

                        let c = (output ^ 0b111) ^ b

                        assert( (b ^ c) ^ 0b111 == output )

                        // Check that bits can support this value of c, restricting future bits as appropriate.
                        for bit in (0..<3) {
                            let value = (c >> bit) & 1

                            guard bits[i + b + bit].contains(value) else {
                                continue nextA
                            }
                            bits[i + b + bit] = [(c >> bit) & 1]
                        }

                        if let result = find(i: i + 3, rest: rest.dropFirst(), bits: bits) {
                            results.append(result)
                        }

                    }
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
            assert(cpu.output.elementsEqual(input.program))
        }
        print("Part 2", part2)
    }

}
