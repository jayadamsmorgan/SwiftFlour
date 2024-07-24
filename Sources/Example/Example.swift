import SwiftFlour

@main
@MainActor
public struct Example {

    class FirstView: View {

        static var progressView = ProgressView(size: 3)
            .setPosition((100, 30))

        public var body: [any View] = [
            Text("Hello, World!")
                .setPosition((10, 10))
                .setMaxWidth(12)
                .setHeight(1)
                .setForeground(.magenta)
                .setBackground(.cyan)
                .withBorder(color: .rgb255(255, 0, 0)),
            Box()
                .setColor(.rgb1000(500, 1000, 750))
                .setHeight(13)
                .setPosition((20, 20))
                .withBorder(verticalPadding: 2, horizontalPadding: 4),
            Button(
                "BUTTON",
                { button in
                    button.setText(button.getText() == "BUTTON" ? "WOW" : "BUTTON")
                    progressView.toggleStartStop()
                }
            )
            .setPosition((80, 10)),
            Button("BUTTON2")
                .setPosition((80, 15)),
            Button("BUTTON3")
                .setPosition((100, 10)),
            Button("BUTTON4")
                .setPosition((100, 15)),
            Text("WOW")
                .setForeground(.rgb255(0, 180, 255)),
            Checkbox(style: .smallRounded)
                .setPosition((60, 20)),
            Input(placeholder: "placeholderplaceholder")
                .setPosition((80, 20))
                .withBorder(),
            SecureInput(placeholder: "password")
                .setPosition((80, 30))
                .withBorder(),
            List(
                [
                    Text("WOW"), Text("WOW2"), Text("WOW3"),
                ],
                spacing: 3,
                direction: .horizontal
            )
            .setPosition((120, 20)),
            progressView,
        ]
    }

    public static func main() async {
        App.logger.logLevel = .debug
        App.fps = 120
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
        App.quitKey = .escape

        app.addGlobalKeyHandler(FlourChar("d")) {
            app.scenes.removeLast()
        }
        app.addGlobalKeyHandler(FlourChar("a")) {
            app.scenes.append(scene2)
        }
        app.addGlobalKeyHandler(FlourChar("]"), handler: app.nextScene)
        app.addGlobalKeyHandler(FlourChar("["), handler: app.previousScene)
        app.addGlobalKeyHandler(FlourChar("i")) {
            app.scenes[0].add(Text("TEST"))
        }

        await app.run()
    }

}
