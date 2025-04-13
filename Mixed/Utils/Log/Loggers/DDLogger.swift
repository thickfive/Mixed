//
//  DDLogger.swift
//  Mixed
//
//  Created by vvii on 2024/9/13.
//

#if canImport(CocoaLumberjack)
import CocoaLumberjack

class DDLogger: NSObject, LogProtocol {
    
    var fileLogger: DDFileLogger?
    
    func setup() {
        let ttyLogger = DDTTYLogger.sharedInstance!
        ttyLogger.logFormatter = self
        DDLog.add(ttyLogger)
        
        let fileLogger = DDFileLogger()
        fileLogger.rollingFrequency = 60 * 60 * 24 // 60 * 60 * 24 (秒)
        fileLogger.logFileManager.maximumNumberOfLogFiles = 5
        fileLogger.logFormatter = self
        DDLog.add(fileLogger)
        self.fileLogger = fileLogger
        
        print(fileLogger.logFileManager.logsDirectory, fileLogger.logFileManager.sortedLogFilePaths)
    }
    
    func flush() {
        DDLog.flushLog()
    }
    
    func close() {
        DDLog.removeAllLoggers()
    }
    
    func getLogFilePaths() -> [String] {
        return fileLogger?.logFileManager.sortedLogFilePaths ?? []
    }
    
    func clearLogFiles() {
        do {
            if let logFileManager = fileLogger?.logFileManager, logFileManager.responds(to: #selector(DDLogFileManager.cleanupLogFiles)) {
                // optional func cleanupLogFiles() throws
                // 这里不能用 ?, 编译无法通过, 只能用 !
                //
                // try logFileManager.cleanupLogFiles!()
                //
                // 实际上文件只有满足条件才会被删除, 需要手动删除
                for info in logFileManager.unsortedLogFileInfos {
                    if info.isArchived {
                        try FileManager.default.removeItem(atPath: info.filePath)
                    }
                }
            }
        } catch {
            Log.error(error)
        }
    }
    
    func verbose(_ messages: Any ...,
                     file: StaticString = #file,
                     function: StaticString = #function,
                     line: UInt = #line,
                     tag: String? = nil) {
        let message = messages.map({ String(describing: $0) }).joined(separator: ", ")
        DDLogVerbose("\(message)", file: file, function: function, line: line, tag: tag)
    }
    
    func debug(_ messages: Any ...,
                     file: StaticString = #file,
                     function: StaticString = #function,
                     line: UInt = #line,
                     tag: String? = nil) {
        let message = messages.map({ String(describing: $0) }).joined(separator: ", ")
        DDLogDebug("\(message)", file: file, function: function, line: line, tag: tag)
    }
    
    func info(_ messages: Any ...,
                     file: StaticString = #file,
                     function: StaticString = #function,
                     line: UInt = #line,
                     tag: String? = nil) {
        let message = messages.map({ String(describing: $0) }).joined(separator: ", ")
        DDLogInfo("\(message)", file: file, function: function, line: line, tag: tag)
    }
    
    func warn(_ messages: Any ...,
                     file: StaticString = #file,
                     function: StaticString = #function,
                     line: UInt = #line,
                     tag: String? = nil) {
        let message = messages.map({ String(describing: $0) }).joined(separator: ", ")
        DDLogWarn("\(message)", file: file, function: function, line: line, tag: tag)
    }
    
    func error(_ messages: Any ...,
                     file: StaticString = #file,
                     function: StaticString = #function,
                     line: UInt = #line,
                     tag: String? = nil) {
        let message = messages.map({ String(describing: $0) }).joined(separator: ", ")
        DDLogError("\(message)", file: file, function: function, line: line, tag: tag)
    }
}

extension DDLogger: DDLogFormatter {
    
    static let levels: [UInt: String] = [
        DDLogFlag.error.rawValue:     "E",
        DDLogFlag.warning.rawValue:   "W",
        DDLogFlag.info.rawValue:      "I",
        DDLogFlag.debug.rawValue:     "D",
        DDLogFlag.verbose.rawValue:   "V"
    ]
    
    func format(message logMessage: DDLogMessage) -> String? {
        // [level][tag][file:line function] message
        let level = "[\(DDLogger.levels[logMessage.flag.rawValue] ?? "?")]"
        let tag = "[\(logMessage.representedObject ?? "?")]"
        let info = "[\(logMessage.file.split(separator: "/").last ?? "?"):\(logMessage.line) \(logMessage.function ?? "?")]"
        let message = "\(level)\(tag)\(info) \(logMessage.message)"
        return message
    }
}
#endif

