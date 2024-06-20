import Darwin.ncurses
import Foundation

@MainActor
public class App {

    // Settings
    public static var locale: String = "en_US.UTF-8"
    public static var fps: UInt = 30
    public static var quitKey: FlourChar?
    public static var disableDebug: Bool = false

    private static var keyHandlers: [FlourChar: () -> Void] = [:]

    private var width: Int32 = COLS
    private var height: Int32 = LINES

    public var scenes: [Scene]

    public var selectedScene: Int = 0

    private var quit: Bool = false

    private let window: OpaquePointer

    private var lastInput = FlourChar(0)

    public init(_ scenes: [Scene]) {
        self.scenes = scenes
        setlocale(LC_CTYPE, App.locale)
        window = initscr()
        noecho()
        nodelay(window, true)
        curs_set(0)
        use_default_colors()
        start_color()
    }

    private func render() {
        if scenes.count == 0 {
            return
        }
        if selectedScene >= scenes.count || selectedScene < 0 {
            return
        }
        scenes[selectedScene].render()
    }

    public func run() async {
        defer {
            endwin()
        }
        while !quit {

            erase()

            handleResize()

            render()

            #if DEBUG
            if !App.disableDebug {
                debugLine()
            }
            #endif

            handleInput()

            refresh()

            napms(Int32(1.0 / Double(App.fps) * 1000))

        }
    }

    private func debugLine() {
        let bottomLine = String(repeating: "_", count: Int(width))
        mvaddstr(LINES - 2, 0, bottomLine)
        mvaddstr(
            LINES - 1,
            0,
            "DBG_INFO: last input: \(lastInput.charAscii),"
                + " window: (\(width)x\(height)),"
                + " cursor: (\(getcurx(window)),\(getcury(window))),"
                + " scenes: \(scenes.count),"
                + " selectedScene: \(selectedScene)"
        )
    }

    public static func addGlobalKeyHandler(_ char: FlourChar, handler: @escaping () -> Void) {
        keyHandlers[char] = handler
    }

    public func _quit() {
        quit = true
    }

    private func handleInput() {
        let input = getch()
        if input == -1 {
            return
        }
        lastInput = FlourChar(input)
        if lastInput == App.quitKey {
            _quit()
            return
        }
        if scenes.count == 0 {
            return
        }
        if selectedScene < 0 || selectedScene >= scenes.count {
            return
        }

        processGlobalKeyHandlers(lastInput)
    }

    private func processGlobalKeyHandlers(_ input: FlourChar) {
        if let handler = App.keyHandlers[input] {
            handler()
        }
    }

    private func handleResize() {
        width = COLS
        height = LINES
        #if DEBUG
        height -= 2
        #endif
    }
}
