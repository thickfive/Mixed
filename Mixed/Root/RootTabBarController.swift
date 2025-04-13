//
//  RootTabBarController.swift
//  Mixed
//
//  Created by vvii on 2024/1/28.
//

import UIKit

class RootTabBarController: UITabBarController, AutorotateProtocol {
    
    init(_ classes: [UIViewController.Type]) {
        super.init(nibName: nil, bundle: nil)
        var viewControllers: [UIViewController] = []
        for (_, cls) in classes.enumerated() {
            let vc = cls.init()
            var name = String(NSStringFromClass(cls).split(separator: ".").last ?? "")
            name = name.replacingOccurrences(of: "ViewController", with: "")
            name = name.replacingOccurrences(of: "Controller", with: "")
            let item = UITabBarItem(title: "\(name)", image: UIImage(systemName: "house"), selectedImage: UIImage(named: "home_selected"))
            vc.extendedLayoutIncludesOpaqueBars = true
            vc.tabBarItem = item
            viewControllers += [vc] // [UINavigationController(rootViewController: vc)]
        }
        self.viewControllers = viewControllers
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .gray
        title = "Home"
        
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .white.withAlphaComponent(0.1)

        UITabBar.appearance().backgroundColor = .white.withAlphaComponent(0.5)
        UITabBar.appearance().isTranslucent = true
        UITabBar.appearance().barTintColor = .green.withAlphaComponent(0.5)
        
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    override var shouldAutorotate: Bool {
        if let topViewController = selectedViewController {
            return topViewController.shouldAutorotate
        }
        return super.shouldAutorotate
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let topViewController = selectedViewController {
            if topViewController is AutorotateProtocol {
                return topViewController.supportedInterfaceOrientations
            } else {
                return .portrait
            }
        }
        return super.supportedInterfaceOrientations
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if let topViewController = selectedViewController {
            return topViewController.preferredInterfaceOrientationForPresentation
        }
        return super.preferredInterfaceOrientationForPresentation
    }
}

class WrapperController: UITabBarController {
    init(_ vc: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        viewControllers = [vc]
        tabBar.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print(#function, self)
    }
}
