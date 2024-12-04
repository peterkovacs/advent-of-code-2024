import ArgumentParser
import CasePaths
import Foundation
import Parsing

struct Day3: ParsingCommand {
    @CasePathable
    enum Input {
        case `do`, `dont`, mul(Int, Int)
    }
    
    static var parser: some Parser<Substring.UTF8View, [Input]> {
        Many(into: [Input]()) { (input: inout [Input], result: Input?) in
            if let result { input.append(result) }
        } element: {
            OneOf {
                OneOf {
                    Parse(Input.mul) {
                        "mul(".utf8
                        Int.parser()
                        ",".utf8
                        Int.parser()
                        ")".utf8
                    }
                    Parse(Input.do) { "do()".utf8 }
                    Parse(Input.dont) { "don't()".utf8 }
                }.map { $0 as Input? }
                Skip { First() }.map { _ in nil }
            }
        } terminator: {
            End()
        }
    }

    func run() throws {
        let input = try parsed()
        let part1 = input
            .compactMap { $0[case: \Input.Cases.mul] }
            .map { $0 * $1 }
            .reduce(0, +)
        print("Part 1", part1)

        let part2 = input
            .reduce(into: (Input.do, 0)) { (state, i) in
                switch (state.0, i) {
                case (.do, .mul(let a, let b)): state.1 += a * b
                case (.do, .dont): state.0 = .dont
                case (.dont, .do): state.0 = .do
                default: break
                }
            }
            .1
        print("Part 2", part2)
    }
}
