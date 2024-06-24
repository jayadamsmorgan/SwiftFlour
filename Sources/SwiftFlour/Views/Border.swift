import Foundation
import curses

public enum BorderType {
    case rounded
    case square
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

public extension _PrimitiveView {

    func enableBorder(padding: Int32 = 1) -> Self {
        return self
    }

    func disableBorder() -> Self {
        return self
    }

    internal func renderBorder(for window: OpaquePointer, with style: BorderType) {
        switch style {
        case .square:
            box(window, 0, 0)
            break
        case .rounded:
            box(window, 1, 1)  // ?
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
                window,
                UInt32(leftSide.asciiValue!),
                UInt32(rightSide.asciiValue!),
                UInt32(topSide.asciiValue!),
                UInt32(bottomSide.asciiValue!),
                UInt32(topLeft.asciiValue!),
                UInt32(topRight.asciiValue!),
                UInt32(bottomLeft.asciiValue!),
                UInt32(bottomRight.asciiValue!)
            )
            break
        }
    }
}
