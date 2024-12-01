import ArgumentParser
import Foundation
import Parsing

extension ParsableCommand {
  var input: AnyIterator<String> {
    .init { readLine(strippingNewline: true) }
  }

  var stdin: String {
    String(data: FileHandle.standardInput.readDataToEndOfFile(), encoding: .utf8) ?? "invalid utf-8 input"
  }

  var grid: Grid<Character> {
    let input = Array(input)
    return Grid(input.joined(), size: .init(x: input[0].count, y: input.count))
  }

  func infiniteGrid(_ default: Character) -> InfiniteGrid<Character> {
    let lines = Array(input)
    let joined = lines.joined()
    let size = Coord(x: lines[0].count, y: lines.count)
    assert(size.x * size.y == joined.count, "Input provided was not the expected size: \(size): \(size.x * size.y) != \(joined.count)")

    return InfiniteGrid(
      joined,
      size: size,
      default: `default`
    )
  }
}

protocol ParsingCommand: ParsableCommand {
    associatedtype Output
    associatedtype ParserType where ParserType: Parser<Substring.UTF8View, Output>
    static var parser: ParserType { get }
    func parsed() throws -> Output
}

extension ParsingCommand {
    func parsed() throws -> Output {
        try Self.parser.parse(stdin)
    }
}

@main struct AdventOfCode: ParsableCommand {
  static let configuration: CommandConfiguration = .init(
    abstract: "AdventOfCode 2024",
    subcommands: [
      Day1.self,
    ]
  )

  init() { }
}
