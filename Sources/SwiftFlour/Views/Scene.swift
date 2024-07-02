import Foundation
import curses

@MainActor
public class Scene: _PrimitiveView, Sendable {

    private var id: UUID = UUID()

    internal var window: OpaquePointer?

    public var backgroundColor: FlourColor

    public init(_ views: [any View] = []) {
        self.backgroundColor = .transparent
        super.init()
        self.width = COLS
        #if DEBUG
        self.height = LINES - 2
        self.window = newwin(LINES - 2, COLS, 0, 0)
        #else
        self.height = LINES
        self.window = newwin(LINES, COLS, 0, 0)
        #endif
        self.body = views
        for view in body {
            view.setParentScene(self)
        }
    }

    public func add<V: View>(_ view: V) {
        view.setParentScene(self)
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
        if borderEnabled {
            renderBorder()
        }
        for view in body {
            view.render()
        }
        wrefresh(window!)
    }

}

extension Scene: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Scene: Equatable {
    public static func == (lhs: Scene, rhs: Scene) -> Bool {
        return lhs.id == rhs.id
    }
}
