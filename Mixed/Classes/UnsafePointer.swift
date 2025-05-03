//
//  UnsafePointer.swift
//  Mixed
//
//  Created by vvii on 2024/8/6.
//

import UIKit

class UnsafePointerController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 指针类型转换基本规则, <Raw> 与 <T> 二选一, 它相当于 T == UInt8
        //
        // 0. OpaquePointer 与 Unsafe 指针类型转换
        // AnyPointer -> OpaquePointer(AnyPointer) -> Unsafe<Mutable><Raw>Pointer<T>(OpaquePointer)
        //
        // 1. <Raw>: init() / bindMemory(to type: T.Type) 或者 assumingMemoryBound<T>(to: T.Type)
        // Unsafe<Mutable>Raw<Buffer>Pointer.init(Unsafe<Mutable><Buffer>Pointer<T>)
        // Unsafe<Mutable>Raw<Buffer>Pointer.bindMemory<T>(to type: T) -> Unsafe<Mutable><Buffer>Pointe<T>
        //
        // 2. <Mutable>: init() / init(mutating:)
        // Unsafe<Raw>Pointer<T>.init(UnsafeMutable<Raw>Pointer<T>)
        // UnsafeMutable<Raw>Pointer<T>.init(mutating: Unsafe<Raw>Pointer<T>)
        //
        // 3. <Buffer>: init(start:count:) / .baseAddress
        // Unsafe<Mutable><Raw>BufferPointer<T>.init(start: Unsafe<Mutable><Raw>Pointer<T>, count: Int)
        // Unsafe<Mutable><Raw>BufferPointer<T>.baseAddress -> Unsafe<Mutable><Raw>Pointer<T>
        //
        // 包括 <Raw> 在内, 想要修改指向的内存, 需要先转换到指定的类型 T 或者 Buffer 才能使用下标
        
        let ptr0: UnsafeMutableRawPointer = malloc(4)
        
        let ptr1 = ptr0.assumingMemoryBound(to: UInt8.self)
        ptr1[0] = 0x11
        ptr1[1] = 0x22
        ptr1[2] = 0x33
        ptr1[3] = 0x44
        debugPrint(ptr0)    // <0000c160>: 44332211
        
        // var num: Int = 0x11223344
        // // dangling pointer, 空悬指针: 指向内容可能已经被释放, 野指针: 没有初始化的指针, 指向未知地址
        // let pt0 = UnsafePointer<Int>(&num)
        // debugPrint(pt0)     // <6f42c140>: 11223344
        // let pt1 = UnsafeMutablePointer<Int>(mutating: pt0)
        // pt1[0] = 0xaa
        // debugPrint(pt1)     // <6f42c140>: 000000aa
        // let pt2 = UnsafeMutableBufferPointer<Int>.init(start: pt1, count: 8)
        // pt2[1] = 0xbb
        // debugPrint(pt2[1])  // <????????>: 000000bb (Int)
        // let pt3 = UnsafeMutableRawPointer(pt1)
        // debugPrint(pt3)     // <6f42c140>: 000000aa
        // let pt4 = UnsafeMutableRawBufferPointer.init(start: pt3, count: 8)
        // pt4[3] = 0xcc
        // debugPrint(pt4)     // <6f42c140>: cc0000aa
    }
}

func debugPrint(_ item: Any) {
    if let ptr = item as? UnsafePointer<Int> {
        debugPrint(OpaquePointer(ptr)); return;
    }
    if let ptr = item as? UnsafeMutablePointer<Int> {
        debugPrint(OpaquePointer(ptr)); return;
    }
    if let ptr = item as? UnsafeRawPointer {
        debugPrint(OpaquePointer(ptr)); return;
    }
    if let ptr = item as? UnsafeMutableRawPointer {
        debugPrint(OpaquePointer(ptr)); return;
    }
    if let ptr = item as? UnsafeBufferPointer<Int> {
        debugPrint(OpaquePointer(ptr.baseAddress!)); return;
    }
    if let ptr = item as? UnsafeMutableBufferPointer<Int> {
        debugPrint(OpaquePointer(ptr.baseAddress!)); return;
    }
    if let ptr = item as? UnsafeRawBufferPointer {
        debugPrint(OpaquePointer(ptr.baseAddress!)); return;
    }
    if let ptr = item as? UnsafeMutableRawBufferPointer {
        debugPrint(OpaquePointer(ptr.baseAddress!)); return;
    }
    if let arg = item as? CVarArg {
        print(String(format: "<????????>: %08x ", arg)); return;
    }
}

func debugPrint(_ ptr: OpaquePointer) {
    let pt = UnsafePointer<Int>(ptr)
    print(String(format: "<%08x>: %08x", pt, pt.pointee))
}
