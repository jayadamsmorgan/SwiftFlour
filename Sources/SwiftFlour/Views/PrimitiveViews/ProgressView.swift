import Foundation
import curses

public class ProgressView: Text {

    private var progressState: [String] = []
    private var progressStateIndex: Int = 0

    private var animationSpeed: Double = 0.4

    private var frameCount: Double = 0

    private var enabled: Bool = true
    private var paused: Bool = false

    public init(
        size: Int = 1,
        enabled: Bool = true,
        paused: Bool = false
    ) {
        self.paused = paused
        self.enabled = enabled
        super.init("")
        initSpinner(size: size)
    }

    private func initSpinner(size: Int) {
        var size = size
        if size <= 0 {
            size = 1
        }

        self.minWidth = Int32(size)
        self.minHeight = Int32(size)

        guard size > 1 else {
            progressState = ["\\", "|", "/", "—"]
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
        self.frameCount = Double(App.fps) * animationSpeed
    }

    override public func render() {
        if !enabled {
            return
        }
        if !paused {
            frameCount += 1
            if frameCount >= Double(App.fps) * animationSpeed {
                frameCount = 0
                progressStateIndex =
                    (progressStateIndex == progressState.count - 1) ? 0 : progressStateIndex + 1
                self.text = progressState[progressStateIndex]
                updateLines()
            }
        }

        super.render()
    }

    public func stop() {
        enabled = true
    }

    public func pause() {
        if enabled {
            paused = true
        }
    }

    public func start() {
        enabled = true
        paused = false
    }

    public func toggleStartPause() {
        if enabled {
            paused.toggle()
        }
    }

    public func toggleStartStop() {
        enabled.toggle()
    }

    public func isEnabled() -> Bool {
        enabled
    }

    public func isPaused() -> Bool {
        paused
    }

}
