//
//  MarsLogger.swift
//  Mixed
//
//  Created by vvii on 2024/9/13.
//

#if canImport(XXLog)
import XXLog

class MarsLogger: NSObject, LogProtocol {
    
    func setup() {
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + "/log"
        let config = XXLogConfig(
            path: path,
            level: XXLogLevel.all,
            isConsoleLog: true,
            pubKey: "22e47ed6923fb6f680ae35a5fb95f1f5bffe1febf6d976d5f58a37722ce6f807b16804838e8e3bec41751094dbb11794a02c82adb7c7ad6157f9c8d24a725000",
            cacheDays: 5
        )
        XXLogHelper.shared().setupConfig(config)
    }
    
    func flush() {
        XXLogHelper.logAppenderFlush()
    }
    
    func close() {
        XXLogHelper.logAppenderClose()
    }
    
    func getLogFilePaths() -> [String] {
        return (XXLogHelper.shared().getLogFilePathList() as? [String]) ?? []
    }
    
    func clearLogFiles() {
        XXLogHelper.shared().clearLocalLogFile()
    }
    
    
    func verbose(_ messages: Any ...,
                     file: StaticString = #file,
                     function: StaticString = #function,
                     line: UInt = #line,
                     tag: String? = nil) {
        print(messages, level: .verbose, file: file, function: function, line: line, tag: tag)
    }
    
    func debug(_ messages: Any ...,
                     file: StaticString = #file,
                     function: StaticString = #function,
                     line: UInt = #line,
                     tag: String? = nil) {
        print(messages, level: .debug, file: file, function: function, line: line, tag: tag)
    }
    
    func info(_ messages: Any ...,
                     file: StaticString = #file,
                     function: StaticString = #function,
                     line: UInt = #line,
                     tag: String? = nil) {
        print(messages, level: .info, file: file, function: function, line: line, tag: tag)
    }
    
    func warn(_ messages: Any ...,
                     file: StaticString = #file,
                     function: StaticString = #function,
                     line: UInt = #line,
                     tag: String? = nil) {
        print(messages, level: .warn, file: file, function: function, line: line, tag: tag)
    }
    
    func error(_ messages: Any ...,
                     file: StaticString = #file,
                     function: StaticString = #function,
                     line: UInt = #line,
                     tag: String? = nil) {
        print(messages, level: .warn, file: file, function: function, line: line, tag: tag)
    }
}

extension MarsLogger {
    
    private func print(_ messages: Any ...,
                level: XXLogLevel,
                file: StaticString = #file,
                function: StaticString = #function,
                line: UInt = #line,
                tag: String? = nil) {
        // [level][tag][file:line function] message
        let file = String(describing: file).split(separator: "/").last ?? "?"
        XXLog.print(level: level, tag: tag ?? "?", fileName: "\(file)", line: line, funcName: "\(function)", items: messages)
    }
}
#endif


