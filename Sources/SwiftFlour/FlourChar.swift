import Foundation

public struct FlourChar: Equatable, Sendable, Hashable {

    public static let q = FlourChar("q")

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
