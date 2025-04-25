//
//  KeyboardViewController.swift
//  Mixed
//
//  Created by vvii on 2025/4/20.
//

import UIKit

class KeyboardViewController: UIViewController {
    
    let text = """
/// 测试条件：iOS 16，不同条件下键盘消失的方式不一致
/// a. 系统默认动画（侧滑，返回）
/// - textField.becomeFirstResponder(), 进入当前页面、侧滑或者点击返回上一页，键盘跟随页面左右移动
/// - textField.resignFirstResponder(), 键盘向下消失
/// b. 自定义动画（自定义手势）
/// - 不调用 textField.resignFirstResponder() 的前提下，键盘跟随手势上下移动
/// - 在 transitionDuration(using:) 里调用 textField.resignFirstResponder(), 键盘向下消失，取消动画重新出现
/// - 在 animateTransition(using:) 里调用 textField.resignFirstResponder(), 键盘跟随手势上下移动
/// - 在其他地方调用 textField.resignFirstResponder()，键盘向下消失
/// c. 自定义动画（自定义手势+键盘截图）
/// - 在pop动画开始之前键盘截图，收起键盘，用截图 _UIReplicantView 代替。实际上系统动画对键盘就是这么处理的
/// - ⚠️：切换其他键盘（搜狗输入法）有问题，反复快速 pop & cancel 就会崩溃，通过限制该场景发生的频率从而减少崩溃的概率
/// - ❌：这个是 iOS 16 的系统 bug，https://developer.apple.com/forums/thread/715176?answerId=745522022#745522022
/// - ✅：解决方案 https://github.com/SnowGirls/Objc-Deallocating
"""
    lazy var textLabel: UILabel = {
        let textLabel = UILabel(frame: CGRect(x: 20, y: 0, width: self.view.bounds.width - 40, height: self.view.bounds.height))
        textLabel.numberOfLines = 0
        textLabel.textColor = .darkText
        textLabel.text = text
        return textLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(textLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let vc = KeyboardViewController2()
        Router.shared.pushViewController(vc)
    }
}

class KeyboardViewController2: UIViewController {
    
    lazy var textField: UITextField = {
        let textField = UITextField(frame: CGRect(x: 20, y: 100, width: self.view.bounds.width - 40, height: 40))
        textField.backgroundColor = .systemGray6
        textField.layer.borderColor = UIColor.systemBlue.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 4
        textField.layer.masksToBounds = true
        textField.placeholder = "What can i say? Man!"
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(textField)
        textFieldBecomeFirstResponder()
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { notification in
            if let userInfo = notification.userInfo,
               let frameEnd = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
               let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
               let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
            {
                UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve)) {
                    self.textField.frame.origin.y = frameEnd.minY - self.textField.frame.height - 12
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // textFieldBecomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // textFieldBecomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // textField.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let vc = KeyboardViewController3()
        Router.shared.pushViewController(vc)
    }
    
    func textFieldBecomeFirstResponder(placeholder: String = #function) {
        textField.placeholder = placeholder
        textField.becomeFirstResponder()
    }
}

class KeyboardViewController3: UIViewController, UINavigationControllerDelegate {
    
