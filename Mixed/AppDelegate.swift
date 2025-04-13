//
//  AppDelegate.swift
//  Mixed
//
//  Created by vvii on 2024/1/27.
//

import UIKit


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var classes: [UIViewController.Type] = [
        VideoListViewController.self, //
        StreamViewController.self,
        WebKitViewController.self,
        FullScreenViewController.self,
        FLEXViewController.self,
        VideoListViewController.self,
        IJKPlayerViewControllerClass,
        SmoothLineViewController.self,
        UnsafePointerController.self,
        BezierCurveViewController.self,
        SettingsViewController.self,
        ImagePreviewViewController.self,
        PresentationViewController.self,
        TranstionViewController.self,
        ModalViewController.self,
        MainViewController.self,
    ]

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupManagers(); runTest();
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = Router.shared.navigationControllerWrapped(vc: RootTabBarController.init(classes))
        window?.makeKeyAndVisible()
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .allButUpsideDown // 优先级高于 General - Deployment Info / Info
    }
}

extension AppDelegate {
    
    func setupManagers() {
        LogManager.shared.setup(logger: DDLogger())
        CrashManager.shared.setup()
    }
}
