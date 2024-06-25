import Foundation
import curses

public enum BorderType {
    case singleLine
    case custom(
        leftSide: Character,
        rightSide: Character,
        topSide: Character,
        bottomSide: Character,
        topLeft: Character,
        topRight: Character,
        bottomLeft: Character,
        bottomRight: Character
    )
}

public extension View {

    func renderBorder(
        window: OpaquePointer,
        style: BorderType = .singleLine,
        viewPosition: Position,
        viewWidth: Int32,
        viewHeight: Int32,
        verticalPadding: Int32,
        horizontalPadding: Int32
    ) {
        switch style {
        case .singleLine:
            let leftSide = "│"
            let rightSide = leftSide
            let topSide = "─"
            let bottomSide = topSide
            let topLeft = "┌"
            let topRight = "┐"
            let bottomLeft = "└"
            let bottomRight = "┘"

            let top =
                topLeft + String(repeating: topSide, count: Int(viewWidth - 2) + Int(horizontalPadding) * 2) + topRight
            let bottom =
                bottomLeft + String(repeating: bottomSide, count: Int(viewWidth - 2) + Int(horizontalPadding) * 2)
                + bottomRight

            for y in viewPosition.y - verticalPadding..<viewPosition.y + viewHeight + verticalPadding {
                if y == viewPosition.y - verticalPadding {
                    mvwaddstr(window, y, Int32(viewPosition.x - horizontalPadding), top)
                } else if y == viewPosition.y + viewHeight - 1 + verticalPadding {
                    mvwaddstr(window, y, Int32(viewPosition.x - horizontalPadding), bottom)
                } else {
                    mvwaddstr(window, y, viewPosition.x - horizontalPadding, leftSide)
                    mvwaddstr(window, y, viewPosition.x + viewWidth - 1 + horizontalPadding, rightSide)
                }
            }

            break
        case .custom(
            let leftSide,
            let rightSide,
            let topSide,
            let bottomSide,
            let topLeft,
            let topRight,
            let bottomLeft,
            let bottomRight
        ):
            break
        }
    }

}

public extension _PrimitiveView {

    func withBorder(
        style: BorderType = .singleLine,
        padding: Int32 = 1,
        color: FlourColor? = nil
    ) -> Self {
        self.borderEnabled = true
        self.borderHorizontalPadding = padding
        self.borderVerticalPadding = padding
        if let color {
            self.borderColor = color
        } else {
            self.borderColor = .white
        }
        self.borderStyle = style
        return self
    }

    func withBorder(
        style: BorderType = .singleLine,
        verticalPadding: Int32,
        horizontalPadding: Int32,
        color: FlourColor? = nil
    ) -> Self {
        self.borderEnabled = true
        self.borderHorizontalPadding = horizontalPadding
        self.borderVerticalPadding = verticalPadding
        if let color {
            self.borderColor = color
        } else {
            self.borderColor = .white
        }
        self.borderStyle = style
        return self
    }

}

internal extension _PrimitiveView {

    func renderBorder() {
        if borderEnabled {
            if let window {
                startColor((borderColor, nil), window: window)
            } else {
                startColor((borderColor, nil))
            }
            if let view = self as? Scene {
                switch view.borderStyle {
                case .singleLine:
                    box(view.window!, 0, 0)
                    break
                case .custom(
                    let leftSide,
                    let rightSide,
                    let topSide,
                    let bottomSide,
                    let topLeft,
                    let topRight,
                    let bottomLeft,
                    let bottomRight
                ):
                    wborder(
                        view.window!,
                        UInt32(FlourChar(leftSide).charAscii),
                        UInt32(FlourChar(rightSide).charAscii),
                        UInt32(FlourChar(topSide).charAscii),
                        UInt32(FlourChar(bottomSide).charAscii),
                        UInt32(FlourChar(topLeft).charAscii),
                        UInt32(FlourChar(topRight).charAscii),
                        UInt32(FlourChar(bottomLeft).charAscii),
                        UInt32(FlourChar(bottomRight).charAscii)
                    )
                    break
                }
                return
            }
            renderBorder(
                window: window!,
                style: borderStyle,
                viewPosition: position,
                viewWidth: width,
                viewHeight: height,
                verticalPadding: borderVerticalPadding,
                horizontalPadding: borderHorizontalPadding
            )
            if let window {
                endColor((borderColor, nil), window: window)
            } else {
                endColor((borderColor, nil))
            }
        }
    }
}
