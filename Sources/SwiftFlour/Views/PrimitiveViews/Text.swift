import Foundation
import curses

public class Text: _PrimitiveView {

    internal var foregroundColor: FlourColor?
    internal var backgroundColor: FlourColor? = .transparent

    internal var maxHeight: Int32?
    internal var maxWidth: Int32?

    internal var minWidth: Int32?
    internal var minHeight: Int32?

    internal var lines: [String.SubSequence] = []
    internal var printLines: [String.SubSequence] = []

    private var printText: String

    public init(
        _ text: String,
        maxWidth: Int32? = nil,
        maxHeight: Int32? = nil,
        minWidth: Int32? = nil,
        minHeight: Int32? = nil
    ) {
        self.printText = text
        super.init()
        self.text = text
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
        self.minWidth = minWidth
        self.minHeight = minHeight
        updateLines()
    }

    public func setMaxWidth(_ maxWidth: Int32?) -> Self {
        if let maxWidth, maxWidth < 0 {
            self.maxWidth = 0
        } else {
            self.maxWidth = maxWidth
        }
        updateLines()
        return self
    }

    public func setMaxHeight(_ maxHeight: Int32?) -> Self {
        if let maxHeight, maxHeight < 0 {
            self.maxHeight = 0
        } else {
            self.maxHeight = maxHeight
        }
        updateLines()
        return self
    }

    public func setMinWidth(_ minWidth: Int32?) -> Self {
        if let minWidth, minWidth < 0 {
            self.minWidth = 0
        } else {
            self.minWidth = minWidth
        }
        updateLines()
        return self
    }

    public func setMinHeight(_ minHeight: Int32?) -> Self {
        if let minHeight, minHeight < 0 {
            self.minHeight = 0
        } else {
            self.minHeight = minHeight
        }
        updateLines()
        return self
    }

    public func setText(_ text: String) -> Self {
        self.text = text
        updateLines()
        return self
    }

    func updateLines() {
        self.lines = self.text.split(separator: "\n")
        self.width = 0
        self.printLines = []
        for lineIndex in lines.indices {
            var line = lines[lineIndex]
            let lineCount = Int32(line.count)
            guard let maxWidth, maxWidth < lineCount else {
                if self.width < lineCount {
                    self.width = lineCount
                }
                self.printLines.append(line)
                continue
            }
            let maxWidthInt = Int(maxWidth)
            while line.count > maxWidthInt {
                self.printLines.append(line.prefix(maxWidthInt))
                line = line.dropFirst(maxWidthInt)
            }
            self.width = maxWidth
        }
        if let maxHeight, self.height > maxHeight {
            self.height = maxHeight
            self.printLines = Array(self.printLines.prefix(Int(maxHeight)))
        }

        if let minWidth, self.width < minWidth {
            self.width = minWidth
        }

        self.height = Int32(printLines.count)
        self.printText = text
        self.height = Int32(lines.count)
    }

    public func setForeground(_ color: FlourColor) -> Self {
        self.foregroundColor = color
        return self
    }

    public func setBackground(_ color: FlourColor) -> Self {
        self.backgroundColor = color
        return self
    }

    override public func render() {

        if let minHeight, self.height < minHeight {
            self.height = minHeight
        }
        var backgroundColor = self.backgroundColor
        if backgroundColor == .transparent, let parentBackground {
            backgroundColor = parentBackground
        }

        let window = parentScene?.window

        self.startColor((foregroundColor, backgroundColor), window: window)

        for line in printLines {
            printString(String(line), position: self.position, window: window)
        }

        self.endColor((foregroundColor, backgroundColor), window: window)
        super.render()

        if borderEnabled {
            renderBorder()
        }
    }

    public func getText() -> String { self.text }

    public func getPrintText() -> String { self.printText }

}
