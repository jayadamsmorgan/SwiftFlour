import Foundation
import curses

@MainActor
public class Scene: _PrimitiveView, Sendable {

    public var backgroundColor: FlourColor

    public init(_ views: [any View] = []) {
        self.backgroundColor = .transparent
        super.init()
        self.window = newwin(LINES, COLS, 0, 0)
        self.body = views
        for view in body {
            view.setWindow(window!)
        }
    }

    public func add<V: View>(_ view: V) {
        view.setWindow(window!)
        body.append(view)
    }

    public func setBackgroundColor(_ color: FlourColor) -> Self {
        self.backgroundColor = color
        let colorPair = getColorPair((nil, color))
        wbkgd(self.window!, UInt32(COLOR_PAIR(colorPair)))
        for view in body {
            view.setParentBackground(color)
        }
        return self
    }

    public func setBackground(_ view: View) -> Self {
        return self
    }

    public override func render() {
        wclear(window!)
        for view in body {
            view.render()
        }
        wrefresh(window!)
    }

}
