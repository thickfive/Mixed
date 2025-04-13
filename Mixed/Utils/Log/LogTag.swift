//
//  LogTag.swift
//  Mixed
//
//  Created by vvii on 2024/9/18.
//

import Foundation

enum Tag: String, CustomStringConvertible {
    case crash
    case network
    // ...
    var description: String {
        return rawValue
    }
}

// 添加 Tag 方式一: 使用枚举, 相对规范
// Log.error(error, tag: .network)
extension String {
    static let crash = Tag.crash.description
    static let network = Tag.network.description
    // ... more from enum Tag
}

// 添加 Tag 方式二: 使用字符串, 简单
// Log.error(error, tag: .test)
extension String {
    static let test = "test"
    // ... more from custom string
}

// 添加 Tag 方式三: 直接使用字面量
// Log.error(error, tag: "tag")


#if canImport(NothingToImport)
// 可以加上所属模块前缀避免冲突
extension Log {
    enum Tag: String, CustomStringConvertible {
        case example
        // ...
        var description: String {
            return rawValue
        }
    }
}

struct ModuleA {
    enum Tag: String, CustomStringConvertible {
        case example
        // ...
        var description: String {
            return rawValue
        }
    }
}

class ModuleB {
    enum Tag: String, CustomStringConvertible {
        case example
        // ...
        var description: String {
            return rawValue
        }
    }
}

enum ModuleC {
    enum Tag: String, CustomStringConvertible {
        case example
        // ...
        var description: String {
            return rawValue
        }
    }
}

extension String {
    static let example0 = Log.Tag.example.description
    static let example1 = ModuleA.Tag.example.description
    static let example2 = ModuleB.Tag.example.description
    static let example3 = ModuleC.Tag.example.description
}
#endif
