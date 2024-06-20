import SwiftFlour

@main
@MainActor
public struct Example {
    public static func main() async {

        let scene = Scene([
            Text("Hello, World!")
                .setPosition((10, 10))
                .setWidth(12)
                .setHeight(1)
                .setForeground(.magenta)
                .setBackground(.cyan),
            Text("WOW"),
        ])
        App.quitKey = .q
        let app = App([scene])
        await app.run()
    }

}
