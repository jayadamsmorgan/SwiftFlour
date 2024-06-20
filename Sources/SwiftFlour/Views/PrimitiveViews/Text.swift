import Darwin.ncurses
import Foundation

public class Text: _PrimitiveView {

    internal var foregroundColor: FlourColor?
    internal var backgroundColor: FlourColor?

    public init(_ text: String) {
        super.init()
        self.text = text
        self.position = Position.zero
        self.width = Int32(text.count)
        self.height = 1
    }

    public func setForeground(_ color: FlourColor) -> Self {
        self.foregroundColor = color
        return self
    }

    public func setBackground(_ color: FlourColor) -> Self {
        self.backgroundColor = color
        return self
    }

    override public func render() {
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
