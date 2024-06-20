import Foundation

public enum FlourColor: Int16, RawRepresentable {
    case transparent = -1

    case black = 0
    case red = 1
    case green = 2
    case yellow = 3
    case blue = 4
    case magenta = 5
    case cyan = 6
    case white = 7
}

private struct FlourColorPair: Hashable {
    let foreground: FlourColor?
    let background: FlourColor?
}

fileprivate var colorPair: [FlourColorPair: Int16] = [:]

extension View {

    internal func startColor(_ pair: (FlourColor?, FlourColor?)) {
        let pair = FlourColorPair(foreground: pair.0, background: pair.1)
        if let colorPair = colorPair[pair] {
            attron(COLOR_PAIR(Int32(colorPair)))
            return
        }
        let count = Int16(colorPair.count) + 1
        colorPair[pair] = count
        if let foreground = pair.foreground, let background = pair.background {
            init_pair(count, foreground.rawValue, background.rawValue)
        } else if let foreground = pair.foreground {
            init_pair(count, foreground.rawValue, -1)
        } else if let background = pair.background {
            init_pair(count, -1, background.rawValue)
        } else {
            init_pair(count, -1, -1)
        }
        attron(COLOR_PAIR(Int32(count)))
        App.logger.debug(
            "Color pair \(count) created"
                + " with foreground \(pair.foreground?.rawValue ?? -1)"
                + " and background \(pair.background?.rawValue ?? -1)"
        )
    }

    internal func endColor(_ pair: (FlourColor?, FlourColor?)) {
        let pair = FlourColorPair(foreground: pair.0, background: pair.1)
        if let colorPair = colorPair[pair] {
            attroff(COLOR_PAIR(Int32(colorPair)))
        } else {
            App.logger.error("Tried to end color pair which was not created.")
        }
    }

}
