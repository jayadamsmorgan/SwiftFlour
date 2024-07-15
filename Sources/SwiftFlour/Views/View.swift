import Foundation
import curses

@MainActor
public protocol View: Sendable {
    var body: [any View] { get set }

    func render()
}

extension View {

    @MainActor
    public func render() {
        for child in body {
            child.render()
        }
    }

    public func setParentScene(_ scene: Scene) {
        if let view = self as? _PrimitiveView {
            view.setParentScene(scene)
            if let view = view as? Focusable {
                SharedFocusables.shared.addFocusable(view, for: scene)
            }
        } else {
            for child in body {
                child.setParentScene(scene)
            }
        }
    }

    public func setParentBackground(_ color: FlourColor) {
        if let view = self as? _PrimitiveView {
            view.setParentBackground(color)
        } else {
            for child in body {
                child.setParentBackground(color)
            }
        }
    }

    public func printString(_ str: String, position: Position, window: OpaquePointer? = nil) {
        if let window {
            mvwaddstr(window, position.y, position.x, str)
        } else {
            mvaddstr(position.y, position.x, str)
        }
    }

    public func printString(_ str: String, position: (Int32, Int32), window: OpaquePointer? = nil) {
        let position = Position(position)
        printString(str, position: position, window: window)
    }

}
