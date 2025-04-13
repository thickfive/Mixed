//
//  FLEX.swift
//  Mixed
//
//  Created by vvii on 2024/9/13.
//

import UIKit
#if canImport(FLEX)
import FLEX
#endif

class FLEXViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
#if canImport(FLEX)
        FLEXManager.shared.showExplorer()
#endif
    }
}
