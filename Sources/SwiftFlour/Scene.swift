import Foundation

@MainActor
public struct Scene: Sendable {

    public var views: [any View] = []

    public init() {}

    public mutating func add<V: View>(_ view: V) {
        views.append(view)
    }

    public func render() {
        for view in views {
            view.render()
        }
    }

    public func processKeyHandlers(_ char: FlourChar) {
        for view in views {

        }
    }

}
