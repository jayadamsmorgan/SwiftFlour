import SwiftFlour

@main
@MainActor
public struct Example {
    public static func main() async {
        let text = Text("Hello, World!")
            .setPosition(Position(x: 10, y: 10))
            .setWidth(20)
            .setHeight(1)

        var scene = Scene()
        scene.add(text)
        App.quitKey = .q
        let app = App([scene])
        await app.run()
    }

}
