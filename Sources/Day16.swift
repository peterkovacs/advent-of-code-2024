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
        var vector: Vector
        var score: Int
        var tiles: [Coord]

        @inlinable static func < (lhs: Element, rhs: Element) -> Bool {
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

        while var current = queue.popMin() {
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
            do {
                let visited = visited[current.vector.position]

                if
                    (visited & current.vector.direction.clockwise.bit) == 0,
                    distance[current.vector.position][keyPath: current.vector.direction.clockwise.keyPath] >= current.score + 1000
                {
                    let i = Element(
                        vector: .init(
                            position: current.vector.position,
                            direction: current.vector.direction.clockwise
                        ),
                        score: current.score + 1000,
                        tiles: current.tiles
                    )

                    distance[i.vector.position][keyPath: i.vector.direction.keyPath] = i.score
                    queue.insert(i)

                }

                if
                    (visited & current.vector.direction.counterClockwise.bit) == 0,
                    distance[current.vector.position][keyPath: current.vector.direction.counterClockwise.keyPath] >= current.score + 1000
                {
                    let i = Element(
                        vector: .init(
                            position: current.vector.position,
                            direction: current.vector.direction.counterClockwise
                        ),
                        score: current.score + 1000,
                        tiles: current.tiles
                    )

                    distance[i.vector.position][keyPath: i.vector.direction.keyPath] = i.score
                    queue.insert(i)
                }
            }

            current.vector.position = current.vector.position + current.vector.direction
            current.score += 1

            // Check the tile in front
            if
                grid[current.vector.position] != "#",
                (visited[current.vector.position] & current.vector.direction.bit) == 0,
                distance[current.vector.position][keyPath: current.vector.direction.keyPath] >= current.score
            {
                current.tiles.append(current.vector.position)
                distance[current.vector.position][keyPath: current.vector.direction.keyPath] = current.score
                queue.insert(current)
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
        case .left:  return \.0
        case .right: return \.1
        case .up:    return \.2
        case .down:  return \.3
        default: fatalError()
        }
    }
}
