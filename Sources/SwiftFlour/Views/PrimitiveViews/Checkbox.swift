import Foundation
import curses

/*
┌─┐
│*│ // 1st style
└─┘

( ) (*) // 2nd style
[ ] [*] // 3rd style

*/

public enum CheckboxStyle: Equatable {
    case smallRounded
    case smallSquared
    case customSmall(leftSideChar: FlourChar, rightSideChar: FlourChar, selectChar: FlourChar)
    case bigSquared
    //tba
}
public class Checkbox: Text, Focusable {

    internal var isFocused: Bool = false
    internal var onPress: () -> Void = {}

    public let style: CheckboxStyle
    public var isChecked: Bool = false

    internal var cursorPos: Position {
        if style == .bigSquared {
            return Position((self.position.x + 1, self.position.y + 1))
        } else {
            return Position((self.position.x + 1, self.position.y))
        }
    }

    public init(style: CheckboxStyle = .smallSquared) {
        self.style = style
        if self.style == .bigSquared {
            super.init(String(repeating: " ", count: 9))
            self.height = 3
            self.width = 3
        } else {
            super.init("   ")
        }
        onPress = { self.isChecked.toggle() }
    }

    public override func render() {
        switch style {
        case .smallSquared:
            self.text = isChecked ? "[x]" : "[ ]"
        case .bigSquared:
            self.text = isChecked ? "┌─┐│x│└─┘" : "┌─┐│ │└─┘"
        case .smallRounded:
            self.text = isChecked ? "(*)" : "( )"
        case .customSmall(let leftSideChar, let rightSideChar, let selectChar):
            self.text =
                isChecked
                ? "\(leftSideChar.char) \(rightSideChar.char)"
                : "\(leftSideChar.char)\(selectChar.char)\(rightSideChar.char)"
        }
        if self.isFocused, let window = self.parentScene?.window {
            if SharedFocusables.shared.focusableSelectStyle == .bordered {
                renderBorder(
                    window: window,
                    viewPosition: position,
                    viewWidth: width,
                    viewHeight: height,
                    verticalPadding: 1,
                    horizontalPadding: 1
                )
            }
        }
        super.render()
    }

    public func overrideOnPress(onPress: @escaping () -> Void) {
        self.onPress = onPress
    }

}
