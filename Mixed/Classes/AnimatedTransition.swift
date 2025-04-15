//
//  AnimatedTransition.swift
//  Mixed
//
//  Created by vvii on 2024/7/17.
//

// https://www.jianshu.com/p/28b9523d70a9

import UIKit

let sw = UIScreen.main.bounds.width
let sh = UIScreen.main.bounds.height

// MARK: - EmptyViewController
class EmptyViewController: UIViewController, HalfPanelViewDelegate {
    
    lazy var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapGesture(_:)))
        tapGesture.numberOfTapsRequired = 1
        return tapGesture
    }()
    
    lazy var videoView: AnimationWrapperView = {
        return AnimationWrapperView(nil)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addGestureRecognizer(tapGesture)
        videoView.frame = view.bounds
        view.addSubview(videoView)
        VideoPlayer.shared.play(in: videoView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        VideoPlayer.shared.play(in: videoView)
    }
    
    @objc func onTapGesture(_ ges: UITapGestureRecognizer) {
        if presentingViewController != nil {
            dismiss(animated: true)
        } else {
            let vc = HalfPanelViewController()
            vc.delegate = self
            Router.shared.present(vc: vc, style: .overNavigationController)
            // Router.shared.pushViewController(TranstionViewController())
        }
    }
    
    func onHalfPanelViewOriginChanged(y: CGFloat, animationDuration: Double, curve: CubicBezierCurve) {
        let h = y
        let w = sw / sh * h
        let x = (sw - w) / 2
        let y = 0.0
        let from = videoView.frame
        let to = CGRect(x: x, y: y, width: w, height: h)
        videoView.animate(from: from, to: to, duration: animationDuration, curve: curve) { rect in
            VideoPlayer.shared.updatePlayerLayer(frame: rect)
        }
    }
    
    deinit {
        print(#function, self)
    }
}


// MARK: - 1. Push & Pop Animation
class TranstionViewController: UIViewController, UINavigationControllerDelegate {
    
    lazy var panGesture: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPanGesture(_:)))
        panGesture.require(toFail: Router.shared.navigationController.interactivePopGestureRecognizer!)
        return panGesture
    }()
    
    var interactiveTransition: UIPercentDrivenInteractiveTransition?
    var interactiveStartLocation: CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .random
        view.addGestureRecognizer(panGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 代理手动设置为 nil 或者当前控制器被释放, 则交给系统自动处理
        // 动画失效时检查 delegate 是否为 nil
        Router.shared.navigationController.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Router.shared.navigationController.delegate = nil
    }
    
    // MARK: - UINavigationControllerDelegate, push & pop
    /// 交互式转场, 自定义手势驱动.
    /// 手势驱动结束后必须要设置为 nil, 否则下次 Pop 会导致 finish() 和 cancel() 无法调用, 界面卡死
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition // UIPercentDrivenInteractiveTransition()
    }

    /// 自定义转场动画
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            return PushAnimation()
        } else if operation == .pop {
            return PopAnimation()
        }
        return nil // 系统默认动画
    }
    
    @objc func onPanGesture(_ ges: UIPanGestureRecognizer) {
        let currX = ges.location(in: view.window!).x
        let startX = interactiveStartLocation?.x ?? currX
        var progress = (currX - startX) / view.window!.bounds.width
        if startX > sw / 2  {
            progress = max(-progress, 0)
        } else {
            progress = max(progress, 0)
        }
        switch ges.state {
        case .began:
            interactiveTransition = UIPercentDrivenInteractiveTransition()
            interactiveStartLocation = ges.location(in: view.window!)
            // 手势驱动控制 push or pop
            if startX > sw / 2  { // e.g. 知乎
                Router.shared.pushViewController(EmptyViewController(), animated: true)
            } else {    // e.g. 侧滑返回
                Router.shared.popViewController()
            }
        case .changed:
            interactiveTransition?.update(progress)
        default:
            progress < 0.5 ? interactiveTransition?.cancel() : interactiveTransition?.finish()
            interactiveTransition = nil
            interactiveStartLocation = nil
        }
    }
    
    deinit {
        print(#function, self)
    }
}

/// PushAnimation
class PushAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    /// 动画时长
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    /// 动画实现
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(using: transitionContext)
        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        transitionContext.containerView.insertSubview(toView, aboveSubview: fromView) // 必须
        fromView.frame = CGRect(x: 0, y: 0, width: sw, height: sh)
        toView.frame = CGRect(x: sw, y: 0, width: sw, height: sh)
        UIView.animate(withDuration: duration) {
            fromView.frame = CGRect(x: -sw * 0.3, y: 0, width: sw, height: sh)
            toView.frame = CGRect(x: 0, y: 0, width: sw, height: sh)
        } completion: { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled) // 必须
        }
    }
}

