import Foundation
import Logging
import curses

@MainActor
public class App {

    // Settings
    public static var locale: String = "en_US.UTF-8"
    public static var fps: UInt = 20
    public static var quitKey: FlourChar?
    public static var disableDebug: Bool = false
    public static var disableLogging: Bool = false

    #if DEBUG
    private var debugWindow: OpaquePointer
    #endif

    public static var logger = Logger(label: "flour") {
        FileLogHandler(label: $0, filePath: $0 + ".log")
    }

    private var keyHandlers: [Int32: () -> Void] = [:]

    private static var width: Int32 = COLS

    public static func getWidth() -> Int32 {
        width
    }

    #if DEBUG
    private static var height: Int32 = LINES - 2
    #else
    private static var height: Int32 = LINES
    #endif

    public static func getHeight() -> Int32 {
        height
    }

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
        setlocale(LC_ALL, "")
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

        keypad(stdscr, true)

        #if DEBUG
        self.debugWindow = newwin(2, COLS, LINES - 2, 0)
        #endif

        initDefaultKeyHandlers()

        App.logger.info("App started.")

    }

    private func initDefaultKeyHandlers() {
        self.keyHandlers[FlourChar.arrowUp.charAscii] = {
            guard let selectedScene = self.getCurrentScene() else {
                return
            }
            SharedFocusables.shared.moveFocusable(for: selectedScene, direction: .up)
        }
        self.keyHandlers[FlourChar.arrowDown.charAscii] = {
            guard let selectedScene = self.getCurrentScene() else {
                return
            }
            SharedFocusables.shared.moveFocusable(for: selectedScene, direction: .down)
        }
        self.keyHandlers[FlourChar.arrowLeft.charAscii] = {
            guard let selectedScene = self.getCurrentScene() else {
                return
            }
            SharedFocusables.shared.moveFocusable(for: selectedScene, direction: .left)
        }
        self.keyHandlers[FlourChar.arrowRight.charAscii] = {
            guard let selectedScene = self.getCurrentScene() else {
                return
            }
            SharedFocusables.shared.moveFocusable(for: selectedScene, direction: .right)
        }
        self.keyHandlers[FlourChar.tab.charAscii] = {
            guard let selectedScene = self.getCurrentScene() else {
                return
            }
            SharedFocusables.shared.nextFocusable(for: selectedScene)
        }
        self.keyHandlers[FlourChar.shiftTab.charAscii] = {
            guard let selectedScene = self.getCurrentScene() else {
                return
            }
            SharedFocusables.shared.previousFocusable(for: selectedScene)
        }
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

            #if DEBUG
            if !App.disableDebug {
                debugLine()
            }
            #endif

            render()

            handleInput()

            napms(Int32(1.0 / Double(App.fps) * 1000))

        }
    }

    #if DEBUG
    private func debugLine() {
        wclear(debugWindow)
        let bottomLine = String(repeating: "_", count: Int(App.width))
        mvwaddstr(debugWindow, 0, 0, bottomLine)
        mvwaddstr(
            debugWindow,
            1,
            0,
            "DBG_INFO: last input: \(lastInput.charAscii),"
                + " window: (\(App.width)x\(App.height)),"
                + " cursor: (\(getcurx(window)),\(getcury(window))),"
                + " scenes: \(scenes.count),"
                + " selectedScene: \(selectedScene)"
        )
        wrefresh(debugWindow)
    }
    #endif

    public func setGlobalKeyHandler(_ char: FlourChar, handler: @escaping () -> Void) {
        keyHandlers[char.charAscii] = handler
    }

    public func setGlobalKeyHandlers(_ char: FlourChar, handlers: [() -> Void]) {
        keyHandlers[char.charAscii] = {
            for handler in handlers {
                handler()
            }
        }
    }

    public func addGlobalKeyHandler(_ char: FlourChar, handler: @escaping () -> Void, higherPriority: Bool = false) {
        guard let oldHandler = keyHandlers[char.charAscii] else {
            setGlobalKeyHandler(char, handler: handler)
            return
        }
        if higherPriority {
            keyHandlers[char.charAscii] = {
                handler()
                oldHandler()
            }
        } else {
            keyHandlers[char.charAscii] = {
                oldHandler()
                handler()
            }
        }
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

    private func getCurrentScene() -> Scene? {
        if scenes.count == 0 {
            return nil
        }
        if selectedScene < 0 || selectedScene >= scenes.count {
            return nil
        }
        return scenes[selectedScene]
    }

    private func handleResize() {
        App.width = COLS
        App.height = LINES
        #if DEBUG
        App.height -= 2
        #endif
    }
}
