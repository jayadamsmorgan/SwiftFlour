import Foundation

public struct Position: Sendable {

    public static let zero: Position = Position((0, 0))

    public var x: Int32
    public var y: Int32

    public init(x: Int32 = 0, y: Int32 = 0) {
        self.x = x
        self.y = y
    }

    public init(x: Int = 0, y: Int = 0) {
        if x > INT32_MAX {
            self.x = INT32_MAX
        } else {
            self.x = Int32(x)
        }
        if y > INT32_MAX {
            self.y = INT32_MAX
        } else {
            self.y = Int32(y)
        }
    }

    public init(_ pair: (Int32, Int32)) {
        self.init(x: pair.0, y: pair.1)
    }

    public init(_ pair: (Int, Int)) {
        self.init(x: pair.0, y: pair.1)
    }
}

extension Position: Equatable {
    public static func == (lhs: Position, rhs: Position) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    public static func < (lhs: Position, rhs: Position) -> Bool {
        if lhs.y < rhs.y {
            return true
        }
        if lhs.y == rhs.y {
            return lhs.x < rhs.x
        }
        return false
    }

    public static func <= (lhs: Position, rhs: Position) -> Bool {
        return lhs == rhs || lhs < rhs
    }

    public static func > (lhs: Position, rhs: Position) -> Bool {
        if lhs.y > rhs.y {
            return true
        }
        if lhs.y == rhs.y {
            return lhs.x > rhs.x
        }
        return false
    }

    public static func >= (lhs: Position, rhs: Position) -> Bool {
        return lhs == rhs || lhs > rhs
    }
}

extension Position: Hashable {

}
