//
//  KeyboardViewController.swift
//  测试键盘
//
//  Created by vvii on 2025/4/24.
//

import UIKit
import SnapKit

class KeyboardViewController: UIInputViewController {
    
    var keyboardContainerView: UIView!
    var nextKeyboardButton: UIButton!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        addKeyboardButtons()
    }
    
    func addKeyboardButtons() {
        addKeyboardContainerView()
        addNextKeyboardButton()
    }
    
    func addNextKeyboardButton() {
        nextKeyboardButton = UIButton(type: .system) as UIButton
//        nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), for: .normal)
        nextKeyboardButton.setImage(UIImage(systemName: "globe"), for: .normal)
        nextKeyboardButton.sizeToFit()
        nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        nextKeyboardButton.addTarget(self, action: #selector(advanceToNextInputMode), for: .touchUpInside)

        view.addSubview(nextKeyboardButton)
        nextKeyboardButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func addKeyboardContainerView() {
        keyboardContainerView = UIView()
        keyboardContainerView.backgroundColor = .systemBlue.withAlphaComponent(0.2)
        view.addSubview(keyboardContainerView)
        keyboardContainerView.snp.makeConstraints { make in
            // make.leading.trailing.top.bottom.equalToSuperview()
            make.edges.equalToSuperview()
            // 额外的约束, 通过 AutoLayout 来控制键盘的高度
            make.height.equalTo(216)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        keyboardContainerView.snp.updateConstraints({ make in
            make.height.equalTo(CGFloat(Int.random(in: 216..<500)))
        })
        // TODO:动画没效果
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
            self.keyboardContainerView.layoutIfNeeded()
        }
    }
}
