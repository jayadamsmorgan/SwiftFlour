import Foundation
import curses

public enum ButtonStyle {
    case textOnly
    case colored
    case custom(border: ButtonBorderStyle = .disabled, color: FlourColor? = nil)
}

public enum ButtonBorderStyle {
    case disabled
    case enabled(horizontalPadding: Int32 = 1, verticalPadding: Int32 = 1)
}

public class Button: Text, Focusable {

    private let id = UUID()

    private var buttonStyle: ButtonStyle

    private var buttonIsPressed: Bool = false

    private var buttonJustPressed: Bool = false

    internal var isFocused: Bool = false

    public init(_ text: String, style: ButtonStyle = .textOnly) {
        self.buttonStyle = style
        super.init(text)
    }

    public init(_ text: String, style: ButtonStyle = .textOnly, _ onClick: @escaping () -> Void) {
        self.buttonStyle = style
        super.init(text)
        self.setOnClick(onClick)
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

    public func setOnClick(_ onClick: @escaping () -> Void) {
        App.addButtonHandler(for: self, handler: onClick)
    }

}

extension Button: Equatable {

    public static func == (lhs: Button, rhs: Button) -> Bool {
        return lhs.id == rhs.id
    }

}

extension Button: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

}