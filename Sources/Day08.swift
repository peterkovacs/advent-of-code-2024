import ArgumentParser

struct Day8: ParsableCommand {
    func run() throws {
        let grid = try grid(file: "08.txt")
        let positions = grid.indices
            .reduce(into: [Character: [Coord]]()) { result, p in
                guard grid[p] != "." else { return }
                result[ grid[p], default: [] ].append(p)
            }
            .values
            .flatMap { $0.permutations(ofCount: 2) }

        let part1 = Set(
            positions
                .map { $0[0] - ($0[1] - $0[0]) }
                .filter { grid.isValid($0) }
        )

        print("Part 1", part1.count)

        let part2 = Set(
            positions
                .flatMap {
                    let (a, b) = ($0[0], $0[1])
                    return (0...)
                        .lazy
                        .map { scale in a - (b - a) * scale }
                        .prefix { grid.isValid($0) }
                }
        )

        print("Part 2", part2.count)

    }
}
