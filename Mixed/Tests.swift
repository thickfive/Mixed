//
//  Tests.swift
//  Mixed
//
//  Created by vvii on 2024/7/30.
//

import LibExample
import HandyJSON

struct Cat: HandyJSON {
    var name: String = ""
    var age: Int = 0
}

func runTest() {
    //
}

struct Object {
    var viewType: ViewType {
        willSet {
            if viewType != newValue {
                print("1 - new value")
            } else {
                print("1 - old value")
            }
        }
        didSet {
            if viewType != oldValue {
                print("2 - new value")
            } else {
                print("2 - old value")
            }
        }
    }
}

enum TypeB: Equatable {
    case b1
    case b2
}

enum ViewType: Equatable {
    case a1
    case a2
    case typeB(TypeB)
}

 
struct Resp: Decodable, Equatable {
    var code = 0
    var msg = ""
    var data: User = User()
}

struct User: Decodable, Equatable, HandyJSON {
    var avatar = ""
}


class SwiftAutorelease: NSObject {
    
    var buffer: UnsafeMutablePointer<UInt8>! = nil
    
    override init() {
        super.init()
        let size = 10 * 1024 * 1024
        buffer = malloc(size).assumingMemoryBound(to: UInt8.self)
        for i in 0..<size {
            buffer[i] = 0
        }
    }
    
    deinit {
        print("deinit")
        free(buffer)
    }
    
    static func test() {
        mainAsyncAfter(second: 1) {
            for i in 0..<10 {
                print("loop start \(i)")
                // OC 内存峰值不会过高, 同样的代码用 Swift 反而需要 autoreleasepool, 无法解释
                // 总之, 在需要的时候加 autoreleasepool, 至于什么时候需要, 看情况
                let path = Bundle.main.path(forResource: "video", ofType: "mp4")!
                autoreleasepool {
                    let data = try! Data(contentsOf: URL(fileURLWithPath: path))
                    print("loop end \(data.count)")
                }
                sleep(1)
            }
        }
    }
}
