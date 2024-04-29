import ArgumentParser
import Foundation
import SloxKit

@main
struct Slox: AsyncParsableCommand {
    @Argument(transform: URL.init(fileURLWithPath:))
    var inputFile: URL?

    mutating func run() async throws {
        let interpreter = TreeWalkInterpreter()

        if let inputFile {
            try await interpreter.runFile(at: inputFile)
        } else {
            interpreter.runPrompt()
        }
    }
}
