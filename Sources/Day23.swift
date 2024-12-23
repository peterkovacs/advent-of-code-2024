import ArgumentParser
import Parsing

struct Day23: ParsingCommand {
    @Argument var file: String = "23.txt"
    static var parser: some Parser<Substring.UTF8View, [(String, String)]> {
        Many {
            Prefix(2).map { String($0)! }
            "-".utf8
            Prefix(2).map { String($0)! }
        } separator: {
            Whitespace(1, .vertical)
        } terminator: {
            End()
        }
    }

    func run() throws {
        let edges = try parsed(file: file)
        let graph = edges.reduce(into: [String: Set<String>]()) {
            $0[$1.0, default: .init()].insert($1.1)
            $0[$1.1, default: .init()].insert($1.0)
        }

        do {
            let networks = Set(
                graph
                    .flatMap { (key, value) in
                        value
                            .combinations(ofCount: 2)
                            .filter { graph[$0[0], default: .init()].contains($0[1]) }
                            .map { ([key] + $0).sorted() }
                    }

            )

            let part1 = networks
                .filter { $0.contains { $0.first == "t" } }

            print("Part 1", part1.count)
        }
        /*
         https://univ-angers.hal.science/hal-02709508/document
         Algorithm 1 A simple algorithm to find the maximum clique C∗
         Function Main
             C* ←∅// the maximum clique
             Clique(∅, V )
             return C*
         End function
         Function Clique(set C, set P)
             if (|C| > |C*|) then
                 C* ← C
             End if
              if (|C|+ |P| > |C*|) then
                  for all p ∈ P in predetermined order, do
                      P ← P \ {p}
                      C' ← C ∪ {p}
                      P' ← P ∩ N(p) // Let N (v) be the set of the vertices adjacent to vertex v
                      Clique(C', P')
                  End for
              End if
          End function
         */

        var maxClique: Set<String> = []
        func clique(_ C: Set<String>, _ P: Set<String>) {
            if C.count > maxClique.count {
                maxClique = C
            }

            if C.count + P.count > maxClique.count {
                var P = P
                for p in P.sorted() {
                    P.subtract([p])
                    let Cʹ = C.union([p])
                    let Pʹ = P.intersection(graph[p, default: []])

                    clique(Cʹ, Pʹ)
                }
            }
        }

        do {
            clique(.init(), Set(graph.keys))
            print("Part 2", maxClique.sorted(by: <).joined(separator: ","))
        }
    }
}
