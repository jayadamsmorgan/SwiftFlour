import Foundation
import curses

public class Text: _PrimitiveView {

    internal var foregroundColor: FlourColor?
    internal var backgroundColor: FlourColor? = .transparent

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

        if borderEnabled {
            renderBorder()
        }

        if height == 0 {
            return
        }

        var backgroundColor = self.backgroundColor
        if backgroundColor == .transparent, let parentBackground {
            backgroundColor = parentBackground
        }

        let window = parentScene?.window

        self.startColor((foregroundColor, backgroundColor), window: window)

        var text = self.text
        if width < text.count {
            for i in position.y..<position.y + height {
                let printText = String(text.prefix(Int(width)))
                text = String(text.dropFirst(Int(width)))
                printString(printText, position: (position.x, i), window: window)
            }
        } else {
            printString(text, position: position, window: window)
        }

        self.endColor((foregroundColor, backgroundColor), window: window)
        super.render()

    }

}
