import Foundation
import curses

public class Input: Text, Focusable {
    public var value: String = ""
    public var placeholder: String

    private var isFocusedHolder = false
    private var justFocused: Bool = false
    internal var isFocused: Bool {
        get { isFocusedHolder }
        set {
            if !isFocusedHolder && newValue {
                justFocused = true
            }
            isFocusedHolder = newValue
        }
    }

    public var onValueChange: ((String) -> Void)?
    public var onEnter: (() -> Void)?
    internal var onPress: () -> Void

    public var placeholderForeground: FlourColor = .rgb255(177, 177, 177)

    public var focusedBackground: FlourColor = .blue
    public var focusedForeground: FlourColor = .white

    public var cursorPos: Position {
        Position((self.position.x + Int32(self.text.count), self.position.y))
    }

    public init(placeholder: String = "") {
        onPress = {}
        self.placeholder = placeholder
        super.init("")
        self.width = 15
    }

    public override func render() {
        self.text = isFocused ? value : (value.count == 0 ? placeholder : value)
        if value.count == 0 && !isFocused {
            self.text = String(self.text.prefix(Int(self.width)))
            let window = self.parentScene?.window
            if borderEnabled {
                renderBorder()
            }
            var backgroundColor = self.backgroundColor
            if backgroundColor == .transparent, let parentBackground {
                backgroundColor = parentBackground
            }
            startColor((placeholderForeground, backgroundColor), window: window)
            printString(self.text, position: self.position, window: window)
            endColor((placeholderForeground, backgroundColor), window: window)
            return
        }
        if self.text.count > self.width {
            self.text = String(self.text.suffix(Int(self.width)))
        }
        super.render()
    }

    internal func handleInput(_ key: FlourChar) {
        if isFocused {
            if justFocused {
                justFocused = false
                return
            }
            switch key {
            case .enter:
                onEnter?()
            case .backspace:
                value = String(value.dropLast())
                onValueChange?(value)
            case .arrowUp, .arrowDown, .arrowLeft, .arrowRight:
                return
            default:
                value.append(Character(UnicodeScalar(Int(key.charAscii))!))
                onValueChange?(value)
            }
        }
    }

    public func setPlaceholder(_ placeholder: String) -> Self {
        self.placeholder = placeholder
        return self
    }

}