/// PopAnimation
class PopAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    /// 动画时长
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
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
        }
    }
}


// MARK: - 2. Present & Dissmiss Animation
class ModalViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    lazy var panGesture: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPanGesture(_:)))
        panGesture.require(toFail: Router.shared.navigationController.interactivePopGestureRecognizer!)
        return panGesture
    }()
    
    var interactiveTransition: UIPercentDrivenInteractiveTransition?
    var interactiveStartLocation: CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .random
        // 代理手动设置为 nil 或者当前控制器被释放, 则交给系统自动处理
        // 动画失效时检查 delegate 是否为 nil
        self.transitioningDelegate = self
        view.addGestureRecognizer(panGesture)
    }
    
    // MARK: - UIViewControllerTransitioningDelegate, present & dismiss
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentAnimation()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimation()
    }

    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return nil
    }
    
    @objc func onPanGesture(_ ges: UIPanGestureRecognizer) {
        let currY = ges.location(in: view.window!).y
        let startY = interactiveStartLocation?.y ?? currY
        var progress = (currY - startY) / view.window!.bounds.width
        if startY > sh / 2  {
            progress = max(-progress, 0)
        } else {
            progress = max(progress, 0)
        }
        switch ges.state {
        case .began:
            interactiveTransition = UIPercentDrivenInteractiveTransition()
            interactiveStartLocation = ges.location(in: view.window!)
            // 手势驱动控制 push or pop
            if startY > sh / 2  { // e.g. 知乎
                let vc = ModalViewController()
                vc.transitioningDelegate = self
                Router.shared.present(vc: vc, style: .overCurrentContext(self))
            } else {    // e.g. 侧滑返回
                dismiss(animated: true)
            }
        case .changed:
            interactiveTransition?.update(progress)
        default:
            progress < 0.5 ? interactiveTransition?.cancel() : interactiveTransition?.finish()
            interactiveTransition = nil
            interactiveStartLocation = nil
        }
    }

    deinit {
        print(#function, self)
    }
}

/// PresentAnimation, fromView == nil
class PresentAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    /// 动画时长
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    /// 动画实现
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(using: transitionContext)
        let toView = transitionContext.view(forKey: .to)!
        transitionContext.containerView.addSubview(toView) // 必须
        toView.frame = CGRect(x: 0, y: sh, width: sw, height: sh)
        UIView.animate(withDuration: duration) {
            toView.frame = CGRect(x: 0, y: 0, width: sw, height: sh)
        } completion: { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled) // 必须
        }
    }
}

/// DismissAnimation, toView == nil
class DismissAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    /// 动画时长
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    /// 动画实现
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(using: transitionContext)
        let fromView = transitionContext.view(forKey: .from)!
        fromView.frame = CGRect(x: 0, y: 0, width: sw, height: sh)
        UIView.animate(withDuration: duration) {
            fromView.frame = CGRect(x: 0, y: sh, width: sw, height: sh)
        } completion: { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled) // 必须
        }
    }
}


// MARK: - 3. UIPresentationController
class PresentationViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .random
    }
    
    // MARK: - UIViewControllerTransitioningDelegate, presentation
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController.init(presentedViewController: presented, presenting: presenting)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let vc = EmptyViewController()
        vc.transitioningDelegate = self
        Router.shared.present(vc: vc, style: .custom(self, .custom)) // 必须设置 UIModalPresentationStyle.custom
    }
    
    deinit {
        print(#function, self)
    }
}

/// 半弹窗容器
class PresentationController: UIPresentationController {
    
    lazy var backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .black
        return backgroundView
    }()
    
    override func presentationTransitionWillBegin() {
        containerView?.addSubview(backgroundView)
        backgroundView.frame = containerView?.bounds ?? .zero
        backgroundView.alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.backgroundView.alpha = 0.2
        }
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        
    }

    override func dismissalTransitionWillBegin() {
        UIView.animate(withDuration: 0.25) {
            self.backgroundView.alpha = 0
        }
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let h = PresentationHeight
        return CGRect(x: 0, y: sh - h, width: sw, height: h)
    }
}

let PresentationHeight = sh - 64
