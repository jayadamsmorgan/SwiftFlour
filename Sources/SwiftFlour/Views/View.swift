import Darwin.ncurses
import Foundation

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

}

internal protocol _PrimitiveView: View {

    var position: Position { get set }
    var width: Int32 { get set }
    var height: Int32 { get set }

    var text: String { get set }

    func setPosition(_ position: Position) -> Self
    func setWidth(_ width: Int32) -> Self
    func setHeight(_ height: Int32) -> Self

}
