//
//  VideoPlayerController.swift
//  Mixed
//
//  Created by vvii on 2025/4/11.
//

import UIKit

let TransitionDuration: Double = 0.5

class VideoPlayerController: UIViewController, UINavigationControllerDelegate, UIViewControllerAnimatedTransitioning {
    
    weak var sourceView: UIView!
    var sourceViewFrame: CGRect {
        return sourceView.superview!.convert(sourceView.frame, to: nil)
    }
    var sourceViewCenter: CGPoint {
        let svf = sourceViewFrame
        return CGPoint(x: svf.minX + svf.width / 2, y: svf.minY + svf.height / 2)
    }
    
    lazy var panGesture: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPanGesture(_:)))
        panGesture.require(toFail: Router.shared.navigationController.interactivePopGestureRecognizer!)
        return panGesture
    }()
    
    var interactiveTransition: UIPercentDrivenInteractiveTransition?
    var interactiveStartLocation: CGPoint?
    var interactiveCurrLocation: CGPoint?
    
    lazy var snapshotView: UIView = {
        let snapshotView = self.sourceView.snapshotView(afterScreenUpdates: false)!
        return snapshotView
    }()
    
    lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.clipsToBounds = true
        return contentView
    }()
    
    lazy var videoView: AnimationWrapperView = {
        let videoView = AnimationWrapperView(nil)
        return videoView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black.withAlphaComponent(1)
        view.addGestureRecognizer(panGesture)
        contentView.frame = view.bounds
        view.addSubview(contentView)
        videoView.frame = contentView.bounds
        videoView.clipsToBounds = true
        videoView.backgroundColor = .clear
        contentView.addSubview(videoView)
        VideoPlayer.shared.play(in: videoView, animation: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 代理手动设置为 nil 或者当前控制器被释放, 则交给系统自动处理
        // 动画失效时检查 delegate 是否为 nil
        Router.shared.navigationController.delegate = self
        Router.shared.navigationController.interactivePopGestureRecognizer?.isEnabled = false
        VideoPlayer.shared.play(in: videoView, animation: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Router.shared.navigationController.delegate = nil
        Router.shared.navigationController.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    // MARK: - UINavigationControllerDelegate, push & pop
    /// 交互式转场, 自定义手势驱动
    /// 手势驱动结束后必须要设置为 nil, 否则下次 Pop 会导致 finish() 和 cancel() 无法调用, 界面卡死
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition // UIPercentDrivenInteractiveTransition()
    }

    /// 自定义转场动画
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
        // return nil // 系统默认动画
    }
    
    /// 动画时长
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TransitionDuration
    }
    
    /// override
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        fatalError("In class \(self.classForCoder) need override func: \(#function)")
    }
    
    /// override
    @objc func onPanGesture(_ ges: UIPanGestureRecognizer) {
        fatalError("In class \(self.classForCoder) need override func: \(#function)")
    }
    
    deinit {
        print(#function, self)
    }
}


