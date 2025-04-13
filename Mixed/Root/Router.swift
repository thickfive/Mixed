//
//  Router.swift
//  Mixed
//
//  Created by vvii on 2024/1/28.
//

import UIKit

class Router: NSObject {
    static let shared = Router()
    var navigationController = UINavigationController()
    var tabBarController = UITabBarController()
    
    func navigationControllerWrapped(vc: UITabBarController) -> UINavigationController {
        navigationController = RootNavigationController(rootViewController: vc)
        tabBarController = vc
        return navigationController
    }
    
    func pushViewController(_ vc: UIViewController, animated: Bool = true) {
        let wrapped = vc // WrapperController(vc)
        navigationController.pushViewController(wrapped, animated: animated)
    }
    
    func popViewController(animated: Bool = true) {
        navigationController.popViewController(animated: animated)
    }
    
    func popToRootViewController(animated: Bool = true) {
        navigationController.popToRootViewController(animated: animated)
    }
    
    func present(vc: UIViewController, style: ModalPresentationStyle) {
        switch style {
        case .overNavigationController:
            vc.modalPresentationStyle = .overCurrentContext
            navigationController.present(vc, animated: true)
        case .overTabBarController:
            vc.modalPresentationStyle = .overCurrentContext
            tabBarController.present(vc, animated: true)
        case .overCurrentContext(let currentContext):
            vc.modalPresentationStyle = .overCurrentContext
            currentContext.present(vc, animated: true)
        case .custom(let currentContext, let style):
            vc.modalPresentationStyle = style
            currentContext.present(vc, animated: true)
        }
        print(#function, style, vc.modalPresentationStyle.rawValue)
    }
}

enum ModalPresentationStyle {
    case overNavigationController
    case overTabBarController
    case overCurrentContext(UIViewController)
    case custom(UIViewController, UIModalPresentationStyle)
}
