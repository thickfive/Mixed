//
//  WebKitViewController.swift
//  Mixed
//
//  Created by vvii on 2024/8/4.
//

import WebKit

class WebKitViewController: UIViewController {
    
    lazy var config = {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        return config
    }()
    
    lazy var webView = WKWebView(frame: self.view.bounds, configuration: config)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(webView)
        let request = URLRequest(url: URL(string: "https://www.baidu.com")!)
        webView.load(request)
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.scrollView.contentSize), options: [.old, .new], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.scrollView.contentSize) {
            if let value = change?[.newKey] {
                print("value", value)
            }
        }
    }
}
