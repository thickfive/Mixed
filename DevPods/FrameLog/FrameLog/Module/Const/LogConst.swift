//
//  LogConst.swift
//  Lama
//
//  Created by 吴迢荣 on 2021/11/21.
//  Copyright © 2021 wenext. All rights reserved.
//

import Foundation

public func logDebug(tag: String, msg: String) {
    XLOG_DEBUG(tag, msg)
}

public func logInfo(tag: String, msg: String) {
    XLOG_INFO(tag, msg)
}

public func logWarning(tag: String, msg: String) {
    XLOG_WARNING(tag, msg)
}

public func logError(tag: String, msg: String) {
    XLOG_ERROR(tag, msg)
}
