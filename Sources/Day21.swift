import ArgumentParser
import Collections

struct Day21: ParsableCommand {
    @Argument var file: String = "21.txt"

    /*
     +---+---+---+
     | 7 | 8 | 9 |
     +---+---+---+
     | 4 | 5 | 6 |
     +---+---+---+
     | 1 | 2 | 3 |
     +---+---+---+
         | 0 | A |
         +---+---+

         +---+---+
         | ^ | A |
     +---+---+---+
     | < | v | > |
     +---+---+---+
     */

    func run() throws {
        guard let input = String(data: try read(filename: file), encoding: .utf8) else { fatalError("Couldn't read input") }
        let lines = input.split(separator: "\n")

        let graph0: [Character: [(Character, Character)]] = [
            "0": [("A", ">"), ("2", "^")],
            "A": [("0", "<"), ("3", "^")],
            "1": [("2", ">"), ("4", "^")],
            "2": [("0", "v"), ("1", "<"), ("3", ">"), ("5", "^")],
            "3": [("A", "v"), ("2", "<"), ("6", "^")],
            "4": [("1", "v"), ("5", ">"), ("7", "^")],
            "5": [("2", "v"), ("4", "<"), ("6", ">"), ("8", "^")],
            "6": [("3", "v"), ("5", "<"), ("9", "^")],
            "7": [("4", "v"), ("8", ">")],
            "8": [("5", "v"), ("7", "<"), ("9", ">")],
            "9": [("6", "v"), ("8", "<")],
        ]

        let graph1: [Character: [(Character, Character)]] = [
            "A": [("^", "<"), (">", "v")],
            "^": [("A", ">"), ("v", "v")],
            ">": [("A", "^"), ("v", "<")],
            "v": [("^", "^"), ("<", "<"), (">", ">")],
            "<": [("v", ">")],
        ]

        // All equal step paths from start to end
        func expand(graph: [Character: [(Character, Character)]], start: Character, end: Character) -> [String] {
            var cost = Int.max
            var queue: Deque = [(start, "")]
            var visited = Set<Character>()
            var result: [String] = []

            while let (current, c) = queue.popFirst(), cost >= c.count {
                if current == end {
                    cost = c.count
                    result.append(c.appending("A"))
                    continue
                }

                visited.insert(current)
                for (next, direction) in graph[current] ?? [] {
                    if !visited.contains(next) {
                        queue.append((next, c.appending(String(direction))))
                    }
                }
            }

            return result
        }

        // [ Start: [ End: [Paths] ]
        let numPad = Dictionary(
            grouping: graph0.keys.permutations(ofCount: 2).map {
                ($0[0], $0[1], expand(graph: graph0, start: $0[0], end: $0[1]))
            },
            by: \.0
        )
            .mapValues {
                Dictionary(
                    grouping: $0,
                    by: \.1
                )
                .mapValues {
                    $0.flatMap(\.2)
                }
            }

        // [ Start: [ End: [Paths] ]
        let arrowKeys = Dictionary(
            grouping: graph1.keys.permutations(ofCount: 2).map {
                ($0[0], $0[1], expand(graph: graph1, start: $0[0], end: $0[1]))
            },
            by: \.0
        )
            .mapValues {
                Dictionary(
                    grouping: $0,
                    by: \.1
                )
                .mapValues {
                    $0.flatMap(\.2)
                }

            }

        struct Key: Hashable {
            let line: String
            let graphs: Int
        }

        func expand(line: some StringProtocol, cache: inout [Key: Int], graphs: some Collection<[Character: [Character: [String]]]>) -> Int {
            guard let graph = graphs.first else { return line.count }
            let key = Key(line: String(line), graphs: graphs.count)
            if let cached = cache[key] { return cached }

            let remaining = graphs.dropFirst()

            var result = 0
            var position = "A" as Character

            for character in line {
                let possiblePaths = graph[position]![character, default: ["A"]]
                let min = possiblePaths
                    .map { expand(line: $0, cache: &cache, graphs: remaining) }
                    .min()!

                result += min
                position = character
            }

            cache[key] = result
            return result
        }

        do {
            var part1 = 0
            var cache = [Key: Int]()
            for line in lines {
                let value = Int(line[line.startIndex..<line.firstIndex(of: "A")!])!
                let command = expand(line: line, cache: &cache, graphs: [numPad, arrowKeys, arrowKeys])

                print(line, command)
                part1 += value * command
            }
            print("Part 1", part1)
        }

        do {
            var part2 = 0
            var cache = [Key: Int]()

            for line in lines {
                let value = Int(line[line.startIndex..<line.firstIndex(of: "A")!])!
                let command = expand(
                    line: line,
                    cache: &cache,
                    graphs: [
                        numPad,
                        arrowKeys, arrowKeys, arrowKeys, arrowKeys, arrowKeys,
                        arrowKeys, arrowKeys, arrowKeys, arrowKeys, arrowKeys,
                        arrowKeys, arrowKeys, arrowKeys, arrowKeys, arrowKeys,
                        arrowKeys, arrowKeys, arrowKeys, arrowKeys, arrowKeys,
                        arrowKeys, arrowKeys, arrowKeys, arrowKeys, arrowKeys
                    ]
                )

                print(line, command)
                part2 += value * command
            }
            print("Part 2", part2)
        }

    }
}

// v<<A >>^A vA ^A v<<A >>^A A v<A <A >>^A A vA A <^A >A v<A >^A A <A >A v<A <A >>^A A A vA <^A >A
//    <    A  >  A    <    A A  v  <     A A  > >  ^   A   v   A A ^  A   v  <     A A A >   ^   A
//         ^     A         ^ ^           < <           A       > >    A            v v v         A
//               3                                     7              9                          A

// <v<A >>^A vA ^A <vA <A A >>^A A vA <^A >A A vA ^A <vA >^A A <A >A <v<A >A >^A A A vA <^A >A
//    <    A  >  A   v  < <    A A  >   ^  A A  >  A   v   A A  ^  A    <  v   A A A  >   ^  A
//         ^     A             < <         ^ ^     A       > >     A           v v v         A
//               3                                 7               9                         A

