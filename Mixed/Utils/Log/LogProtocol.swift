//
//  LogProtocol.swift
//  Mixed
//
//  Created by vvii on 2024/9/13.
//

protocol LogProtocol: NSObjectProtocol {
    
    func setup()
    
    func flush()
    
    func close()
    
    func getLogFilePaths() -> [String]
    
    func clearLogFiles()
    
    func verbose(_ messages: Any ...,
                     file: StaticString,
                     function: StaticString,
                     line: UInt,
                     tag: String?)
    
    func debug(_ messages: Any ...,
                     file: StaticString,
                     function: StaticString,
                     line: UInt,
                     tag: String?)
    
    func info(_ messages: Any ...,
                     file: StaticString,
                     function: StaticString,
                     line: UInt,
                     tag: String?)
    
    func warn(_ messages: Any ...,
                     file: StaticString,
                     function: StaticString,
                     line: UInt,
                     tag: String?)
    
    func error(_ messages: Any ...,
                     file: StaticString,
                     function: StaticString,
                     line: UInt,
                     tag: String?)
}
