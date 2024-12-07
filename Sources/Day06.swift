import ArgumentParser
import Atomics
import Dispatch

struct Day6: ParsableCommand {

    func part1(position startingPosition: Vector, grid: Grid<Character>) -> ([Vector], Int) {
        var visited: Set<Coord> = []
        var path: [Vector] = []
        visited.reserveCapacity(grid.elements.count)
        var position = startingPosition

        while grid.isValid(position.position) {
            if visited.insert(position.position).inserted {
                path.append(position)
            }

            let inFront = position.position + position.direction
            if grid.isValid(inFront) && grid[inFront] == "#" {
                position.direction = position.direction.clockwise
            }

            position.position = position.position + position.direction
        }

        return (path, visited.count)
    }

    func part2(path: [Vector], grid: Grid<Character>) -> Int {
        // place an obstacle at the next position in the path, run a simulation from our current position
        @Sendable func isLoop(at obstacle: Coord, path: ArraySlice<Vector>, position: Vector) -> Bool {
            var position = position
            var visited: Set<Vector> = []
            visited.reserveCapacity(path.count * 4)

            while grid.isValid(position.position) {
                guard visited.insert(position).inserted else { return true }

                while true {
                    let inFront = position.position + position.direction
                    if inFront == obstacle || (grid.isValid(inFront) && grid[inFront] == "#") {
                        position.direction = position.direction.clockwise
                    }
                    else { break }
                }

                position.position = position.position + position.direction
            }

            return false
        }

        let counter = ManagedAtomic<Int>(0)

        DispatchQueue.concurrentPerform(iterations: path.count - 1) { index in
            if isLoop(at: path[index + 1].position, path: path[..<index], position: path[index]) {
                counter.wrappingIncrement(ordering: .relaxed)
            }
        }

        return counter.load(ordering: .relaxed)
    }

    func run() throws {
        let grid = grid
        guard let startingPosition = grid.indices.first(where: { grid[$0] == "^" }) else { fatalError("No starting position found") }

        let (path, part1) = part1(position: .init(position: startingPosition, direction: .up), grid: grid)
        print("Part 1", part1, path.count)
        print("Part 2", part2(path: path, grid: grid))

    }
}
