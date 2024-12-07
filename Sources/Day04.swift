import ArgumentParser

struct Day4: ParsableCommand {
    func part1(_ grid: InfiniteGrid<Character>) -> Int {
        grid.indices.filter {
            grid[$0] == "X" && grid[$0.right] == "M" && grid[$0.right.right] == "A" && grid[$0.right.right.right] == "S"
        }.count +
        grid.indices.filter {
            grid[$0] == "X" && grid[$0.left] == "M" && grid[$0.left.left] == "A" && grid[$0.left.left.left] == "S"
        }.count +
        grid.indices.filter {
            grid[$0] == "X" && grid[$0.down] == "M" && grid[$0.down.down] == "A" && grid[$0.down.down.down] == "S"
        }.count +
        grid.indices.filter {
            grid[$0] == "X" && grid[$0.up] == "M" && grid[$0.up.up] == "A" && grid[$0.up.up.up] == "S"
        }.count +
        grid.indices.filter {
            grid[$0] == "X" && grid[$0.right.down] == "M" && grid[$0.right.down.right.down] == "A" && grid[$0.right.down.right.down.right.down] == "S"
        }.count +
        grid.indices.filter {
            grid[$0] == "X" && grid[$0.right.up] == "M" && grid[$0.right.up.right.up] == "A" && grid[$0.right.up.right.up.right.up] == "S"
        }.count +
        grid.indices.filter {
            grid[$0] == "X" && grid[$0.left.down] == "M" && grid[$0.left.down.left.down] == "A" && grid[$0.left.down.left.down.left.down] == "S"
        }.count +
        grid.indices.filter {
            grid[$0] == "X" && grid[$0.left.up] == "M" && grid[$0.left.up.left.up] == "A" && grid[$0.left.up.left.up.left.up] == "S"
        }.count
    }

    func part2(_ grid: InfiniteGrid<Character>) -> Int {
        // M.M
        // .A.
        // S.S
        grid.indices.filter {
            grid[$0] == "M" && grid[$0.right.right] == "M" &&
            grid[$0.down.right] == "A" &&
            grid[$0.down.down] == "S" && grid[$0.down.down.right.right] == "S"
        }.count +
        // M.S
        // .A.
        // M.S
        grid.indices.filter {
            grid[$0] == "M" && grid[$0.down.down] == "M" &&
            grid[$0.down.right] == "A" &&
            grid[$0.right.right] == "S" && grid[$0.down.down.right.right] == "S"
        }.count +
        // S.S
        // .A.
        // M.M
        grid.indices.filter {
            grid[$0] == "M" && grid[$0.right.right] == "M" &&
            grid[$0.up.right] == "A" &&
            grid[$0.up.up] == "S" && grid[$0.up.up.right.right] == "S"
        }.count +
        // S.M
        // .A.
        // S.M
        grid.indices.filter {
            grid[$0] == "M" && grid[$0.up.up] == "M" &&
            grid[$0.up.left] == "A" &&
            grid[$0.left.left] == "S" && grid[$0.up.up.left.left] == "S"
        }.count
    }

    func run() throws {
        let grid = try infiniteGrid(".", file: "04.txt")

        let part1 = part1(grid)
        print("Part 1", part1)

        let part2 = part2(grid)
        print("Part 2", part2)

    }
}
