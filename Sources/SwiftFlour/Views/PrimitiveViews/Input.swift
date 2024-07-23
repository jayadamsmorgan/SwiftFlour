import Foundation
import curses

public class Input: Text, Focusable {
    public var value: String = ""
    public var placeholder: String

    private var isFocusedHolder = false
    internal var justFocused: Bool = false
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
    internal var onPress: () -> Void = {}

    public var placeholderForeground: FlourColor = .rgb255(177, 177, 177)

    public var focusedBackground: FlourColor = .blue
    public var focusedForeground: FlourColor = .white

    public var cursorPos: Position {
        Position((self.position.x + (Int32(self.text.count)), self.position.y))
    }

    public init(placeholder: String = "") {
        onPress = {}
        self.placeholder = placeholder
        super.init(placeholder)
        self.minWidth = 15
        self.minHeight = 1
        self.maxWidth = 20
        updateLines()
    }

    public init(placeholder: String = "", _ onClick: @escaping (Input) -> Void) {
        self.placeholder = placeholder
        super.init(placeholder)
        self.minWidth = 15
        self.minHeight = 1
        onPress = {
            onClick(self)
        }
        updateLines()
    }

    public override func render() {
        if isFocused || value.count != 0 {
            self.text = value
            updateLines()
            super.render()
        } else {
            self.text = placeholder
            let lastForeground = self.foregroundColor
            self.foregroundColor = placeholderForeground
            updateLines()
            super.render()
            self.foregroundColor = lastForeground
        }
    }

    internal func handleInput(_ key: FlourChar) {
        if isFocused {
            if justFocused {
                justFocused = false
                return
            }
            switch key {
            case .enter:
                onPress()
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
