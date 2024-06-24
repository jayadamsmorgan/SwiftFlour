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

    public func setWindow(_ window: OpaquePointer) {
        if let view = self as? _PrimitiveView {
            view.setWindow(window)
        } else {
            for child in body {
                child.setWindow(window)
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

}
