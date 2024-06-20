import Foundation

@MainActor
public class Scene: Sendable {

    public var views: [any View]

    public init(_ views: [any View] = []) {
        self.views = views
    }

    public func add<V: View>(_ view: V) {
        views.append(view)
    }

    public func render() {
        for view in views {
            view.render()
        }
    }

}
