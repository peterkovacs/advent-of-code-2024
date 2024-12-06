import ArgumentParser

struct Day6: ParsableCommand {

    func part1(position: Coord, grid: Grid<Character>) -> (Grid<Character>, Int) {
        var grid = grid
        var visited: Set<Coord> = []
        var facing = Coord.up
        var position = position

        while grid.isValid(position) {

            let inFront = position + facing
            if grid.isValid(inFront) && grid[inFront] == "#" {
                facing = facing.clockwise
            }

            grid[position] = "X"
            visited.insert(position)
            position = position + facing
        }

        return (grid, visited.count)
    }

    func part2(position startingPosition: Coord, grid: Grid<Character>) -> Int {
        func isLoop(at: Coord) -> Bool {
            var vector = Vector(position: startingPosition, direction: .up)
            var visited: Set<Vector> = []

            while grid.isValid(vector.position) {
                guard visited.insert(vector).inserted else { return true }

                while true {
                    let inFront = vector.position + vector.direction
                    if inFront == at || (grid.isValid(inFront) && grid[inFront] == "#") {
                        vector.direction = vector.direction.clockwise
                    }
                    else { break }
                }

                vector.position = vector.position + vector.direction
            }

            return false
        }
        return grid
            .indices
            .filter {
                $0 != startingPosition && grid[$0] == "X"
            }
            .filter {
                isLoop(at: $0)
            }
            .count
    }

    func run() throws {
        let grid = grid
        guard let startingPosition = grid.indices.first(where: { grid[$0] == "^" }) else { fatalError("No starting position found") }

        let (path, p1) = part1(position: startingPosition, grid: grid)
        print("Part 1", p1)
        print("Part 2", part2(position: startingPosition, grid: path))

    }
}
