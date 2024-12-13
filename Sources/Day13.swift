import ArgumentParser
import Parsing

struct Day13: ParsingCommand {
    /*
     Button A: X+94, Y+34
     Button B: X+22, Y+67
     Prize: X=8400, Y=5400
     */
    static var parser: some Parser<Substring.UTF8View, [(Int, Int, Int, Int, Int, Int)]> {
        Many {
            "Button A: ".utf8
            "X+".utf8
            Int.parser()
            ", Y+".utf8
            Int.parser()
            Whitespace(1, .vertical)

            "Button B: ".utf8
            "X+".utf8
            Int.parser()
            ", Y+".utf8
            Int.parser()
            Whitespace(1, .vertical)

            "Prize: ".utf8
            "X=".utf8
            Int.parser()
            ", Y=".utf8
            Int.parser()
        } separator: {
            Whitespace(2, .vertical)
        }
    }

    func run() throws {
        let input = try parsed(file: "13.txt")

        var part1 = 0
        for (xa, ya, xb, yb, tx, ty) in input {
            let A = (yb * tx - xb * ty) / (yb * xa - xb * ya)
            let B = (xa * ty - ya * tx) / (yb * xa - xb * ya)
            if (A * xa + B * xb) == tx && (A * ya + B * yb) == ty {
                part1 += A * 3 + B
            }
        }

        print("Part 1", part1)

        var part2 = 0
        for (xa, ya, xb, yb, tx_, ty_) in input {
            let ty = ty_ + 10000000000000
            let tx = tx_ + 10000000000000
            let A = (yb * tx - xb * ty) / (yb * xa - xb * ya)
            let B = (xa * ty - ya * tx) / (yb * xa - xb * ya)
            if (A * xa + B * xb) == tx && (A * ya + B * yb) == ty {
                part2 += A * 3 + B
            }
        }

        print("Part 2", part2)
    }
}
