//
//  Settings.swift
//  Mixed
//
//  Created by vvii on 2024/8/2.
//

import UIKit
import WebKit

class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertController(title: "Clear Cache?")
            .addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
                self?.clearCache()
            })
            .addAction(UIAlertAction(title: "No", style: .cancel))
            .show(presenting: self)
    }
    
    func clearCache() {
        // 视频缓存
        VideoPlayer.shared.clearCache()
        // WebKit 缓存
        print(WKWebsiteDataStore.allWebsiteDataTypes())
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) {
            $0.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record]) {
                    print("webkit remove data for \(record)")
                }
            }
        }
        // ...
        // 日志
        LogManager.shared.clearLogFiles()
    }
}
