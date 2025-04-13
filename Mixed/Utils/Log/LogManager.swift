//
//  LogManager.swift
//  Mixing
//
//  Created by vvii on 2024/9/1.
//

class LogManager: NSObject {
    
    static let shared = LogManager()
    
    var logger: LogProtocol?
    
    func setup(logger: LogProtocol?) {
        self.logger = logger
        self.logger?.setup()
    }
    
    func flush() {
        logger?.flush()
    }
    
    func close() {
        logger?.close()
    }
    
    func getLogFilePaths() -> [String] {
        return logger?.getLogFilePaths() ?? []
    }
    
    func clearLogFiles() {
        logger?.clearLogFiles()
    }
}
