import Foundation

public struct FlourChar: Equatable, Sendable, Hashable {

    public static let q = FlourChar("q")

    public static let arrowUp = FlourChar(259)
    public static let arrowDown = FlourChar(258)
    public static let arrowLeft = FlourChar(260)
    public static let arrowRight = FlourChar(261)

    public static let escape = FlourChar(27)
    public static let tab = FlourChar(9)
    public static let enter = FlourChar(10)
    public static let backspace = FlourChar(263)

    public static let space = FlourChar(32)

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
