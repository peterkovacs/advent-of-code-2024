import ArgumentParser
import Collections

struct Day10: ParsableCommand {
    @Argument var file: String = "10.txt"

    func run() throws {
        let grid = try self.grid(file: file).map { $0 == "." ? 100 : Int(String($0))! }
        let startingPositions = grid.indices.filter { grid[$0] == 0 }

        let part1 = startingPositions.reduce(into: 0) { $0 += bfs(from: $1, in: grid) }
        print("Part 1", part1)


        let part2 = startingPositions.reduce(into: 0) { $0 += dfs(from: $1, in: grid) }
        print("Part 2", part2)

    }

    func bfs(from: Coord, in grid: Grid<Int>) -> Int {
        var queue: Deque<Coord> = [from]
        var visited: Set<Coord> = []
        var result = 0

        visited.reserveCapacity(grid.elements.count)
        queue.reserveCapacity(grid.elements.count)

        while let next = queue.popFirst() {
            if grid[next] == 9 {
                result += 1
                continue
            }

            let neighbors = grid.neighbors(adjacent: next)
                .filter { grid[$0] - grid[next] == 1 }
                .filter { visited.contains($0) == false }

            visited.formUnion(neighbors)
            queue.append(contentsOf: neighbors)
        }

        return result
    }

    func dfs(from: Coord, in grid: Grid<Int>) -> Int {
        if grid[from] == 9 { return 1 }
        
        let neighbors = grid.neighbors(adjacent: from)
            .filter { grid[$0] - grid[from] == 1 }

        return neighbors.reduce(into: 0) { $0 += dfs(from: $1, in: grid) }
    }
}
