import Logging

#if os(Linux)
@preconcurrency import Foundation
#else
import Foundation
#endif

public struct FileLogHandler: LogHandler, Sendable {
    public var logLevel: Logger.Level
    public var metadata = Logger.Metadata()
    public var logLevelOverrides: [String: Logger.Level] = [:]
    public var label: String
    public var fileURL: URL
    public var fileHandle: FileHandle?

    @MainActor
    public init(label: String, filePath: String, logLevel: Logger.Level = .info) {
        self.logLevel = logLevel
        self.label = label
        self.fileURL = URL(string: filePath)!
        if App.disableLogging {
            return
        }
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: filePath) {
            fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
        }
        self.fileHandle = try! FileHandle(forUpdating: fileURL)
    }

    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            return metadata[metadataKey]
        }
        set {
            metadata[metadataKey] = newValue
        }
    }

    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        file: String,
        function: String,
        line: UInt
    ) {
        let metadataString = metadata?.map { "\($0)=\($1)" }.joined(separator: " ") ?? ""
        let logMessage = "\(level): \(message) \(metadataString)\n"
        fileHandle?.write(logMessage.data(using: .utf8)!)
    }

    public subscript(dynamicMetadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            return metadata[metadataKey]
        }
        set {
            metadata[metadataKey] = newValue
        }
    }
}

extension Logger {
    func trace(_ message: String) {
        trace(Logger.Message(stringLiteral: message))
    }

    func debug(_ message: String) {
        debug(Logger.Message(stringLiteral: message))
    }

    func info(_ message: String) {
        info(Logger.Message(stringLiteral: message))
    }

    func warning(_ message: String) {
        warning(Logger.Message(stringLiteral: message))
    }

    func error(_ message: String) {
        error(Logger.Message(stringLiteral: message))
    }
}
