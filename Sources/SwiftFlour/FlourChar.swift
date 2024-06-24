import Foundation

public struct FlourChar: Equatable, Sendable, Hashable {

    public static let q = FlourChar("q")

    public static let arrowUp = FlourChar(KEY_UP)
    public static let arrowDown = FlourChar(KEY_DOWN)
    public static let arrowLeft = FlourChar(KEY_LEFT)
    public static let arrowRight = FlourChar(KEY_RIGHT)

    public static let enter = FlourChar(KEY_ENTER)
    public static let backspace = FlourChar(KEY_BACKSPACE)

    public static let space = FlourChar(" ")

    public let charAscii: Int32

    public let char: Character

    public init(_ char: Character) {
        self.char = char
        self.charAscii = Int32(char.asciiValue ?? 0)
    }

    public init(_ charAscii: Int32) {
        self.char = "0"
        self.charAscii = charAscii
    }

    public static func == (lhs: FlourChar, rhs: FlourChar) -> Bool {
        return lhs.charAscii == rhs.charAscii
    }

}
