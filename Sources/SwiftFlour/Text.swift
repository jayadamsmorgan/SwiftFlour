import Darwin.ncurses
import Foundation

public class Text: _PrimitiveView {

    public var body: [any View] = []

    internal var position: Position
    internal var width: Int32
    internal var height: Int32

    internal var foregroundColor: FlourColor?
    internal var backgroundColor: FlourColor?

    public var text: String

    public init(_ text: String) {
        self.text = text
        self.position = Position.zero
        self.width = Int32(text.count)
        self.height = 1
    }

    public func setPosition(_ position: Position) -> Self {
        self.position = position
        return self
    }

    public func setPosition(x: Int32, y: Int32) -> Self {
        self.position = Position(x: x, y: y)
        return self
    }

    public func setPosition(_ pair: (Int32, Int32)) -> Self {
        self.position = Position(pair)
        return self
    }

    public func setWidth(_ width: Int32) -> Self {
        self.width = width
        return self
    }

    public func setHeight(_ height: Int32) -> Self {
        self.height = height
        return self
    }

    public func setForeground(_ color: FlourColor) -> Self {
        self.foregroundColor = color
        return self
    }

    public func setBackground(_ color: FlourColor) -> Self {
        self.backgroundColor = color
        return self
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
