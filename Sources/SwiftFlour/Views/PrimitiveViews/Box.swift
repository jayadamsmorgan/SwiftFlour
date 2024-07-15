import Foundation
import curses

public class Box: _PrimitiveView {

    override public init() {
        super.init()
        self.width = 30
        self.height = 15
        self.text = String(repeating: " ", count: Int(width * height))
        self.position = Position.zero
    }

    var color: FlourColor = .red

    public func setColor(_ color: FlourColor) -> Self {
        self.color = color
        return self
    }

    override public func render() {

        if borderEnabled {
            renderBorder()
        }

        let window = parentScene?.window

        startColor((nil, color), window: window)
        for i in position.y..<position.y + height {
            printString(
                String(repeating: " ", count: Int(width)),
                position: (position.x, i),
                window: window
            )
        }
        endColor((nil, color), window: window)
        super.render()
    }

}
