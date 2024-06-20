import Darwin.ncurses
import Foundation

@MainActor
public protocol View: Sendable {
    var body: [any View] { get set }

    func render()
}

fileprivate var colorPair: [Int16: (FlourColor?, FlourColor?)] = [:]

extension View {

    @MainActor
    public func render() {
        for child in body {
            child.render()
        }
    }

    internal func startColor(_ pair: (FlourColor?, FlourColor?)) {
        let foreground = pair.0
        let background = pair.1
        if let colorPair = colorPair.first(where: { $0.value == pair }) {
            attron(COLOR_PAIR(Int32(colorPair.key)))
            return
        }
        let count = Int16(colorPair.count) + 1
        colorPair[count] = pair
        if let foreground, let background {
            init_pair(count, foreground.rawValue, background.rawValue)
        } else if let foreground {
            init_pair(count, foreground.rawValue, -1)
        } else if let background {
            init_pair(count, -1, background.rawValue)
        } else {
            init_pair(count, -1, -1)
        }
        attron(COLOR_PAIR(Int32(count)))
    }

    internal func endColor(_ pair: (FlourColor?, FlourColor?)) {
        if let colorPair = colorPair.first(where: { $0.value == pair }) {
            attroff(COLOR_PAIR(Int32(colorPair.key)))
        }
    }

}

internal protocol _PrimitiveView: View {

    var position: Position { get set }
    var width: Int32 { get set }
    var height: Int32 { get set }

    var data: Data { get set }

    func setPosition(_ position: Position) -> Self
    func setWidth(_ width: Int32) -> Self
    func setHeight(_ height: Int32) -> Self

}
