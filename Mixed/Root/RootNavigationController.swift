//
//  RootNavigationController.swift
//  Mixed
//
//  Created by vvii on 2024/1/28.
//

import UIKit

class RootNavigationController: UINavigationController, AutorotateProtocol {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var shouldAutorotate: Bool {
        if let topViewController = topViewController {
            return topViewController.shouldAutorotate
        }
        return super.shouldAutorotate
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let topViewController = topViewController {
            if topViewController is AutorotateProtocol {
                return topViewController.supportedInterfaceOrientations
            } else {
                return .portrait
            }
        }
        return super.supportedInterfaceOrientations
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if let topViewController = topViewController {
            return topViewController.preferredInterfaceOrientationForPresentation
        }
        return super.preferredInterfaceOrientationForPresentation
    }
}

/// override var shouldAutorotate iOS 16 不再生效, 返回 true/false 都能自动旋转
/// override var supportedInterfaceOrientations 只能通过它来实现
/// https://github.com/TheLittleBoy/HXRotationTool
/// https://blog.csdn.net/thelittleboy/article/details/126955521
protocol AutorotateProtocol {
    var shouldAutorotate: Bool { get }
    var supportedInterfaceOrientations: UIInterfaceOrientationMask { get }
}
