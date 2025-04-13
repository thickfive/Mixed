//
//  Utils.swift
//  Mixed
//
//  Created by vvii on 2024/7/23.
//

import UIKit
import SwiftUI

func withoutAnimation(_ task: () -> Void) {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    task()
    CATransaction.commit()
}

func nothing() {
    // nothing to do
}

func mainAsync(_ task: @escaping () -> Void) {
    DispatchQueue.main.async {
        task()
    }
}

func mainAsyncAfter(second: Double, _ task: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + second, execute: {
        task()
    })
}

func withExtendedLifetime<T>(_ x: T, body: @escaping () -> Void) {
    withExtendedLifetime(x, body) // Weak-Strong Dance, https://www.jianshu.com/p/4e4265473a69
}
