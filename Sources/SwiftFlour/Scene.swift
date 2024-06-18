import Foundation

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

}
