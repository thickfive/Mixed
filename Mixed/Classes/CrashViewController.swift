//
//  CrashViewController.swift
//  Mixed
//
//  Created by vvii on 2025/4/23.
//

import UIKit

class CrashViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertController(title: "Crash test", message: nil)
            .addAction(UIAlertAction(title: "Crash", style: .destructive, handler: { _ in
                self.crashTest001()
            }))
            .addAction(UIAlertAction(title: "Cancel", style: .cancel))
            .show(presenting: self)
    }
    
    @inline(never) func crashTest001() {
        print(#function, #line)
        crashTest002()
    }
    
    @inline(never) func crashTest002() {
        print(#function, #line)
        var view: UIView!
        view.removeFromSuperview()
        view = UIView()
    }
}
