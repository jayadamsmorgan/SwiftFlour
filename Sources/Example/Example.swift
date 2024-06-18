import SwiftFlour

@main
@MainActor
public struct Example {
    public static func main() {
        let text = Text("Hello, World!")
            .setPosition(Position(x: 10, y: 10))
            .setWidth(20)
            .setHeight(1)

        let ui = UI()
        var scene = Scene()
        scene.add(text)
        let app = App(scenes: [scene])
        ui.run(app)
    }

}
