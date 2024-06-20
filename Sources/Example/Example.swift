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
        let scene2 = Scene([
            Text("Scene 2")
                .setPosition((10, 10))
                .setWidth(12)
                .setHeight(1)
                .setForeground(.magenta)
                .setBackground(.cyan),
            Text("WOW"),
        ])
        App.quitKey = .q
        App.logger.logLevel = .debug
        let app = App([scene, scene2])
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
