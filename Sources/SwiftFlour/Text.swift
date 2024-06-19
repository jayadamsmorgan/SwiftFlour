import Darwin.ncurses
import Foundation

public struct Text: _PrimitiveView {

    public var body: [any View] = []

    internal var position: Position
    internal var width: Int32
    internal var height: Int32

    public var text: String
    internal var data: Data {
        get {
            text.data(using: .utf8)!
        }
        set {
            text = String(data: newValue, encoding: .utf8)!
        }
    }

    public init(_ text: String) {
        self.text = text
        self.position = Position.zero
        self.width = Int32(text.count)
        self.height = 1
    }

    public func setPosition(_ position: Position) -> Self {
        var copy = self
        copy.position = position
        return copy
    }

    public func setWidth(_ width: Int32) -> Self {
        var copy = self
        copy.width = width
        return copy
    }

    public func setHeight(_ height: Int32) -> Self {
        var copy = self
        copy.height = height
        return copy
    }

    public func render() {
        mvaddstr(position.y, position.x, text)
    }

}
