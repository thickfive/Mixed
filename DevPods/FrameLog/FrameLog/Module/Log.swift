//
//  LogManager.swift
//  FrameLog
//
//  Created by 吴迢荣 on 2021/12/13.
//

import Foundation

public protocol LogProtocol {
    static func config(config: LogConfigProtocol)
    static func logAppenderClose()
    static func logAppenderFlush()
    static func getLogFilePathList() -> [String]?
    static func clearLogFile()
    static func spiltLog(log: String) -> [String]
}

public class Log: LogProtocol {
    private static let LOG_MAX_LEN = 10000
    
    public static var shared: LogProtocol = Log()
    
    public static var config: LogConfigProtocol!
    
    public static func config(config: LogConfigProtocol) {
        self.config = config
        XLogHelper.shared().initXLog(.debug, release: config.releaseLevel, path: config.path, prefix: config.logFileNamePrefix, pubKey: config.pubKey)
    }
    
    public static func logAppenderClose() {
        XLogHelper.logAppenderClose()
    }
    
    public static func logAppenderFlush() {
        XLogHelper.logAppenderFlush()
    }
    
    public static func getLogFilePathList() -> [String]? {
        XLogHelper.shared().getLogFilePathList() as? [String]
    }
    
    public static func clearLogFile() {
        XLogHelper.shared().clearLocalLogFile()
    }
    
    public static func spiltLog(log: String) -> [String] {
        var logs: [String] = []
        var startIndex = log.startIndex
        while startIndex < log.endIndex {
            let endIndex = log.index(startIndex, offsetBy: LOG_MAX_LEN, limitedBy: log.endIndex) ?? log.endIndex
            logs.append(String(log[startIndex ..< endIndex]))
            startIndex = endIndex
        }
        return logs
    }
}
