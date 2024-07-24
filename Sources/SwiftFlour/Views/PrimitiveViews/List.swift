import Foundation
import curses

public enum ListDirection {
    case horizontal
    case vertical
}

public class List: _PrimitiveView {

    public var direction: ListDirection

    public var spacing: Int

    public var items: [_PrimitiveView]

    public init(_ items: [_PrimitiveView] = [], spacing: Int = 10, direction: ListDirection = .vertical) {
        self.items = items
        self.spacing = spacing
        self.direction = direction
    }

    public override func render() {
        switch direction {
        case .horizontal:
            var x = self.position.x
            self.height = 0
            self.width = 0
            for item in items {
                item.position = .init((x, self.position.y))
                item.render()
                let offset = item.width + Int32(spacing)
                x += offset
                self.width += offset
                if self.height < item.height {
                    self.height = item.height
                }
            }
        case .vertical:
            var y = self.position.y
            for item in items {
                item.position = .init((self.position.x, y))
                item.render()
                let offset = item.height + Int32(spacing)
                y += offset
                self.height += offset
                if self.width < item.width {
                    self.width = item.width
                }
            }
        }
        if borderEnabled {
            renderBorder()
        }
    }

}
