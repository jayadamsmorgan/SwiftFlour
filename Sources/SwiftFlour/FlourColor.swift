import Foundation
import curses

private enum FlourColorValue {
    case `default`
    case custom
}

public struct RGBColor: Hashable {
    public let red: Int16
    public let green: Int16
    public let blue: Int16

    private static func constraintColorValue(_ val: Int16) -> Int16 {
        if val > 1000 {
            return 1000
        } else if val < 0 {
            return 0
        }
        return val
    }

    public init(_ red: Int16, _ green: Int16, _ blue: Int16) {
        self.red = RGBColor.constraintColorValue(red)
        self.green = RGBColor.constraintColorValue(green)
        self.blue = RGBColor.constraintColorValue(blue)
    }

    public init(_ red: UInt8, _ green: UInt8, _ blue: UInt8) {
        let red: Int16 = Int16(red * 8)
        let green: Int16 = Int16(green * 8)
        let blue: Int16 = Int16(blue * 8)
        self.init(red, green, blue)
    }
}

@MainActor
public struct FlourColor: Hashable {

    fileprivate let value: FlourColorValue

    fileprivate let rgb: RGBColor

    fileprivate let color: Int16

    public static let transparent: FlourColor = FlourColor(-1)
    public static let black: FlourColor = FlourColor(0)
    public static let red: FlourColor = FlourColor(1)
    public static let green: FlourColor = FlourColor(2)
    public static let yellow: FlourColor = FlourColor(3)
    public static let blue: FlourColor = FlourColor(4)
    public static let magenta: FlourColor = FlourColor(5)
    public static let cyan: FlourColor = FlourColor(6)
    public static let white: FlourColor = FlourColor(7)

    public init(_ def: Int16) {
        App.logger.info("Created default color \(def)")
        self.value = .default
        self.color = def
        self.rgb = .init(Int16(0), 0, 0)
    }

    public static func custom(_ red: Int16, _ green: Int16, _ blue: Int16) -> FlourColor {
        App.logger.info("Creating custom color with rgb: \(red), \(green), \(blue)")
        let rgb = RGBColor(red, green, blue)
        return .init(rgb)
    }

    public static func custom(_ rgb: RGBColor) -> FlourColor {
        return .init(rgb)
    }

    public init(_ red: Int16, _ green: Int16, _ blue: Int16) {
        let rgb = RGBColor(red, green, blue)
        self.init(rgb)
    }

    public init(_ rgb: RGBColor) {
        self.rgb = rgb
        self.value = .custom
        if let color = customColors[rgb] {
            self.color = color.color
            return
        }
        self.color = 7 + Int16(customColors.count) + 1

        guard self.color < 1000 else {
            fatalError("Reached limit in creating new colors, consider reusing some.")
        }
        customColors[rgb] = self

        init_color(self.color, self.rgb.red, self.rgb.green, self.rgb.blue)
        App.logger.info(
            "Created custom color \(self.color) with rgb: \(self.rgb)"
        )
    }

}

fileprivate var customColors: [RGBColor: FlourColor] = [:]

fileprivate struct FlourColorPair: Hashable {
    let foreground: FlourColor?
    let background: FlourColor?
}

fileprivate var colorPair: [FlourColorPair: Int16] = [:]

extension View {

    fileprivate func createNewColorPair(_ pair: FlourColorPair) -> Int32 {
        let count = Int16(colorPair.count) + 1
        colorPair[pair] = count
        if let foreground = pair.foreground, let background = pair.background {
            init_pair(count, foreground.color, background.color)
        } else if let foreground = pair.foreground {
            init_pair(count, foreground.color, -1)
        } else if let background = pair.background {
            init_pair(count, -1, background.color)
        } else {
            init_pair(count, -1, -1)
        }
        return Int32(count)
    }

    internal func startColor(_ pair: (FlourColor?, FlourColor?)) {
        let pair = FlourColorPair(foreground: pair.0, background: pair.1)
        if let colorPair = colorPair[pair] {
            attron(COLOR_PAIR(Int32(colorPair)))
            return
        }
        let colorPair = createNewColorPair(pair)
        attron(COLOR_PAIR(colorPair))
        App.logger.info(
            "Color pair \(colorPair) created"
                + " with foreground \(pair.foreground?.color ?? -1)"
                + " and background \(pair.background?.color ?? -1)"
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
