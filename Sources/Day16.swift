import ArgumentParser
import Collections

struct Day16: ParsableCommand {
    @Argument var file: String = "16.txt"

    func run() throws {
        let input = try grid(file: file)

        let start = input.indices.first { input[$0] == "S" }!
        let end = input.indices.first { input[$0] == "E" }!

        let (part1, part2) = dfs(position: start, goal: end, grid: input)
        print("Part 1", part1)
        print("Part 2", part2)
    }

    struct Element: Hashable, Comparable {
        let vector: Vector
        let score: Int
        let tiles: Set<Coord>

        static func < (lhs: Element, rhs: Element) -> Bool {
            lhs.score < rhs.score
        }
    }

    func dfs(position: Coord, goal: Coord, grid: Grid<Character>) -> (cost: Int, tiles: Int) {
        var queue: Heap<Element> = [ .init(vector: .init(position: position, direction: .right), score: 0, tiles: [position]) ]
        var visited: Set<Vector> = .init()

        var cost = Int.max
        var tiles = Set<Coord>()

        while let current = queue.popMin() {
            guard current.score <= cost else { continue }

            if current.vector.position == goal {
                print("FOUND PATH", current.tiles)
                cost = current.score
                tiles.formUnion(current.tiles)
                continue
            }

            let neighbors = [
                Element(
                    vector: .init(
                        position: current.vector.position + current.vector.direction,
                        direction: current.vector.direction
                    ),
                    score: current.score + 1,
                    tiles: current.tiles.union([current.vector.position])
                ),
                Element(
                    vector: .init(
                        position: current.vector.position,
                        direction: current.vector.direction.clockwise
                    ),
                    score: current.score + 1000,
                    tiles: current.tiles
                ),
                Element(
                    vector: .init(
                        position: current.vector.position,
                        direction: current.vector.direction.counterClockwise
                    ),
                    score: current.score + 1000,
                    tiles: current.tiles
                ),
            ]
                .filter { grid[$0.vector.position] != "#" }
                .filter { !visited.contains($0.vector) }

            visited.formUnion(neighbors.map(\.vector))

            queue.insert(contentsOf: neighbors)
        }

        var grid = grid
        for tile in tiles { grid[tile] = "O" }
        print(grid)
        return (cost: cost, tiles: tiles.count)
    }
    }
}