    lazy var panGesture: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPanGesture(_:)))
        // 保留系统侧滑返回手势
        panGesture.require(toFail: Router.shared.navigationController.interactivePopGestureRecognizer!)
        return panGesture
    }()
    
    lazy var textField: UITextField = {
        let textField = UITextField(frame: CGRect(x: 20, y: 100, width: self.view.bounds.width - 40, height: 40))
        textField.backgroundColor = .systemGray6
        textField.layer.borderColor = UIColor.systemBlue.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 4
        textField.layer.masksToBounds = true
        textField.placeholder = "What can i say? Man!"
        return textField
    }()
    
    var interactiveTransition: UIPercentDrivenInteractiveTransition?
    var interactiveStartLocation: CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .random
        view.addGestureRecognizer(panGesture)
        view.addSubview(textField)
        textFieldBecomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Router.shared.navigationController.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Router.shared.navigationController.delegate = nil
    }
    
    func textFieldBecomeFirstResponder(placeholder: String = #function) {
        textField.placeholder = placeholder
        textField.becomeFirstResponder()
    }
    
    // MARK: - UINavigationControllerDelegate, push & pop
    /// 交互式转场, 自定义手势驱动.
    /// 手势驱动结束后必须要设置为 nil, 否则下次 Pop 会导致 finish() 和 cancel() 无法调用, 界面卡死
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition // UIPercentDrivenInteractiveTransition()
    }

    /// 自定义转场动画
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // UIApplication.shared.windows
        let windows = UIApplication.shared.connectedScenes.flatMap({ ($0 as? UIWindowScene)?.windows ?? [] })
        if let keyboardWindowClass = NSClassFromString("UITextEffectsWindow"),
            let keyboardWindow = windows.first(where: { $0.isKind(of: keyboardWindowClass )}),
            let keyboardView = keyboardWindow.rootViewController?.view.subviews.first {
            // 想要截图键盘只能用全屏截图, 并且参数只能用false
            // let screenSnapshot = keyboardWindow.screen.snapshotView(afterScreenUpdates: false)
            // keyboardWindow.screen 有时候（比如切换键盘）截不到图，改用 UIScreen.main
            let screenSnapshot = UIScreen.main.snapshotView(afterScreenUpdates: false)
            withoutAnimation {
                self.textField.resignFirstResponder()
            }
            keyboardSnapshot.frame = CGRect(x: 0,
                                            y: view.bounds.height - keyboardView.bounds.height,
                                            width: keyboardView.bounds.width,
                                            height: keyboardView.bounds.height)
            // 只保留键盘部分
            keyboardSnapshot.bounds.origin.y = view.bounds.height - keyboardView.bounds.height
            keyboardSnapshot.clipsToBounds = true
            keyboardSnapshot.subviews.forEach { $0.removeFromSuperview() }
            keyboardSnapshot.addSubview(screenSnapshot)
            view.addSubview(keyboardSnapshot)
        }

        if operation == .pop {
            return self
        }
        return nil // 系统默认动画
    }
    
    var keyboardSnapshot = UIView()
    
    @objc func onPanGesture(_ ges: UIPanGestureRecognizer) {
        let currX = ges.location(in: view.window!).x
        let startX = interactiveStartLocation?.x ?? currX
        let progress = max((currX - startX) / view.window!.bounds.width, 0)
        let velocity = ges.velocity(in: view.window!).x
        let estimatedProgress = max((currX + velocity - startX) / view.window!.bounds.width, 0)
        switch ges.state {
        case .began:
            interactiveTransition = UIPercentDrivenInteractiveTransition()
            interactiveStartLocation = ges.location(in: view.window!)
            if estimatedProgress > 0 {
                Router.shared.popViewController()
            }
        case .changed:
            interactiveTransition?.update(progress)
        default:
            estimatedProgress < 0.5 ? interactiveTransition?.cancel() : interactiveTransition?.finish()
            interactiveTransition = nil
            interactiveStartLocation = nil
        }
    }
    
    deinit {
        print(#function, self)
    }
}

/// PopAnimation
extension KeyboardViewController3: UIViewControllerAnimatedTransitioning {
    /// 动画时长
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        // textField.resignFirstResponder() // 键盘直接向下消失，取消出现
        return 0.5
    }
    
    /// 动画实现
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(using: transitionContext)
        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        transitionContext.containerView.insertSubview(toView, belowSubview: fromView) // 必须
        fromView.frame = CGRect(x: 0, y: 0, width: sw, height: sh)
        toView.frame = CGRect(x: -sw * 0.3, y: 0, width: sw, height: sh)
        UIView.animate(withDuration: duration) {
            fromView.frame = CGRect(x: sw, y: 0, width: sw, height: sh)
            toView.frame = CGRect(x: 0, y: 0, width: sw, height: sh)
        } completion: { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled) // 必须
            self.keyboardSnapshot.removeFromSuperview()
        }
        // textField.resignFirstResponder() // 键盘跟随手势向下
        textField.placeholder = #function
    }
}
