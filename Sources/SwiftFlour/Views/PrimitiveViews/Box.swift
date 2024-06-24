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

        if let window {
            startColor((nil, color), window: window)
        } else {
            startColor((nil, color))
        }
        for i in position.y..<position.y + height {
            if window != nil {
                mvwaddstr(window!, i, position.x, String(repeating: " ", count: Int(width)))
            } else {
                mvaddstr(i, position.x, String(repeating: " ", count: Int(width)))
            }
        }
        if let window {
            endColor((nil, color), window: window)
        } else {
            endColor((nil, color))
        }
    }

}
