import ArgumentParser
import Atomics
import Collections
import Foundation
import Parsing

struct Day20: ParsableCommand {
    @Argument var file: String = "20.txt"

    func calculateDistances(_ input: Grid<Character>) -> (Grid<Int>, [(Coord, Coord)]) {
        guard let start = input.indices.first(where: { input[$0] == "E" }) else { fatalError("Start not found") }
        var result = Grid(repeating: Int.max, size: input.size)
        var queue: Deque<Coord> = [start]
        var shortcuts: [(Coord, Coord)] = []
        result[start] = 0

        while let position = queue.popFirst() {
            for neighbor in input.neighbors(adjacent: position) where input[neighbor] != "#" && result[neighbor] == Int.max {
                queue.append(neighbor)
                result[neighbor] = result[position] + 1
            }

            for shortcut in [Coord.up, .down, .left, .right] {
                guard input.isValid(position + shortcut), input.isValid(position + shortcut + shortcut) else { continue }
                guard input[position + shortcut] == "#" else { continue }
                let destination = input[ position + shortcut + shortcut ]
                guard (destination == "." || destination == "E" || destination == "S") else { continue }

                shortcuts.append((position, position + shortcut + shortcut))
            }
        }

        return (result, shortcuts)
    }

    func run() throws {
        let input = try grid(file: file)
        let (distances, shortcuts) = calculateDistances(input)

        // Calculate example.
        // let part1 = shortcuts
        //     .map { ($0.0, $0.1, distances[$0.0] - distances[$0.1] - 2) }
        //     .filter { $0.2 > 0 }
        //     .grouped { $0.2 }
        //     .mapValues { $0.count }
        //     .sorted { $0.key < $1.key }

        let part1 = shortcuts
            .map { (distances[$0.0] - distances[$0.1] - 2) }
            .filter { $0 >= 100 }
            .count

        print("Part 1", part1)

        let path = distances.indices
            .filter { distances[$0] < Int.max }

        let part2 = ManagedAtomic(0)

        DispatchQueue.concurrentPerform(iterations: path.count) { index in
            let a = path[index]
            let count = path
                .reduce(into: 0) {
                    let distance = a.distance(to: $1)
                    if (1...20).contains(distance), distances[a] - distances[$1] - distance >= 100 {
                        $0 += 1
                    }
                }
            part2.wrappingIncrement(by: count, ordering: .relaxed)
        }

        print("Part 2", part2.load(ordering: .relaxed))
    }
}
