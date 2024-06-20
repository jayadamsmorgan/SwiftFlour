import Darwin.ncurses
import Foundation

public struct Text: _PrimitiveView {

    public var body: [any View] = []

    internal var position: Position
    internal var width: Int32
    internal var height: Int32

    internal var foregroundColor: FlourColor?
    internal var backgroundColor: FlourColor?

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

    public func setPosition(x: Int32, y: Int32) -> Self {
        var copy = self
        copy.position = Position(x: x, y: y)
        return copy
    }

    public func setPosition(_ pair: (Int32, Int32)) -> Self {
        var copy = self
        copy.position = Position(pair)
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

    public func setForeground(_ color: FlourColor) -> Self {
        var copy = self
        copy.foregroundColor = color
        return copy
    }

    public func setBackground(_ color: FlourColor) -> Self {
        var copy = self
        copy.backgroundColor = color
        return copy
    }

    public func render() {
        if height == 0 {
            return
        }

        self.startColor((foregroundColor, backgroundColor))

        var text = self.text
        if width < text.count {
            for i in position.y..<position.y + height {
                let printText = String(text.prefix(Int(width)))
                text = String(text.dropFirst(Int(width)))
                mvaddstr(i, position.x, printText)
            }
        } else {
            mvaddstr(position.y, position.x, text)
        }

        self.endColor((foregroundColor, backgroundColor))
    }

}
