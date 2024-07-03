import Foundation
import curses

internal protocol Focusable: _PrimitiveView {
    var isFocused: Bool { get set }
    var onPress: () -> Void { get set }
}

internal enum Direction {
    case up
    case down
    case left
    case right
}

internal class SharedFocusables {

    public static let shared: SharedFocusables = SharedFocusables()

    private var map: [Scene: [any Focusable]]
    private var currentlyFocused: [Scene: Array<Focusable>.Index]

    private init() {
        self.map = [:]
        self.currentlyFocused = [:]
    }

    @MainActor
    internal func addFocusable(_ focusable: any Focusable, for scene: Scene) {
        defer {
            var str = ""
            for item in map[scene] ?? [] {
                str.append("\(item.text), ")
            }
            App.logger.info(str)
        }
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
        var f: (Focusable) -> Bool = { item in false }
        var indexOffset = 0
        switch direction {
        case .up:
            guard currentlyFocusedIndex != array.indices.first else {
                return nil
            }
            array = Array(array.prefix(upTo: currentlyFocusedIndex - 1))
            f = { $0.position.y < y }
        case .down:
            guard currentlyFocusedIndex != array.indices.last else {
                return nil
            }
            array = Array(array.suffix(from: currentlyFocusedIndex + 1))
            indexOffset = currentlyFocusedIndex + 1
            f = { $0.position.y > y }
        case .left:
            guard currentlyFocusedIndex != array.indices.first else {
                return nil
            }
            f = { $0.position.x < x }
        case .right:
            guard currentlyFocusedIndex != array.indices.last else {
                return nil
            }
            f = { $0.position.x > x }
        }
        guard !array.isEmpty else {
            return nil
        }
        var closest = array.first!
        var closestIndex = array.indices.first!
        for index in array.indices.dropFirst() {
            guard f(array[index]) else {
                continue
            }
            let oldOffset = abs(x - closest.position.x) + abs(y - closest.position.y)
            let newOffset = abs(x - array[index].position.x) + abs(y - array[index].position.y)
            if newOffset < oldOffset {
                closest = array[index]
                closestIndex = index
            }
        }
        closestIndex += indexOffset
        guard currentlyFocusedIndex != closestIndex else {
            return nil
        }
        return closestIndex
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
            // self.currentlyFocused[scene] = array.indices.last!
            // array.last?.isFocused = true
            // if direction == .up || direction == .left {
            //     previousFocusable(for: scene)
            // } else {
            //     nextFocusable(for: scene)
            // }
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
