import Foundation

public final class TreeWalkInterpreter {
    private var hadError = false

    public init() {}

    public func runFile(at file: URL) async throws {
        try run(String(contentsOf: file).trimmingCharacters(in: .whitespacesAndNewlines))
    }

    func runFileByLine(at file: URL) async throws {
        let handle = try FileHandle(forReadingFrom: file)
        for try await line in handle.bytes.lines {
            print(line)
        }
    }

    public func runPrompt() {
        print("> ")
        while let line = readLine() {
            run(line)
            hadError = false
        }
    }

    func run(_ string: String) {
        print(string.components(separatedBy: .whitespacesAndNewlines).map { $0 as NSString })
        let scanner = Scanner(source: string)
        scanner.scanTokens()
        print(scanner.tokens)
    }

    // MARK: Helpers

    func error(at line: Int, message: String) {
        reportError(at: line, where: "", message: message)
    }

    func reportError(at line: Int, where: String, message: String) {
        print("[line \(line)] Error \(`where`): \(message)")
        hadError = true
    }
}

struct Token {
    let type: TokenType
    let lexeme: String
    let line: Int
    let literal: Literal?

    enum TokenType {
        // Single-character tokens
        case leftParen, rightParen, leftBrace, rightBrace, comma, dot, minus, plus, semicolon, slash, star

        // One or two character tokens.
        case bang, bangEqual, equal, equalEqual, greater, greaterEqual, less, lessEqual

        // Literals
        case identifier, string, number

        // Keywords
        case and, `class`, `else`, `false`, fun, `for`, `if`, `nil`, or, print, `return`, `super`, this, `true`, `var`, `while`

        case eof
    }

    enum Literal {
        case string(String), bool(Bool), number(Double), `nil`
    }
}

final class Scanner {
    var tokens: [Token] = []

    private let source: String

    init(source: String) {
        self.source = source
    }

    func scanTokens() {
        tokens.append(Token(type: .eof, lexeme: "", line: 10, literal: nil))
    }
}
