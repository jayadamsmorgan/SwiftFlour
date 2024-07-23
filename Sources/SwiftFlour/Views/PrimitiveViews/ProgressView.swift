import Foundation
import curses

public enum ProgressViewStyle {
    case spinner(size: Int)
}

public class ProgressView: Text {

    private var progressState: [String] = []
    private var progressStateIndex: Int = 0

    private var progressPercentage: Int = 0

    private var animationSpeed: Double = 0.4

    private var frameCount: Double = 0

    private var enabled: Bool = true
    private var paused: Bool = false

    public init(style: ProgressViewStyle = .spinner(size: 1)) {
        switch style {
        case .spinner(let size):
            super.init(String(repeating: " ", count: size * size))
            initSpinner(size: size)
        }
    }

    private func initSpinner(size: Int) {
        guard size >= 1 else {
            fatalError("ProgressView spinner size needs to be greater than 0.")
        }

        self.width = Int32(size)
        self.height = Int32(size)

        guard size > 1 else {
            progressState = ["\\", "|", "/", "—"]
            self.width = 1
            self.height = 1
            return
        }

        progressState = ["", "", "", ""]

        for i in 0..<size {
            progressState[0].append(String(repeating: " ", count: i))
            if i == size - 1 {
                progressState[0].append("\\")
            } else {
                progressState[0].append("\\\n")
            }

            progressState[1].append(String(repeating: " ", count: size / 2))
            if i == size - 1 {
                progressState[1].append("|")
            } else {
                progressState[1].append("|\n")
            }

            progressState[2].append(String(repeating: " ", count: (size - i - 1)))
            if i == size - 1 {
                progressState[2].append("/")
            } else {
                progressState[2].append("/\n")
            }

            if size % 2 == 0 {
                if i == (size - 2) / 2 {
                    progressState[3].append(String(repeating: "_", count: size))
                } else {
                    progressState[3].append(String(repeating: " ", count: size))
                }
            } else {
                if i == (size - 1) / 2 {
                    progressState[3].append(String(repeating: "—", count: size))
                } else {
                    progressState[3].append(String(repeating: " ", count: size))
                }
            }
            if i != size - 1 {
                progressState[3].append("\n")
            }
        }
    }

    override public func render() {
        frameCount += 1
        if frameCount >= Double(App.fps) * animationSpeed {
            frameCount = 0
            if progressStateIndex == progressState.count - 1 {
                progressStateIndex = 0
            } else {
                progressStateIndex += 1
            }
        }

        self.text = progressState[progressStateIndex]

        if borderEnabled {
            renderBorder()
        }

        var backgroundColor = self.backgroundColor
        if backgroundColor == .transparent, let parentBackground {
            backgroundColor = parentBackground
        }

        let window = parentScene?.window

        self.startColor((foregroundColor, backgroundColor), window: window)

        let lines = self.text.split(separator: "\n")
        for i in 0..<self.height {
            printString(String(lines[Int(i)]), position: (self.position.x, self.position.y + i), window: window)
        }

        self.endColor((foregroundColor, backgroundColor), window: window)
    }

    public func setProgressPercentage(_ percentage: Int) {
        self.progressPercentage = percentage
    }

    public func stop() {

    }

    public func pause() {

    }

    public func start() {

    }

}
