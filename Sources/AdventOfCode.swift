import ArgumentParser
import Foundation
import Parsing

extension ParsableCommand {
    func read(filename: String = #file) throws -> Data {
        let url = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appending(path: "input", directoryHint: .isDirectory)
            .appending(path: filename)

        return try FileHandle(forReadingFrom: url).readToEnd() ?? Data()
    }

//    var input: AnyIterator<String> {
//        .init { readLine(strippingNewline: true) }
//    }
//
//    var stdin: String {
//        String(data: FileHandle.standardInput.readDataToEndOfFile(), encoding: .utf8) ?? "invalid utf-8 input"
//    }
//
//    var grid: Grid<Character> {
//        let input = Array(input)
//        return Grid(input.joined(), size: .init(x: input[0].count, y: input.count))
//    }

//    func infiniteGrid(_ default: Character) -> InfiniteGrid<Character> {
//        infiniteGrid(`default`, lines: Array(input))
//    }

    func grid(file: String) throws -> Grid<Character> {
        guard let data = String(data: try read(filename: file), encoding: .utf8)?.split(separator: /\n|\r\n/) else {
            throw ParsingError.invalidInput
        }
        
        return Grid(data.joined(), size: .init(x: data[0].count, y: data.count))
    }

    func infiniteGrid(_ default: Character, file: String) throws -> InfiniteGrid<Character> {
        let data = try read(filename: file)
        return infiniteGrid(`default`, lines: String(data: data, encoding: .utf8)?.split(separator: /\n|\r\n/) ?? [])
    }

    func infiniteGrid(_ default: Character, lines: [Substring]) -> InfiniteGrid<Character> {
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

    @ParserBuilder<Substring.UTF8View> static var parser: ParserType { get }
    func parsed(file: String) throws -> Output
}

enum ParsingError: Error {
    case fileNotFound(String)
    case invalidInput
}

extension ParsingCommand {
//    func parsed() throws -> Output {
//        try Self.parser.parse(stdin)
//    }

    func parsed(file: String) throws -> Output {
        let data = try read(filename: file)
        guard
            let contents = String(data: data, encoding: .utf8)
        else {
            throw ParsingError.fileNotFound(file)
        }

        return try Self.parser.parse(contents.utf8)
    }
}

@main struct AdventOfCode: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        abstract: "AdventOfCode 2024",
        subcommands: [
            Day1.self,
            Day2.self,
            Day3.self,
            Day4.self,
            Day5.self,
            Day6.self,
            Day7.self,
            Day8.self
        ]
    )

    init() { }

    func run() throws {
        try Day1().run()
        try Day2().run()
        try Day3().run()
        try Day4().run()
        try Day5().run()
        try Day6().run()
        try Day7().run()
        try Day8().run()
    }
}
