import Foundation
import curses

public enum ButtonStyle {
    case textOnly
    case colored
    case bordered
    case custom(border: ButtonBorderStyle = .disabled, color: FlourColor? = nil)
}

public enum ButtonBorderStyle {
    case disabled
    case enabled(horizontalPadding: Int32 = 1, verticalPadding: Int32 = 1)
}

public class Button: Text, Focusable {

    private var buttonStyle: ButtonStyle

    private var buttonIsPressed: Bool = false

    private var buttonJustPressed: Bool = false

    internal var isFocused: Bool = false
    internal var onPress: () -> Void = {}

    internal var cursorPos: Position { self.position }

    public init(_ text: String, style: ButtonStyle = .textOnly) {
        self.buttonStyle = style
        super.init(text)
    }

    public init(_ text: String, style: ButtonStyle = .textOnly, _ onClick: @escaping (Button) -> Void) {
        self.buttonStyle = style
        super.init(text)
        self.onPress = {
            onClick(self)
        }
    }

    public override func render() {
        if isFocused {
            renderFocused()
        } else {
            renderUnfocused()
        }
        super.render()
    }

    private func renderUnfocused() {

    }

    private func renderFocused() {
        if SharedFocusables.shared.focusableSelectStyle == .bordered {
            if let window = self.parentScene?.window {
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
    }

    public func setOnClick(_ onClick: @escaping (Button) -> Void) {
        self.onPress = {
            onClick(self)
        }
    }

}
