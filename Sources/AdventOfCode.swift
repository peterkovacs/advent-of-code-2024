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
            Day8.self,
            Day9.self,
            Day10.self,
            Day11.self,
            Day12.self,
            Day13.self,
            Day14.self,
            Day15.self,
            Day16.self,
            Day17.self,
            Day18.self,
            Day19.self,
            Day20.self,
        ]
    )

    init() { }

    func run() throws {
        func go<T>(_ type: T.Type) throws -> TimeInterval where T: ParsableCommand {
            print(T._commandName)
            var command = try T.parse(nil)
            let start = Date()
            try command.run()
            let end = Date()
            print("-> took \(String(format: "%0.3f", end.timeIntervalSince(start))) seconds\n")
            return end.timeIntervalSince(start)
        }

        let duration = try Self.configuration.subcommands.reduce(0.0) { try $0 + go($1) }
        print("-> took \(String(format: "%0.3f", duration)) seconds\n")

    }
}
