import Foundation
import curses

internal protocol Focusable: _PrimitiveView {
    var isFocused: Bool { get set }
}

internal class SharedFocusables {

    public static let shared: SharedFocusables = SharedFocusables()

    private var map: [Scene: [any Focusable]]
    private var currentlyFocused: [Scene: any Focusable]

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
            currentlyFocused[scene] = focusable
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
            self.currentlyFocused[scene] = array.first
            array.first?.isFocused = true
        } else {
            self.currentlyFocused[scene] = array[index - 1]
            array[index - 1].isFocused = true
        }
    }

    @MainActor
    internal func rightFocusable(for scene: Scene) {
        guard let currentlyFocused = currentlyFocused[scene] else {
            return
        }
        currentlyFocused.isFocused = false
        guard let array = map[scene] else {
            self.currentlyFocused[scene] = nil
            return
        }
        guard let currentlyFocusedIndex = array.firstIndex(where: { $0 === currentlyFocused }) else {
            return
        }
        if currentlyFocusedIndex >= array.count - 1 {  // Failsafe
            self.currentlyFocused[scene] = array.last
            array.last?.isFocused = true
            return
        }
        guard
            let lowerFocusableIndex = array.firstIndex(where: {
                $0.position.y == currentlyFocused.position.y && $0.position.x > currentlyFocused.position.x
            })
        else {
            currentlyFocused.isFocused = true
            return
        }
        self.currentlyFocused[scene] = array[lowerFocusableIndex]
        self.currentlyFocused[scene]?.isFocused = true
    }

    @MainActor
    internal func leftFocusable(for scene: Scene) {
        guard let currentlyFocused = currentlyFocused[scene] else {
            return
        }
        currentlyFocused.isFocused = false
        guard let array = map[scene] else {
            self.currentlyFocused[scene] = nil
            return
        }
        guard let currentlyFocusedIndex = array.firstIndex(where: { $0 === currentlyFocused }) else {
            return
        }
        if currentlyFocusedIndex <= 0 {  // Failsafe
            self.currentlyFocused[scene] = array.first
            array.first?.isFocused = true
            return
        }
        guard
            let lowerFocusableIndex = array.firstIndex(where: {
                $0.position.y == currentlyFocused.position.y && $0.position.x < currentlyFocused.position.x
            })
        else {
            currentlyFocused.isFocused = true
            return
        }
        self.currentlyFocused[scene] = array[lowerFocusableIndex]
        self.currentlyFocused[scene]?.isFocused = true
    }

    @MainActor
    internal func upperFocusable(for scene: Scene) {
        guard let currentlyFocused = currentlyFocused[scene] else {
            return
        }
        currentlyFocused.isFocused = false
        guard let array = map[scene] else {
            self.currentlyFocused[scene] = nil
            return
        }
        guard let currentlyFocusedIndex = array.firstIndex(where: { $0 === currentlyFocused }) else {
            return
        }
        if currentlyFocusedIndex <= 0 {  // Failsafe
            self.currentlyFocused[scene] = array.first
            array.first?.isFocused = true
            return
        }
        guard
            let upperFocusableIndex = array.lastIndex(where: {
                $0.position.x == currentlyFocused.position.x && $0.position.y < currentlyFocused.position.y
            })
        else {
            guard let upperFocusableIndex = array.lastIndex(where: { $0.position.y < currentlyFocused.position.y })
            else {
                currentlyFocused.isFocused = true
                return
            }
            self.currentlyFocused[scene] = array[upperFocusableIndex]
            self.currentlyFocused[scene]?.isFocused = true
            return
        }
        self.currentlyFocused[scene] = array[upperFocusableIndex]
        self.currentlyFocused[scene]?.isFocused = true
    }

    @MainActor
    internal func lowerFocusable(for scene: Scene) {
        guard let currentlyFocused = currentlyFocused[scene] else {
            return
        }
        currentlyFocused.isFocused = false
        guard let array = map[scene] else {
            self.currentlyFocused[scene] = nil
            return
        }
        guard let currentlyFocusedIndex = array.firstIndex(where: { $0 === currentlyFocused }) else {
            return
        }
        if currentlyFocusedIndex >= array.count - 1 {  // Failsafe
            self.currentlyFocused[scene] = array.last
            array.last?.isFocused = true
            return
        }
        guard
            let lowerFocusableIndex = array.firstIndex(where: {
                $0.position.x == currentlyFocused.position.x && $0.position.y > currentlyFocused.position.y
            })
        else {
            guard let lowerFocusableIndex = array.firstIndex(where: { $0.position.y > currentlyFocused.position.y })
            else {
                currentlyFocused.isFocused = true
                return
            }
            self.currentlyFocused[scene] = array[lowerFocusableIndex]
            self.currentlyFocused[scene]?.isFocused = true
            return
        }
        self.currentlyFocused[scene] = array[lowerFocusableIndex]
        self.currentlyFocused[scene]?.isFocused = true
    }

    internal func nextFocusable(for scene: Scene) {
        guard let currentlyFocused = currentlyFocused[scene] else {
            return
        }
        currentlyFocused.isFocused = false
        guard let array = map[scene] else {
            self.currentlyFocused[scene] = nil
            return
        }
        guard let currentlyFocusedIndex = array.firstIndex(where: { $0 === currentlyFocused }) else {
            return
        }
        if currentlyFocusedIndex >= array.count - 1 {  // Failsafe
            self.currentlyFocused[scene] = array.last
            array.last?.isFocused = true
            return
        }
        self.currentlyFocused[scene] = array[currentlyFocusedIndex + 1]
        self.currentlyFocused[scene]?.isFocused = true
    }

    internal func previousFocusable(for scene: Scene) {
        guard let currentlyFocused = currentlyFocused[scene] else {
            return
        }
        currentlyFocused.isFocused = false
        guard let array = map[scene] else {
            self.currentlyFocused[scene] = nil
            return
        }
        guard let currentlyFocusedIndex = array.firstIndex(where: { $0 === currentlyFocused }) else {
            return
        }
        if currentlyFocusedIndex <= 0 {
            self.currentlyFocused[scene] = array.first
            array.first?.isFocused = true
            return
        }
        self.currentlyFocused[scene] = array[currentlyFocusedIndex - 1]
        self.currentlyFocused[scene]?.isFocused = true
    }

    internal func clear(for scene: Scene) {
        self.currentlyFocused[scene] = nil
        self.map[scene] = nil
    }

}
