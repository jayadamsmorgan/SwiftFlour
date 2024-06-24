import Foundation
import Logging
import curses

@MainActor
public class App {

    // Settings
    public static var locale: String = "en_US.UTF-8"
    public static var fps: UInt = 30
    public static var quitKey: FlourChar?
    public static var disableDebug: Bool = false
    public static var disableLogging: Bool = false

    public static var logger = Logger(label: "flour") {
        FileLogHandler(label: $0, filePath: $0 + ".log")
    }

    private var keyHandlers: [Int32: () -> Void] = [:]

    private var width: Int32 = COLS
    private var height: Int32 = LINES

    public var scenes: [Scene]

    public var selectedScene: Int = 0

    private var quit: Bool = false

    private let window: OpaquePointer

    private var lastInput = FlourChar(0)

    public convenience init() {
        self.init([])
    }

    public init(_ scenes: [Scene]) {
        self.scenes = scenes
        setlocale(LC_CTYPE, App.locale)
        window = initscr()
        noecho()
        nodelay(window, true)
        curs_set(0)

        if has_colors() {
            start_color()
            use_default_colors()
        } else {
            App.logger.warning("Terminal does not support colors.")
        }

        App.logger.info("App started.")

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

            handleResize()

            render()

            #if DEBUG
            if !App.disableDebug {
                debugLine()
            }
            #endif

            handleInput()

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

    public func addGlobalKeyHandler(_ char: FlourChar, handler: @escaping () -> Void) {
        keyHandlers[char.charAscii] = handler
    }

    public func removeGlobalKeyHandler(_ char: FlourChar) {
        keyHandlers.removeValue(forKey: char.charAscii)
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
        processGlobalKeyHandlers(lastInput)
    }

    private func processGlobalKeyHandlers(_ input: FlourChar) {
        if let handler = keyHandlers[input.charAscii] {
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
