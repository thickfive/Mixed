//
//  VideoPlayerController2.swift
//  Mixed
//
//  Created by vvii on 2025/4/11.
//

import UIKit

class VideoPlayerController2: VideoPlayerController {
    
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
                // --- start ---
                // 重置 frame
                let lastFrame = self.contentView.frame
                self.contentView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.contentView.frame = lastFrame
                self.contentView.backgroundColor = .black
                self.videoView.frame = CGRect(x: 0, y: 0, width: sourceViewFrame.width, height: sourceViewFrame.height)
                VideoPlayer.shared.play(in: self.videoView)
                UIView.animate(withDuration: TransitionDuration * progress) {
                    self.contentView.frame = self.sourceViewFrame
                } completion: { _ in
                    self.interactiveTransition?.finish()
                    self.interactiveTransition = nil
                    self.interactiveStartLocation = nil
                }
                // --- end ---
            }
        }
    }
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(using: transitionContext)
        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.viewController(forKey: .from)!.view!
        
        // --- start ---
        if transitionContext.viewController(forKey: .to) == self { // push
            transitionContext.containerView.insertSubview(toView, aboveSubview: fromView) // 必须
            toView.backgroundColor = .clear
            self.contentView.frame = sourceViewFrame
            self.contentView.backgroundColor = .black
            UIView.animate(withDuration: duration) {
                toView.backgroundColor = .black
                self.contentView.frame = self.view.bounds
            } completion: { finished in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled) // 必须
            }
        } else { // pop
            transitionContext.containerView.insertSubview(toView, belowSubview: fromView) // 必须
            if self.interactiveTransition == nil {
                fromView.backgroundColor = .black
                self.videoView.frame = CGRect(x: 0, y: 0, width: sourceViewFrame.width, height: sourceViewFrame.height)
                VideoPlayer.shared.play(in: self.videoView)
                UIView.animate(withDuration: duration) {
                    fromView.backgroundColor = .clear
                    self.contentView.frame = self.sourceViewFrame
                } completion: { finished in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled) // 必须
                }
            } else {
                self.contentView.backgroundColor = .clear
                UIView.animate(withDuration: duration) {
                    fromView.backgroundColor = .clear
                } completion: { finished in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled) // 必须
                }
            }
        }
        // --- end ---
    }
}

