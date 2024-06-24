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

public class _PrimitiveView: View {

    public var window: OpaquePointer?

    public var parentBackground: FlourColor?

    public var body: [any View] = []

    internal var position: Position = Position.zero
    internal var width: Int32 = 0
    internal var height: Int32 = 0

    internal var text: String = ""

    public func render() {}

    public func setWindow(_ window: OpaquePointer) {
        self.window = window
    }

    public func setParentBackground(_ color: FlourColor) {
        self.parentBackground = color
    }

}

extension _PrimitiveView {

    public func setPosition(_ position: Position) -> Self {
        self.position = position
        return self
    }

    public func setPosition(x: Int32, y: Int32) -> Self {
        self.position = Position(x: x, y: y)
        return self
    }

    public func setX(_ x: Int32) -> Self {
        self.position.x = x
        return self
    }

    public func setY(_ y: Int32) -> Self {
        self.position.y = y
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
}
