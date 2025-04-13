//
//  LogConfigProtocol.swift
//  FrameLog
//
//  Created by 吴迢荣 on 2021/12/13.
//

import Foundation

public protocol LogConfigProtocol {
    var path: String { get }
    var releaseLevel: XLogLevel { get }
    var logFileNamePrefix: String { get }
    var pubKey: String { get }
}
