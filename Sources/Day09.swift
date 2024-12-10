import Algorithms
import ArgumentParser

struct Day9: ParsableCommand {
    enum Block {
        case file(id: Int, size: Int, startingPosition: Int)
        case freeSpace(size: Int, startingPosition: Int)
    }

    func run() throws {
        let input = zip(
            [true, false].cycled(),
            try read(filename: "09.txt").map { Int($0 - 0x30) }
        )
            .reduce(
                into: (
                    id: 0,
                    position: 0,
                    files: [(id: Int, size: Int, startingPosition: Int)](),
                    free: [(size: Int, startingPosition: Int)]()
                )
            ) { (result, i) in
                let (isFile, size) = i

                if isFile {
                    precondition(size > 0)
                    result.files.append((id: result.id, size: size, startingPosition: result.position))
                    result.id += 1
                } else if size > 0 {
                    result.free.append((size: size, startingPosition: result.position))
                }

                result.position += size
            }

        do {
            var freeSpace = input.free[...]
            var output = [(id: Int, size: Int, startingPosition: Int)]()
            var free = freeSpace.popFirst()!

            for (id, var size, startingPosition) in input.files.reversed() {

                if startingPosition < free.startingPosition {
                    output.append((id: id, size: size, startingPosition: startingPosition))
                }
                else if size < free.size {
                    output.append((id: id, size: size, startingPosition: free.startingPosition))
                    free.size -= size
                    free.startingPosition += size

                } else {

                    repeat {
                        let amount = min(free.size, size)
                        output.append((id: id, size: amount, startingPosition: free.startingPosition))
                        size -= amount
                        free.size -= amount
                        free.startingPosition += amount
                        if free.size == 0 {
                            free = freeSpace.popFirst()!
                        }
                    } while size > 0 && startingPosition > free.startingPosition

                    if size > 0 {
                        output.append((id: id, size: size, startingPosition: startingPosition))
                    }
                }
            }

            let part1 = output.sorted { $0.startingPosition < $1.startingPosition }.reduce(into: 0) { partialResult, i in
                let (id, size, startingPosition) = i
                partialResult += (id * size * (startingPosition + startingPosition + size - 1)) / 2
            }

            print("Part 1", part1)
        }

        do {
            var freeSpace = input.free
            var output = [(id: Int, size: Int, startingPosition: Int)]()

            for (id, size, startingPosition) in input.files.reversed() {
                let index = freeSpace
                    .prefix { $0.startingPosition < startingPosition }
                    .firstIndex { $0.size >= size }

                if let index {
                    output.append((id: id, size: size, startingPosition: freeSpace[index].startingPosition))
                    freeSpace[index] = (size: freeSpace[index].size - size, startingPosition: freeSpace[index].startingPosition + size)
                } else {
                    output.append((id: id, size: size, startingPosition: startingPosition))
                }
            }

            let part2 = output.sorted { $0.startingPosition < $1.startingPosition }.reduce(into: 0) { partialResult, i in
                let (id, size, startingPosition) = i
                partialResult += (id * size * (startingPosition + startingPosition + size - 1)) / 2
            }

            print("Part 2", part2)
        }
    }
}
