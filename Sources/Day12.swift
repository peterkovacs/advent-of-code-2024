import ArgumentParser

struct Day12: ParsableCommand {
    @Argument var file = "12.txt"
    func run() throws {
        let grid = try grid(file: file)

        do {
            var indices = Set(grid.indices)
            var part1 = 0
            for point in grid.indices {
                guard indices.remove(point) != nil else { continue }
                let (a, p) = grid.floodFill(from: point, remaining: &indices)
                part1 += (a * p)
            }

            print("Part 1", part1)
        }

        do {
            var indices = Set(grid.indices)
            var part2 = 0

            for point in grid.indices {
                guard indices.remove(point) != nil else { continue }
                let (a, p) = grid.floodFillCountingCorners(from: point, remaining: &indices)
                part2 += (a * p)
            }

            print("Part 2   ", part2)
        }
    }
}

extension Grid where Element: Equatable {
    func floodFill(from point: Coord, remaining: inout Set<Coord>) -> (area: Int, perimeter: Int) {
        var (notNeighbors, neighbors) = point.adjacent.partitioned {
            isValid($0) && self[$0] == self[point]
        }

        neighbors = Array(remaining.intersection(neighbors))
        remaining.subtract(neighbors)

        return neighbors.reduce(into: (1, notNeighbors.count)) {
            let (area, perimeter) = floodFill(from: $1, remaining: &remaining)
            $0.0 += area
            $0.1 += perimeter
        }
    }

    func floodFillCountingCorners(from point: Coord, remaining: inout Set<Coord>) -> (area: Int, corners: Int) {
        var neighbors = point.adjacent.filter {
            isValid($0) && self[$0] == self[point]
        }

        neighbors = Array(remaining.intersection(neighbors))
        remaining.subtract(neighbors)

        let isOutsideBottomRightCorner = (
            self.isValid(point.up)        && self[point.up]      == self[point] &&
            self.isValid(point.left)      && self[point.left]    == self[point] &&
            (!self.isValid(point.left.up) || self[point.left.up] != self[point])
        ) ? 1 : 0

        let isInsideBottomRightCorner = (
            (!self.isValid(point.right)      || self[point.right]      != self[point]) &&
            (!self.isValid(point.down)       || self[point.down]       != self[point])
        ) ? 1 : 0

        let isOutsideBottomLeftCorner = (
            self.isValid(point.up)         && self[point.up]       == self[point] &&
            self.isValid(point.right)      && self[point.right]    == self[point] &&
            (!self.isValid(point.right.up) || self[point.right.up] != self[point])
        ) ? 1 : 0

        let isInsideBottomLeftCorner = (
            (!self.isValid(point.left)      || self[point.left]      != self[point]) &&
            (!self.isValid(point.down)      || self[point.down]      != self[point])
        ) ? 1 : 0

        let isInsideTopLeftCorner = (
            (!self.isValid(point.left)    || self[point.left]    != self[point]) &&
            (!self.isValid(point.up)      || self[point.up]      != self[point])
        ) ? 1 : 0

        let isOutsideTopLeftCorner = (
            self.isValid(point.right)        && self[point.right]      == self[point] &&
            self.isValid(point.down)         && self[point.down]       == self[point] &&
            (!self.isValid(point.right.down) || self[point.right.down] != self[point])
        ) ? 1 : 0

        let isInsideTopRightCorner = (
            (!self.isValid(point.right)    || self[point.right]    != self[point]) &&
            (!self.isValid(point.up)       || self[point.up]       != self[point])
        ) ? 1 : 0

        let isOutsideTopRightCorner = (
            (self.isValid(point.left)       && self[point.left]       == self[point]) &&
            (self.isValid(point.down)       && self[point.down]       == self[point]) &&
            (!self.isValid(point.left.down) || self[point.left.down] != self[point])
        ) ? 1 : 0

        let corners = isInsideTopLeftCorner + isInsideTopRightCorner + isInsideBottomLeftCorner + isInsideBottomRightCorner + isOutsideTopLeftCorner + isOutsideTopRightCorner + isOutsideBottomLeftCorner + isOutsideBottomRightCorner

        return neighbors.reduce(into: (1, corners)) {
            let (area, corners) = floodFillCountingCorners(from: $1, remaining: &remaining)
            $0.0 += area
            $0.1 += corners
        }

    }
}
