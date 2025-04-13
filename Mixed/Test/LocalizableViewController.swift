//
//  LocalizableViewController.swift
//  Mixed
//
//  Created by vvii on 2024/1/31.
//

import UIKit

enum Language: String {
    case ar
    case en
    case zh = "zh-Hans"
}

func localizedString(forKey key: String, language: Language) -> String {
    if let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
       let bundle = Bundle.init(path: path) {
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }
    return key
}

class LocalizableViewController: UIViewController {
    
    let textLabel1 = UILabel()
    let textLabel2 = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .lightGray
        
        textLabel1.numberOfLines = 0
        textLabel1.textColor = .green
        textLabel1.font = UIFont.monospacedSystemFont(ofSize: 20, weight: .semibold)
        view.addSubview(textLabel1)
        
        textLabel2.numberOfLines = 0
        textLabel2.textColor = .red
        textLabel2.font = UIFont.monospacedSystemFont(ofSize: 20, weight: .semibold)
        view.addSubview(textLabel2)
        
        // 问题出在阿拉伯语文件第 1212 行, 这一行的书写顺序有问题
        textLabel1.text = string(forKey: "profile_edit_birthday_limit")
        textLabel2.text = string(forKey: "profile_custom_id_expire_tip") // 这个 key 有问题
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let center = view.center
        
        textLabel1.bounds.size = textLabel1.sizeThatFits(view.bounds.size)
        textLabel1.center = CGPoint(x: center.x, y: center.y - 100)
        
        textLabel2.bounds.size = textLabel2.sizeThatFits(view.bounds.size)
        textLabel2.center = CGPoint(x: center.x, y: center.y + 100)
    }
    
    func string(forKey key: String) -> String {
        """
        \(localizedString(forKey: key, language: .en))
        \(localizedString(forKey: key, language: .zh))
        \(localizedString(forKey: key, language: .ar))
        """
    }
}
