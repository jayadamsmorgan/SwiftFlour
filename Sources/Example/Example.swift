import SwiftFlour

@main
@MainActor
public struct Example {

    public static func main() async {
        App.logger.logLevel = .debug
        let app = App()

        let scene = Scene([
            Text("Hello, World!")
                .setPosition((10, 10))
                .setWidth(12)
                .setHeight(1)
                .setForeground(.magenta)
                .setBackground(.cyan),
            Box()
                .setColor(.rgb1000(500, 1000, 750))
                .setHeight(13)
                .setPosition((20, 20)),
            Text("WOW")
                .setForeground(.rgb255(0, 180, 255)),
        ])

        let scene2 = Scene([
            Text("Scene 2")
                .setPosition((10, 10))
                .setWidth(12)
                .setHeight(1)
                .setForeground(.magenta)
                .setBackground(.cyan),
            Text("WOW"),
        ])
        .setBackgroundColor(.green)

        app.scenes = [scene, scene2]
        App.quitKey = .q

        app.addGlobalKeyHandler(FlourChar("d")) {
            app.scenes.removeLast()
        }
        app.addGlobalKeyHandler(FlourChar("a")) {
            app.scenes.append(scene2)
        }
        app.addGlobalKeyHandler(FlourChar("]")) {
            app.selectedScene += 1
        }
        app.addGlobalKeyHandler(FlourChar("[")) {
            app.selectedScene -= 1
        }
        app.addGlobalKeyHandler(FlourChar("i")) {
            app.scenes[0].add(Text("TEST"))
        }

        await app.run()
    }

}
