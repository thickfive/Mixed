//
//  XLog.swift
//  FrameLog
//
//  Created by 吴迢荣 on 2021/12/13.
//

import Foundation

///  对OC XLog日志打印的封装
public func xLogPrint(level: XLogLevel,
                      tag: String,
                      fileName: String,
                      line: UInt,
                      funcName: String,
                      message: String)
{
    if XLogHelper.shouldLog(level)
    {
        XLogHelper.log(with: level,
                       moduleName: tag,
                       fileName: fileName,
                       lineNumber: Int32(line),
                       funcName: funcName,
                       message: message)
    }
}

public func XLOG_ERROR(_ moduleName: String,
                       _ message: String,
                       fileName: String = #file,
                       line: UInt = #line,
                       funcName: String = #function)
{
    xLogPrint(level: .error,
              tag: moduleName,
              fileName: fileName,
              line: line,
              funcName: funcName,
              message: message)
}

public func XLOG_WARNING(_ moduleName: String,
                         _ message: String,
                         fileName: String = #file,
                         line: UInt = #line,
                         funcName: String = #function)
{
    xLogPrint(level: .warn,
              tag: moduleName,
              fileName: fileName,
              line: line, funcName: funcName,
              message: message)
}

public func XLOG_INFO(_ moduleName: String,
                      _ message: String,
                      fileName: String = #file,
                      line: UInt = #line,
                      funcName: String = #function)
{
    xLogPrint(level: .info,
              tag: moduleName,
              fileName: fileName,
              line: line,
              funcName: funcName,
              message: message)
}

public func XLOG_DEBUG(_ moduleName: String,
                       _ message: String,
                       fileName: String = #file,
                       line: UInt = #line,
                       funcName: String = #function)
{
    xLogPrint(level: .debug,
              tag: moduleName,
              fileName: fileName,
              line: line,
              funcName: funcName,
              message: message)
}
