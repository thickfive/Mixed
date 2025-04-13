//
//  AlertController.swift
//  Mixed
//
//  Created by vvii on 2024/8/5.
//

import UIKit

class AlertController: NSObject {
    
    let vc: UIAlertController
    
    init(title: String?, message: String? = nil, preferredStyle: UIAlertController.Style = .alert) {
        vc = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
    }
    
    func addAction(_ action: UIAlertAction) -> AlertController {
        vc.addAction(action)
        return self
    }
    
    func show(presenting: UIViewController, animated: Bool = true) {
        presenting.present(vc, animated: true)
    }
    
    deinit {
        print(#function, self)
    }
}
