//
//  VideoPlayerController1.swift
//  Mixed
//
//  Created by vvii on 2025/4/11.
//

import UIKit

class VideoPlayerController1: VideoPlayerController {
    
    override func onPanGesture(_ ges: UIPanGestureRecognizer) {
        let currX = ges.location(in: view.window!).x
        let startX = interactiveStartLocation?.x ?? currX
        let progress = max((currX - startX) / view.window!.bounds.width, 0)
        switch ges.state {
        case .began:
            interactiveTransition = UIPercentDrivenInteractiveTransition()
            interactiveStartLocation = ges.location(in: view.window!)
            // 手势驱动控制 push or pop
            Router.shared.popViewController()
        case .changed:
            self.snapshotView.isHidden = true
            interactiveTransition?.update(progress)
            print(#function, progress)
            let point1 = ges.location(in: view.window!)
            let point0 = interactiveStartLocation ?? point1
            contentView.layer.anchorPoint = CGPoint(x: point0.x / sw, y: point0.y / sh)
            contentView.layer.position = point1
            contentView.transform = CGAffineTransform(scaleX: 1 - progress / 3, y: 1 - progress / 3)
        default:
            if progress < 0.5 {
                UIView.animate(withDuration: 0.1) {
                    self.contentView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                    self.contentView.layer.position = CGPoint(x: sw / 2, y: sh / 2)
                    self.contentView.transform = CGAffineTransform(scaleX: 1, y: 1)
                }
                interactiveTransition?.cancel()
                interactiveTransition = nil
                interactiveStartLocation = nil
            } else {
                // 1. 修改 layer.frame 时有个很难控制的隐式动画, UIView.animate 对它不起作用, 改用两个 transform 叠加来还原位置
                // 2. 通过 CATransiton 控制隐式动画开关
                // --- start ---
                let sx = sourceViewFrame.width / sw
                let sy = sourceViewFrame.height / sh
                self.snapshotView.isHidden = false
                UIView.animate(withDuration: TransitionDuration * progress) {
                    // transform 1
                    self.contentView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                    self.contentView.layer.position = CGPoint(x: sw / 2, y: sh / 2)
                    self.contentView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    // transform 2
                    self.videoView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                    self.videoView.layer.position = self.sourceViewCenter
                    self.videoView.transform = CGAffineTransform(scaleX: sx, y: sy)
                } completion: { _ in
                    self.interactiveTransition?.finish()
                    self.interactiveTransition = nil
                    self.interactiveStartLocation = nil
                }
                // --- end --
            }
        }
    }
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(using: transitionContext)
        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.viewController(forKey: .from)!.view!
        let sx = sourceViewFrame.width / sw
        let sy = sourceViewFrame.height / sh
        
        // --- start ---
        if transitionContext.viewController(forKey: .to) == self { // push
            transitionContext.containerView.insertSubview(toView, aboveSubview: fromView) // 必须
            toView.backgroundColor = .clear
            self.contentView.layer.position = sourceViewCenter
            self.contentView.transform = CGAffineTransform(scaleX: sx, y: sy)
            
            self.snapshotView.alpha = 1
            self.snapshotView.frame = self.contentView.bounds
            self.videoView.addSubview(self.snapshotView)
            
            self.sourceView.isHidden = true
            UIView.animate(withDuration: duration) {
                toView.backgroundColor = .black
                self.contentView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.contentView.layer.position = CGPoint(x: sw / 2, y: sh / 2)
                self.snapshotView.alpha = 0
            } completion: { finished in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled) // 必须
                self.snapshotView.removeFromSuperview()
            }
        } else { // pop
            transitionContext.containerView.insertSubview(toView, belowSubview: fromView) // 必须
            fromView.backgroundColor = .black
            
            self.videoView.addSubview(self.snapshotView)
            self.snapshotView.isHidden = false
            
            UIView.animate(withDuration: duration) {
                fromView.backgroundColor = .clear
                self.snapshotView.alpha = 1
                if self.interactiveTransition == nil {
                    self.contentView.transform = CGAffineTransform(scaleX: sx, y: sy)
                    self.contentView.layer.position = self.sourceViewCenter
                }
            } completion: { finished in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled) // 必须
                self.sourceView.isHidden = transitionContext.transitionWasCancelled
            }
        }
        // --- end ---
    }
}
