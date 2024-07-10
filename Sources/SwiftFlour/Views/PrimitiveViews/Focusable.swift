import Foundation
import curses

internal protocol Focusable: _PrimitiveView {
    var isFocused: Bool { get set }
    var onPress: () -> Void { get set }
    var cursorPos: Position { get }
}

internal enum Direction {
    case up
    case down
    case left
    case right
}

public enum FocusableSelectStyle {
    case bordered
    case highlighted
    case cursor
    case none
}

internal class SharedFocusables {

    public static let shared: SharedFocusables = SharedFocusables()

    private var focusableSelectStyleHolder: FocusableSelectStyle = .cursor
    public var focusableSelectStyle: FocusableSelectStyle {
        get { focusableSelectStyleHolder }
        set {
            focusableSelectStyleHolder = newValue
            if newValue == .cursor {
                curs_set(1)
            } else {
                curs_set(0)
            }
        }
    }

    private var map: [Scene: [any Focusable]]
    private var currentlyFocused: [Scene: Array<Focusable>.Index]

    private init() {
        self.map = [:]
        self.currentlyFocused = [:]
        if focusableSelectStyleHolder == .cursor {
            curs_set(1)
        }
    }

    internal func pressCurrentlyFocused(for scene: Scene) {
        guard let currentlyFocusedIndex = currentlyFocused[scene] else {
            return
        }
        guard let array = map[scene] else {
            return
        }
        array[currentlyFocusedIndex].onPress()
    }

    @MainActor
    internal func addFocusable(_ focusable: any Focusable, for scene: Scene) {
        guard let array = map[scene], !array.isEmpty else {
            map[scene] = [focusable]
            currentlyFocused[scene] = 0
            focusable.isFocused = true
            return
        }
        if array.contains(where: { $0 === focusable }) {
            return
        }
        for index in array.indices {
            if array[index].position > focusable.position {
                map[scene]?.insert(focusable, at: index)
                return
            }
        }
        map[scene]?.append(focusable)
    }

    internal func removeFocusable(_ focusable: any Focusable, for scene: Scene) {
        focusable.isFocused = false
        guard var array = map[scene] else {
            return
        }
        let index = array.firstIndex(where: { $0 === focusable }) ?? 0
        array.removeAll(where: { $0 === focusable })
        if array.isEmpty {
            self.currentlyFocused[scene] = nil
            return
        }
        if index == 0 {
            self.currentlyFocused[scene] = 0
            array.first?.isFocused = true
        } else {
            self.currentlyFocused[scene] = index - 1
            array[index - 1].isFocused = true
        }
    }

    @MainActor
    private func closestFocusable(
        in array: [Focusable],
        currentlyFocused: Focusable,
        currentlyFocusedIndex: Array<Focusable>.Index,
        direction: Direction
    )
        -> Array<Focusable>.Index?
    {
        var array = array
        let x = currentlyFocused.position.x
        let y = currentlyFocused.position.y
        var filter: (Focusable) -> Bool = { item in false }
        var directionOffset: (Focusable) -> Int32 = { item in 0 }
        var indexOffset = 0
        switch direction {
        case .up:
            guard currentlyFocusedIndex != array.indices.first else {
                return nil
            }
            array = Array(array.prefix(upTo: currentlyFocusedIndex - 1))
            filter = { $0.position.y < y }
            directionOffset = { abs($0.position.x - x) }
        case .down:
            guard currentlyFocusedIndex != array.indices.last else {
                return nil
            }
            array = Array(array.suffix(from: currentlyFocusedIndex + 1))
            indexOffset = currentlyFocusedIndex + 1
            filter = { $0.position.y > y }
            directionOffset = { abs($0.position.x - x) }
        case .left:
            guard currentlyFocusedIndex != array.indices.first else {
                return nil
            }
            filter = { $0.position.x < x }
            directionOffset = { abs($0.position.y - y) }
        case .right:
            guard currentlyFocusedIndex != array.indices.last else {
                return nil
            }
            filter = { $0.position.x > x }
            directionOffset = { abs($0.position.y - y) }
        }
        guard !array.isEmpty else {
            return nil
        }
        var closestIndex: Array<Focusable>.Index?
        var oldOffset: Int32?
        for index in array.indices {
            guard filter(array[index]) else {
                continue
            }
            let newOffset = directionOffset(array[index])
            guard oldOffset != nil else {
                oldOffset = newOffset
                closestIndex = index
                continue
            }
            if newOffset < oldOffset! {
                oldOffset = newOffset
                closestIndex = index
            }
        }
        guard var closestIndex else {
            return nil
        }
        closestIndex += indexOffset
        guard currentlyFocusedIndex != closestIndex else {
            return nil
        }
        return closestIndex
    }

    internal func setCursor(for scene: Scene) {
        guard self.focusableSelectStyleHolder == .cursor else {
            return
        }
        guard let currentlyFocusedIndex = currentlyFocused[scene] else {
            return
        }
        guard let array = map[scene] else {
            return
        }
        let cursorPos = array[currentlyFocusedIndex].cursorPos
        mvaddstr(cursorPos.y, cursorPos.x, "")
    }

    @MainActor
    internal func moveFocusable(for scene: Scene, direction: Direction) {
        guard let array = map[scene] else {
            self.currentlyFocused[scene] = nil
            return
        }
        guard !array.isEmpty && array.count != 1 else {
            return
        }
        guard let currentlyFocusedIndex = currentlyFocused[scene] else {
            return
        }
        let currentlyFocused = array[currentlyFocusedIndex]
        guard
            let closest = closestFocusable(
                in: array,
                currentlyFocused: currentlyFocused,
                currentlyFocusedIndex: currentlyFocusedIndex,
                direction: direction
            )
        else {
            return
        }
        currentlyFocused.isFocused = false
        self.currentlyFocused[scene] = closest
        array[closest].isFocused = true
    }

    internal func nextFocusable(for scene: Scene) {
        guard let currentlyFocusedIndex = currentlyFocused[scene] else {
            return
        }
        guard let array = map[scene] else {
            self.currentlyFocused[scene] = nil
            return
        }
        guard !array.isEmpty && array.count != 1 else {
            return
        }
        guard currentlyFocusedIndex != array.indices.last else {
            array[currentlyFocusedIndex].isFocused = false
            self.currentlyFocused[scene] = array.indices.first
            array.first?.isFocused = true
            return
        }
        array[currentlyFocusedIndex].isFocused = false
        self.currentlyFocused[scene] = currentlyFocusedIndex + 1
        array[currentlyFocusedIndex + 1].isFocused = true
    }

    internal func previousFocusable(for scene: Scene) {
        guard let currentlyFocusedIndex = currentlyFocused[scene] else {
            return
        }
        guard let array = map[scene] else {
            self.currentlyFocused[scene] = nil
            return
        }
        guard !array.isEmpty && array.count != 1 else {
            return
        }
        guard currentlyFocusedIndex != array.indices.first else {
            array[currentlyFocusedIndex].isFocused = false
            self.currentlyFocused[scene] = array.indices.last
            array.last?.isFocused = true
            return
        }
        array[currentlyFocusedIndex].isFocused = false
        self.currentlyFocused[scene] = currentlyFocusedIndex - 1
        array[currentlyFocusedIndex - 1].isFocused = true
    }

    internal func clear(for scene: Scene) {
        self.currentlyFocused[scene] = nil
        self.map[scene] = nil
    }

}
