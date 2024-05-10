import Foundation

public final class TreeWalkInterpreter {
    private static var hadError = false

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
            Self.hadError = false
        }
    }

    func run(_ string: String) {
        print(string.components(separatedBy: .whitespacesAndNewlines).map { $0 as NSString })
        let scanner = Scanner(source: string)
        scanner.scanTokens()
        print(scanner.tokens)
    }

    // MARK: Helpers

    static func error(at line: Int, message: String) {
        reportError(at: line, where: "", message: message)
    }

    static func reportError(at line: Int, where: String, message: String) {
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

    private var line = 1
    private var startIndex: String.Index
    private var currentIndex: String.Index

    private let source: String

    init(source: String) {
        self.source = source
        startIndex = source.startIndex
        currentIndex = source.startIndex
    }

    func scanTokens() {
        while currentIndex < source.endIndex {
            startIndex = currentIndex
            let character = source[startIndex]
            advance()
            switch character {
            case "(": addToken(.leftParen)
            case ")": addToken(.rightParen)
            case "{": addToken(.leftBrace)
            case "}": addToken(.rightBrace)
            case ",": addToken(.comma)
            case ".": addToken(.dot)
            case "-": addToken(.minus)
            case "+": addToken(.plus)
            case ";": addToken(.semicolon)
            case "*": addToken(.star)
            case "!": addToken(matches("=") ? .bangEqual : .bang)
            case "=": addToken(matches("=") ? .equalEqual : .equal)
            case "<": addToken(matches("=") ? .lessEqual : .less)
            case ">": addToken(matches("=") ? .greaterEqual : .greater)
            case "/":
                if matches("/") {
                    advance(until: "\n")
                } else {
                    addToken(.slash)
                }
            case " ", "\r", "\t": break // Ignore whitespace
            case "\n": line += 1
            case #"""#: parseString()
            default:
                if character.isASCIINumber {
                    parseNumber()
                } else if character.isAlpha {
                    advance(while: \.isAlphaNumeric)
                    let identifier = String(source[startIndex..<currentIndex])
                    addToken(keywords[identifier] ?? .identifier)
                } else {
                    TreeWalkInterpreter.error(at: line, message: "Unexpected character.")
                }
            }
        }

        tokens.append(Token(type: .eof, lexeme: "", line: line, literal: nil))
    }

    private func advance() { currentIndex = source.index(after: currentIndex) }

    private func advance(until sought: Character) {
        advance { $0 != sought }
    }

    private func advance(while predicate: (Character) -> Bool) {
        while let next = peek(), predicate(next), currentIndex < source.endIndex {
            advance()
        }
    }

    private func addToken(_ type: Token.TokenType, literal: Token.Literal? = nil) {
        tokens.append(.init(type: type, lexeme: String(source[startIndex..<currentIndex]), line: line, literal: literal))
    }

    private func matches(_ expected: Character) -> Bool {
        guard currentIndex < source.endIndex else { return false }

        guard source[currentIndex] == expected else { return false }

        currentIndex = source.index(after: currentIndex)
        return true
    }

    private func peek() -> Character? {
        guard currentIndex < source.endIndex else { return nil }

        return source[currentIndex]
    }

    private func peekNext() -> Character? {
        let nextIndex = source.index(after: currentIndex)
        guard nextIndex < source.endIndex else { return nil }

        return source[nextIndex]
    }

    private func parseString() {
        while let next = peek(), next != #"""# {
            if peek() == "\n" { line += 1 }

            advance()
        }

        if currentIndex == source.endIndex {
            TreeWalkInterpreter.error(at: line, message: "Unterminated string.")
        }

        // The closing ".
        advance()
        addToken(.string, literal: .string(String(source[source.index(startIndex, offsetBy: 1)..<source.index(currentIndex, offsetBy: -1)])))
    }

    private func parseNumber() {
        advance(while: \.isASCIINumber)

        // Look for a fractional part.
        if peek() == ".", peekNext()?.isASCIINumber == true {
            advance() // Consume the "."
            advance(while: \.isASCIINumber)
        }

        addToken(.number, literal: .number(Double(String(source[startIndex..<currentIndex]))!))
    }
}

extension Character {
    var isASCIINumber: Bool { isASCII && isWholeNumber }
    var isAlpha: Bool { isASCII && (isLetter || self == "_") }
    var isAlphaNumeric: Bool { isASCIINumber || isAlpha }
}

private let keywords: [String: Token.TokenType] = [
    "and": .and,
    "class": .class,
    "else": .else,
    "false": .false,
    "for": .for,
    "fun": .fun,
    "if": .if,
    "nil": .nil,
    "or": .or,
    "print": .print,
    "return": .return,
    "super": .super,
    "this": .this,
    "true": .true,
    "var": .var,
    "while": .while
]
