import ArgumentParser
import Parsing
import Foundation

struct Day24: ParsingCommand {
    @Argument var file = "24.txt"

    enum Op {
        case and, or, xor

        func callAsFunction(_ a: Bool, _ b: Bool) -> Bool {
            switch self {
            case .and: return a && b
            case .or: return a || b
            case .xor: return (a || b) && !(a && b)
            }
        }
    }

    static var parser: some Parser<Substring.UTF8View, ([String: Bool], [(String, Op, String, String)])> {
        Many(into: [String: Bool]()) { partialResult, output in
            partialResult[output.0] = output.1
        } element: {
            PrefixUpTo(":".utf8).map { String($0)! }
            ": ".utf8
            Int.parser().map { $0 == 1 ? true : false }
        } separator: {
            Whitespace(1, .vertical)
        } terminator: {
            Whitespace(2, .vertical)
        }

        Many {
            Parse {
                $0 < $2 ? ($0, $1, $2, $3) : ($2, $1, $0, $3)
            } with: {
                Prefix(3).map { String($0)! }

                OneOf {
                    " XOR ".utf8.map { Op.xor }
                    " OR ".utf8.map { .or }
                    " AND ".utf8.map { .and }
                }

                Prefix(3).map { String($0)! }
                " -> ".utf8
                Prefix(3).map { String($0)! }
            }
        } separator: {
            Whitespace(1, .vertical)
        } terminator: {
            End()
        }
    }

    func evaluate(for output: String, values: inout [String: (Bool, Set<String>)], gates: [String: (String, String, Op)]) -> (Bool, Set<String>) {
        if let value = values[output] {
            return value
        }

        if let (a, b, gate) = gates[output] {

            let (aValue, aGates) = evaluate(for: a, values: &values, gates: gates)
            let (bValue, bGates) = evaluate(for: b, values: &values, gates: gates)

            let result = (gate(aValue, bValue), aGates.union(bGates).union([a, b]))

            values[output] = result
            return result
        } else {
            return (false, Set<String>())
        }
    }

    func run() throws {
        let (values, gates) = try parsed(file: file)


        do {
            var values = values.mapValues { ($0, Set<String>()) }
            let gates = gates.reduce(into: [String: (String, String, Op)]()) {
                $0[$1.3] = ($1.0, $1.2, $1.1)
            }

            let part1 = gates
                .keys
                .filter { $0.first == "z" }
                .sorted()
                .reversed()
                .reduce(into: 0) { partialResult, i in
                    partialResult <<= 1
                    if evaluate(for: i, values: &values, gates: gates).0 {
                        partialResult |= 1
                    }
                }

            print("Part 1", part1)
        }

        do {
            struct Gate: Hashable {
                let input: String
                let op: Op
            }
            let gates = gates.reduce(into: [Gate:(String, String)]()) {
                $0[.init(input: $1.0, op: $1.1)] = ($1.2, $1.3)
                $0[.init(input: $1.2, op: $1.1)] = ($1.0, $1.3)
            }

            var Cin = "ktt"
            var bad = Set<String>()
            for i in 1...44 {
                let Xin = String(format: "x%02d", i)
                let Zout = String(format: "z%02d", i)
                let (Yin, A) = gates[.init(input: Xin, op: .xor)]!

                let B: String
                do {
                    if let BXOR = gates[.init(input: A, op: .xor)] {
                        let (Cinʹ, Bʹ) = BXOR
                        B = Bʹ

                        // We can check that Cin is correct as it should be conencted to this output.
                        if Cin != Cinʹ {
                            print("\(Cin) should have been connected to B, but \(Cinʹ) was instead")
                            bad.insert(Cin)
                            bad.insert(Cinʹ)
                        }
                    } else if let BXOR = gates[.init(input: Cin, op: .xor)] {
                        let (Aʹ, Bʹ) = BXOR
                        B = Bʹ

                        print("\(A) should have been an input to \(Aʹ) was instead")
                        bad.insert(A)
                        bad.insert(Aʹ)
                    } else {
                        fatalError()
                    }
                }

                if B != Zout {
                    print("\(B) should have been \(Zout)")
                    bad.insert(B)
                }

                let C: String
                do {
                    if let CAND = gates[.init(input: A, op: .and)] {
                        let (Cinʹ, Cʹ) = CAND
                        C = Cʹ

                        if Cin != CAND.0 {
                            print("\(Cin) should have been connected to C, but \(Cinʹ) was instead")
                            bad.insert(Cin)
                        }
                    } else if let CAND = gates[.init(input: Cin, op: .and)] {
                        let (Aʹ, Cʹ) = CAND
                        C = Cʹ

                        print("\(A) should have been an input to C, but \(Aʹ) was instead")
                        bad.insert(A)
                    } else {
                        fatalError()
                    }
                }

                let (Din, D) = gates[.init(input: Xin, op: .and)]!
                assert(Din == Yin)

                let E: String
                do {
                    if let EOR = gates[.init(input: D, op: .or)] {
                        let (Cʹ, Eʹ) = EOR
                        E = Eʹ

                        if C != Cʹ {
                            print("\(C) should have been connected to E, but \(Cʹ) was instead")
                            bad.insert(C)
                        }
                    } else if let EOR = gates[.init(input: C, op: .or)] {
                        let (Dʹ, Eʹ) = EOR
                        E = Eʹ
                        print("\(D) should have been an input to E, but \(Dʹ) was instead")
                        bad.insert(D)
                    } else {
                        fatalError()
                    }
                }

                Cin = E
            }

            print("Part 2", bad.sorted().joined(separator: ","))
        }
    }
}
