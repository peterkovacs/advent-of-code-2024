import ArgumentParser
import Parsing

struct Day14: ParsingCommand {
    @Argument var file: String = "14.txt"
    @Argument var width: Int = 101
    @Argument var height: Int = 103

    static var parser: some Parser<Substring.UTF8View, [Vector]> {
        Many {
            Parse(Vector.init(position:direction:)) {
                "p=".utf8

                Parse(Coord.init(x:y:)) {
                    Int.parser()
                    ",".utf8
                    Int.parser()
                }

                " v=".utf8

                Parse(Coord.init(x:y:)) {
                    Int.parser()
                    ",".utf8
                    Int.parser()
                }
            }
        } separator: {
            Whitespace(.vertical)
        }
    }

    func run() throws {
        let input = try parsed(file: file)
        let size = Coord(x: width, y: height)

        do {
            var vectors = input
            for _ in 0..<100 {
                vectors = vectors.map {
                    $0.move(mod: size)
                }
            }

            let part1 = vectors.reduce(into: (0, 0, 0, 0)) { partialResult, i in
                partialResult.0 += i.position.x < size.x / 2 && i.position.y < size.y / 2 ? 1 : 0
                partialResult.1 += i.position.x > size.x / 2 && i.position.y < size.y / 2 ? 1 : 0
                partialResult.2 += i.position.x < size.x / 2 && i.position.y > size.y / 2 ? 1 : 0
                partialResult.3 += i.position.x > size.x / 2 && i.position.y > size.y / 2 ? 1 : 0
            }

            print("Part 1", part1.0 * part1.1 * part1.2 * part1.3)
        }

        do {
            var vectors = input
            var (minX, minY) = (Int.max, Int.max)

            for i in 0... {
                let meanX = vectors.map(\.position.x).reduce(0, +) / vectors.count
                let varianceX = vectors.map(\.position.x).reduce(0, { $0 + ($1 - meanX)*($1 - meanX) }) / vectors.count

                let meanY = vectors.map(\.position.y).reduce(0, +) / vectors.count
                let varianceY = vectors.map(\.position.y).reduce(0, { $0 + ($1 - meanY)*($1 - meanY) }) / vectors.count

                if varianceX == minX && varianceY == minY {
                    print("Part 1", i)
                    break
                }

                minX = min(minX, varianceX)
                minY = min(minY, varianceY)
                vectors = vectors.map { $0.move(mod: size) }
            }
        }
    }
}

fileprivate extension Vector {
    func move(mod: Coord) -> Vector {
        var result = self
        result.position = position + direction

        if result.position.x < 0 { result.position.x += mod.x }
        if result.position.y < 0 { result.position.y += mod.y }
        result.position.x %= mod.x
        result.position.y %= mod.y
        return result
    }
}
