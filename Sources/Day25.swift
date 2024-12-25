import Algorithms
import ArgumentParser
import CasePaths

struct Day25: ParsableCommand {
    @CasePathable
    enum Schematic: Equatable {
        case key(Int, Int, Int, Int, Int)
        case lock(Int, Int, Int, Int, Int)
    }

    func run() throws {
        let input = String(data: try read(filename: "25.txt"), encoding: .utf8)!
            .split(separator: /\n\n/)
            .map { (input: Substring) -> Grid<Character> in
                return Grid(input.split(separator: /\n/).joined(), size: .init(x: 5, y: 7))
            }
            .map { (grid: Grid<Character>) -> Schematic in
                if grid.row(0).allSatisfy({ $0 == "#" }) {
                    return Schematic.key(
                        (1..<7).first { grid[.init(x: 0, y: $0)] == "." }! - 1,
                        (1..<7).first { grid[.init(x: 1, y: $0)] == "." }! - 1,
                        (1..<7).first { grid[.init(x: 2, y: $0)] == "." }! - 1,
                        (1..<7).first { grid[.init(x: 3, y: $0)] == "." }! - 1,
                        (1..<7).first { grid[.init(x: 4, y: $0)] == "." }! - 1
                    )
                } else {
                    return Schematic.lock(
                        5 - (0..<6).reversed().first { grid[.init(x: 0, y: $0)] == "." }!,
                        5 - (0..<6).reversed().first { grid[.init(x: 1, y: $0)] == "." }!,
                        5 - (0..<6).reversed().first { grid[.init(x: 2, y: $0)] == "." }!,
                        5 - (0..<6).reversed().first { grid[.init(x: 3, y: $0)] == "." }!,
                        5 - (0..<6).reversed().first { grid[.init(x: 4, y: $0)] == "." }!
                    )
                }
            }

        let (keys, locks) = input
            .partitioned { $0.is(\Schematic.Cases.lock) }

        let part1 = product(keys, locks)
            .filter { (key, lock) in
                guard
                    case let .key(a, b, c, d, e) = key,
                    case let .lock(f, g, h, i, j) = lock
                else { return false }

                return a + f <= 5 && b + g <= 5 && c + h <= 5 && d + i <= 5 && e + j <= 5
            }
            .count

        print("Part 1", part1)
    }
}
