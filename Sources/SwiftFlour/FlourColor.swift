import Foundation
import curses

private enum FlourColorValue {
    case `default`
    case custom
}

public struct RGBColor: Hashable, Sendable {
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
        let red = Int16(red) * 3
        let green = Int16(green) * 3
        let blue = Int16(blue) * 3
        self.init(red, green, blue)
    }
}

@MainActor
public struct FlourColor: Hashable, Sendable {

    fileprivate let value: FlourColorValue

    fileprivate let rgb: RGBColor

    internal let color: Int16

    public static let transparent: FlourColor = FlourColor(-1)
    public static let black: FlourColor = FlourColor(0)
    public static let red: FlourColor = FlourColor(1)
    public static let green: FlourColor = FlourColor(2)
    public static let yellow: FlourColor = FlourColor(3)
    public static let blue: FlourColor = FlourColor(4)
    public static let magenta: FlourColor = FlourColor(5)
    public static let cyan: FlourColor = FlourColor(6)
    public static let white: FlourColor = FlourColor(7)

    private init(_ def: Int16) {
        App.logger.info("Created default color \(def)")
        self.value = .default
        self.color = def
        self.rgb = .init(Int16(0), 0, 0)
    }

    public static func rgb1000(_ red: Int16, _ green: Int16, _ blue: Int16) -> FlourColor {
        let rgb = RGBColor(red, green, blue)
        return .init(rgb)
    }

    public static func rgb255(_ red: UInt8, _ green: UInt8, _ blue: UInt8) -> FlourColor {
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

    public init(_ red: UInt8, _ green: UInt8, _ blue: UInt8) {
        let rgb = RGBColor(red, green, blue)
        self.init(rgb)
    }

    public init(_ rgb: RGBColor) {
        App.logger.info("Creating custom color with rgb: \(rgb.red), \(rgb.green), \(rgb.blue)")
        self.rgb = rgb
        self.value = .custom
        if let color = customColors[rgb] {
            self.color = color.color
            return
        }
        self.color = 16 + Int16(customColors.count)

        guard can_change_color() else {
            App.logger.info("Terminal does not support changing colors.")
            return
        }

        guard self.color < 256 else {
            App.logger.error("Reached limit in creating custom colors, consider reusing some.")
            return
        }

        customColors[rgb] = self

        let status = init_color(self.color, self.rgb.red, self.rgb.green, self.rgb.blue)
        if status == ERR {
            App.logger.error(
                "Cannot init RGB Color, terminal might not support it or the color was created before app initialization."
            )
        } else {
            App.logger.info(
                "Created custom color \(self.color) with rgb: \(self.rgb)"
            )
        }
    }

    public nonisolated static func == (lhs: FlourColor, rhs: FlourColor) -> Bool {
        return lhs.value == rhs.value && lhs.color == rhs.color
    }

}

fileprivate var customColors: [RGBColor: FlourColor] = [:]

fileprivate struct FlourColorPair: Hashable {
    let foreground: FlourColor?
    let background: FlourColor?
}

fileprivate var colorPair: [FlourColorPair: Int16] = [:]

extension View {

    internal func getColorPair(_ pair: (FlourColor?, FlourColor?)) -> Int32 {
        let pair = FlourColorPair(foreground: pair.0, background: pair.1)

        if let colorPair = colorPair[pair] {
            return Int32(colorPair)
        }

        return createNewColorPair(pair)
    }

    fileprivate func createNewColorPair(_ pair: FlourColorPair) -> Int32 {
        let count = Int16(colorPair.count) + 1
        colorPair[pair] = count
        let foreground = pair.foreground?.color ?? -1
        let background = pair.background?.color ?? -1
        init_pair(count, foreground, background)
        App.logger.info(
            "New color pair created"
                + " with foreground \(foreground)"
                + " and background \(background)"
        )
        return Int32(count)
    }

    internal func startColor(_ pair: (FlourColor?, FlourColor?)) {

        let colorPair = getColorPair(pair)

        attron(COLOR_PAIR(colorPair))
    }

    internal func startColor(_ pair: (FlourColor?, FlourColor?), window: OpaquePointer) {

        let colorPair = getColorPair(pair)

        wattron(window, COLOR_PAIR(colorPair))
    }

    internal func endColor(_ pair: (FlourColor?, FlourColor?)) {
        let pair = FlourColorPair(foreground: pair.0, background: pair.1)
        if let colorPair = colorPair[pair] {
            attroff(COLOR_PAIR(Int32(colorPair)))
        } else {
            App.logger.error("Tried to end color pair which was not created.")
        }
    }

    internal func endColor(_ pair: (FlourColor?, FlourColor?), window: OpaquePointer) {
        let pair = FlourColorPair(foreground: pair.0, background: pair.1)
        if let colorPair = colorPair[pair] {
            wattroff(window, COLOR_PAIR(Int32(colorPair)))
        } else {
            App.logger.error("Tried to end color pair which was not created.")
        }
    }

}
