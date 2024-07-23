import Foundation
import curses

public class SecureInput: Input {

    private var secureValue: [Character] = []

    override internal func handleInput(_ key: FlourChar) {
        if isFocused {
            if justFocused {
                justFocused = false
                return
            }
            switch key {
            case .enter:
                onPress()
            case .backspace:
                secureValue = secureValue.dropLast()
                value = String(value.dropLast())
                onValueChange?(value)
            case .arrowUp, .arrowDown, .arrowLeft, .arrowRight:
                return
            default:
                secureValue.append(Character(UnicodeScalar(Int(key.charAscii))!))
                value.append("*")
                onValueChange?(value)
            }
        }
    }

    public func getSecureValue() -> [Character] {
        secureValue
    }

}
