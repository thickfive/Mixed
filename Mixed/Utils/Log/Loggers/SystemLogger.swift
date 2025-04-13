//
//  SystemLogger.swift
//  Mixed
//
//  Created by vvii on 2024/9/13.
//

import Foundation

class SystemLogger: NSObject, LogProtocol {
    
    func setup() {
        // do noting
    }
    
    func flush() {
        // do noting
    }
    
    func close() {
        // do noting
    }
    
    func getLogFilePaths() -> [String] {
        // do noting
        return []
    }
    
    func clearLogFiles() {
        // do noting
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
        print(messages, level: .error, file: file, function: function, line: line, tag: tag)
    }
}

extension SystemLogger {
    
    enum Level: String {
        case verbose    = "V"
        case debug      = "D"
        case info       = "I"
        case warn       = "W"
        case error      = "E"
    }
    
    private func print(_ messages: Any ...,
                level: Level,
                file: StaticString = #file,
                function: StaticString = #function,
                line: UInt = #line,
                tag: String? = nil) {
        // [level][tag][file:line function] message
        let messages = messages.map({ String(describing: $0) }).joined(separator: ", ")
        let level = "[\(level.rawValue)]"
        let tag = "[\(tag ?? "?")]"
        let info = "[\(String(describing: file).split(separator: "/").last ?? "?"):\(line) \(function)]"
        let message = "\(level)\(tag)\(info) \(messages)"
        Swift.print(message)
    }
}
