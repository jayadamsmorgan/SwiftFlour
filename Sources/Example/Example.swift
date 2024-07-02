import SwiftFlour

@main
@MainActor
public struct Example {

    class FirstView: View {
        public var body: [any View] = [
            Text("Hello, World!")
                .setPosition((10, 10))
                .setWidth(12)
                .setHeight(1)
                .setForeground(.magenta)
                .setBackground(.cyan)
                .withBorder(color: .rgb255(255, 0, 0)),
            Box()
                .setColor(.rgb1000(500, 1000, 750))
                .setHeight(13)
                .setPosition((20, 20))
                .withBorder(verticalPadding: 2, horizontalPadding: 4),
            Button("BUTTON")
                .setPosition((80, 10)),
            Button("BUTTON2")
                .setPosition((80, 15)),
            Button("BUTTON3")
                .setPosition((100, 10)),
            Button("BUTTON4")
                .setPosition((100, 15)),
            Text("WOW")
                .setForeground(.rgb255(0, 180, 255)),
        ]
    }

    public static func main() async {
        App.logger.logLevel = .debug
        let app = App()

        let scene = Scene([FirstView()])
            .withBorder(color: .rgb255(0, 255, 0))

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
            if app.selectedScene < app.scenes.count - 1 {
                app.selectedScene += 1
            }
        }
        app.addGlobalKeyHandler(FlourChar("[")) {
            if app.selectedScene > 0 {
                app.selectedScene -= 1
            }
        }
        app.addGlobalKeyHandler(FlourChar("i")) {
            app.scenes[0].add(Text("TEST"))
        }

        await app.run()
    }

}
