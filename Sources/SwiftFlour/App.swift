import Foundation

public struct App: Sendable {

    public var scenes: [Scene]

    public init(scenes: [Scene]) {
        self.scenes = scenes
    }

    internal func render() {
        for scene in scenes {
            scene.render()
        }
    }

}
