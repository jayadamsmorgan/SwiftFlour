import Darwin.ncurses
import Foundation

@MainActor
public class UI {

    private var width: Int32
    private var height: Int32

    public init() {
        setlocale(LC_CTYPE, "en_US.UTF-8")
        let window = initscr()
        width = getmaxx(window)
        height = getmaxy(window)
        noecho()
        curs_set(0)
        use_default_colors()
    }

    public func run(_ app: App) {
        defer {
            endwin()
        }
        while true {
            erase()
            refresh()
            app.render()
            let ch = getch()
            if ch == 113 {  // 'q' to quit
                break
            }
        }
    }
}
