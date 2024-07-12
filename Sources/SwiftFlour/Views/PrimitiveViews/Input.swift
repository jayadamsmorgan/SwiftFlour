import Foundation
import curses

public class Input: Text, Focusable {
    public var value: String = ""
    public var placeholder: String = ""

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

    // public var placeholderForeground: FlourColor = .custom(.init(UInt8(30), 30, 30))  // gray color
    public var placeholderForeground: FlourColor = .red

    public var focusedBackground: FlourColor = .blue
    public var focusedForeground: FlourColor = .white

    public var cursorPos: Position { Position((self.position.x + Int32(value.count), self.position.y)) }

    public init(placeholder: String = "") {
        onPress = {}
        super.init(placeholder)
        self.width = 15
    }

    public override func render() {
        self.text = isFocused ? value : (value.count == 0 ? placeholder : value)
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
