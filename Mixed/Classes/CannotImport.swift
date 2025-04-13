//
//  CannotImport.swift
//  Mixed
//
//  Created by vvii on 2024/8/27.
//

import UIKit

/* for example:
     #if canImport(IJKPlayer)
         import IJKPlayer
         let IJKPlayerViewControllerClass = IJKPlayerViewController.self
     #else
         let IJKPlayerViewControllerClass = CannotImportViewController.self
     #endif
 */
class CannotImportViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertController(title: "Cannot import the framework", message: "See details in Podfile or other places")
            .addAction(UIAlertAction(title: "OK", style: .cancel))
            .show(presenting: self)
    }
}

