import ArgumentParser
import Collections
import Parsing

struct Day18: ParsingCommand {
    static var parser: some Parser<Substring.UTF8View, [Coord]> {
        Many {
            Parse(Coord.init) {
                Int.parser()
                ",".utf8
                Int.parser()
            }
        } separator: {
            Whitespace(.vertical)
        } terminator: {
            End()
        }
    }

    func run() throws {
        let input = try parsed(file: "18.txt")
        let size = Coord(x: 71, y: 71)

        do {
            var grid = Grid<Bool>(repeating: true, size: size)
            input[0..<1024].forEach { grid[$0] = false }
            guard let steps = dijkstra(grid: grid, start: .zero, goal: size.up.left) else { return }
            print("Part 1", steps)
        }

        do {
            let coord = input.indices.partitioningIndex {
                var grid = Grid<Bool>(repeating: true, size: size)
                input[0...$0].forEach { grid[$0] = false }
                return dijkstra(grid: grid, start: .zero, goal: size.up.left) == nil
            }

            print("Part 2", "\(input[coord].x),\(input[coord].y)")
        }
    }

    struct Element: Comparable {
        let steps: Int
        let coord: Coord

        static func < (lhs: Element, rhs: Element) -> Bool {
            lhs.steps < rhs.steps
        }
    }

    func dijkstra(grid: Grid<Bool>, start: Coord, goal: Coord) -> Int? {
        var q = Set(grid.indices)
        var queue: Heap<Element> = [.init(steps: 0, coord: start)]
        var distance: [Coord: Int] = [:]
        var prev: [Coord: Coord] = [:]

        distance[start] = 0

        while let u = queue.popMin() {
            guard distance[u.coord] == u.steps else { continue }
            if u.coord == goal { return u.steps }

            q.remove(u.coord)

            let neighbors = grid.neighbors(adjacent: u.coord)
                .filter { grid[$0] }
                .filter { q.contains($0) }

            for v in neighbors {
                let alt = u.steps + 1
                if distance[v, default: Int.max] > alt {
                    queue.insert(.init(steps: alt, coord: v))
                    distance[v] = alt
                    prev[v] = u.coord
                }
            }
        }

        return nil
    }
}
