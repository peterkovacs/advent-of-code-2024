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
        let tiles: [Coord]

        static func < (lhs: Element, rhs: Element) -> Bool {
            lhs.score < rhs.score
        }
    }

    func dfs(position: Coord, goal: Coord, grid: Grid<Character>) -> (cost: Int, tiles: Int) {
        var queue: Heap<Element> = [ .init(vector: .init(position: position, direction: .right), score: 0, tiles: [position]) ]
        var visited = Grid(repeating: 0 as UInt8, size: grid.size)
        var distance = Grid(repeating: (Int.max, Int.max, Int.max, Int.max), size: grid.size)

        distance[position][keyPath: Coord.right.keyPath] = 0

        var cost = Int.max
        var tiles: Set<Coord> = [ position, goal ]

        while let current = queue.popMin() {
            // We've exhausted all possibilities of beating our score.
            guard current.score <= cost else { break }

            // Better path to the current vector
            guard distance[current.vector.position][keyPath: current.vector.direction.keyPath] == current.score else { continue }

            // Add the tiles of the current element
            if current.vector.position == goal {
                cost = current.score
                tiles.formUnion(current.tiles)
                continue
            }

            visited[current.vector.position] |= current.vector.direction.bit

            var neighbors: [Element] = []
            var tiles = current.tiles
            let forward = current.vector.position + current.vector.direction

            // Check the tile in front
            if grid[forward] != "#" &&
                (visited[forward] & current.vector.direction.bit) == 0 &&
                distance[forward][keyPath: current.vector.direction.keyPath] >= current.score + 1
            {
                tiles.append(forward)
                neighbors.append(
                    Element(
                        vector: .init(
                            position: forward,
                            direction: current.vector.direction
                        ),
                        score: current.score + 1,
                        tiles: tiles
                    )
                )
            }

            // check turning left or right
            neighbors.append(
                contentsOf:  [
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
                    .filter {
                        (visited[$0.vector.position] & $0.vector.direction.bit) == 0 &&
                        distance[$0.vector.position][keyPath: $0.vector.direction.keyPath] >= $0.score
                    }
            )

            for i in neighbors {
                distance[i.vector.position][keyPath: i.vector.direction.keyPath] = i.score
                queue.insert(i)
            }
        }

        return (cost: cost, tiles: tiles.count)
    }
}


fileprivate extension Coord {

    var bit: UInt8 {
        switch self {
        case .left:  return 1
        case .right: return 2
        case .up:    return 4
        case .down:  return 8
        default: fatalError()
        }
    }

    var keyPath: WritableKeyPath<(Int, Int, Int, Int), Int> {
        switch self {
        case .left:  return \(Int, Int, Int, Int).0
        case .right: return \(Int, Int, Int, Int).1
        case .up:    return \(Int, Int, Int, Int).2
        case .down:  return \(Int, Int, Int, Int).3
        default: fatalError()
        }
    }
}
