//
//  VideoPlayerController3.swift
//  Mixed
//
//  Created by vvii on 2025/4/11.
//

import UIKit

class VideoPlayerController3: VideoPlayerController, CAAnimationDelegate {
    
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
                let lastCenter = CGPoint(x: lastFrame.minX + lastFrame.width / 2, y: lastFrame.minY + lastFrame.height / 2)
                self.contentView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.contentView.frame = self.view.bounds
                
                let boundsAnimation = CABasicAnimation(keyPath: "bounds")
                boundsAnimation.fromValue = NSValue(cgRect: lastFrame)
                boundsAnimation.toValue = NSValue(cgRect: sourceViewFrame)
                boundsAnimation.duration = TransitionDuration * progress
                boundsAnimation.isRemovedOnCompletion = false
                boundsAnimation.fillMode = .forwards
                
                
                let positionAnimation = CABasicAnimation(keyPath: "position")
                positionAnimation.fromValue = NSValue(cgPoint: lastCenter)
                positionAnimation.toValue = NSValue(cgPoint: sourceViewCenter)
                positionAnimation.duration = TransitionDuration * progress
                positionAnimation.isRemovedOnCompletion = false
                positionAnimation.fillMode = .forwards
                
                let groupAnimation = CAAnimationGroup()
                groupAnimation.animations = [
                    boundsAnimation,
                    positionAnimation
                ]
                groupAnimation.duration = TransitionDuration * progress
                groupAnimation.isRemovedOnCompletion = false
                groupAnimation.delegate = self
                
                VideoPlayer.shared.playerLayer.add(groupAnimation, forKey: "interactivePop")
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
            UIView.animate(withDuration: duration) {
                toView.backgroundColor = .black
            }
            
            // [iOS - CABasicAnimation（基础动画）](https://blog.csdn.net/zj382561388/article/details/103794711)
            // CAAnimationGroup 的大部分属性对子动画基本上都不起作用, 最好分开设置
            let boundsAnimation = CABasicAnimation(keyPath: "bounds")
            boundsAnimation.fromValue = NSValue(cgRect: sourceViewFrame)
            boundsAnimation.toValue = NSValue(cgRect: view.bounds)
            boundsAnimation.duration = duration
            boundsAnimation.isRemovedOnCompletion = false
            boundsAnimation.fillMode = .forwards
            
            let positionAnimation = CABasicAnimation(keyPath: "position")
            positionAnimation.fromValue = NSValue(cgPoint: sourceViewCenter)
            positionAnimation.toValue = NSValue(cgPoint: view.center)
            positionAnimation.duration = duration
            positionAnimation.isRemovedOnCompletion = false
            positionAnimation.fillMode = .forwards
            
            let groupAnimation = CAAnimationGroup()
            groupAnimation.animations = [
                boundsAnimation,
                positionAnimation
            ]
            groupAnimation.duration = duration // 需要单独设置
            groupAnimation.isRemovedOnCompletion = false
            groupAnimation.delegate = self
            
            VideoPlayer.shared.playerLayer.add(groupAnimation, forKey: "push")
        } else { // pop
            transitionContext.containerView.insertSubview(toView, belowSubview: fromView) // 必须
            if self.interactiveTransition == nil {
                fromView.backgroundColor = .black
                UIView.animate(withDuration: duration) {
                    fromView.backgroundColor = .clear
                }
                
                let boundsAnimation = CABasicAnimation(keyPath: "bounds")
                boundsAnimation.fromValue = NSValue(cgRect: view.bounds)
                boundsAnimation.toValue = NSValue(cgRect: sourceViewFrame)
                boundsAnimation.duration = duration
                boundsAnimation.isRemovedOnCompletion = false
                boundsAnimation.fillMode = .forwards
                
                let positionAnimation = CABasicAnimation(keyPath: "position")
                positionAnimation.fromValue = NSValue(cgPoint: view.center)
                positionAnimation.toValue = NSValue(cgPoint: sourceViewCenter)
                positionAnimation.duration = duration
                positionAnimation.isRemovedOnCompletion = false
                positionAnimation.fillMode = .forwards
                
                let groupAnimation = CAAnimationGroup()
                groupAnimation.animations = [
                    boundsAnimation,
                    positionAnimation
                ]
                groupAnimation.duration = duration
                groupAnimation.isRemovedOnCompletion = false
                groupAnimation.delegate = self
                
                VideoPlayer.shared.playerLayer.add(groupAnimation, forKey: "pop")
            } else {
                fromView.backgroundColor = .black
                UIView.animate(withDuration: duration) {
                    fromView.backgroundColor = .clear
                } completion: { _ in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
            }
        }
        // --- end ---
        
        self.transitionContext = transitionContext
    }
    
    weak var transitionContext: UIViewControllerContextTransitioning!
    
    func animationDidStart(_ anim: CAAnimation) {
        
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if VideoPlayer.shared.playerLayer.animation(forKey: "push") == anim || VideoPlayer.shared.playerLayer.animation(forKey: "pop") == anim {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled) // 必须
            VideoPlayer.shared.playerLayer.removeAllAnimations() // 必须, 否则在其他页面视频的大小位置很奇怪
        }
        if VideoPlayer.shared.playerLayer.animation(forKey: "interactivePop") == anim {
            self.interactiveTransition?.finish()
            self.interactiveTransition = nil
            self.interactiveStartLocation = nil
            mainAsync {
                VideoPlayer.shared.playerLayer.removeAllAnimations() // 手势驱动 pop 最后会闪一下
                VideoPlayer.shared.play(in: self.sourceView) // 需要重新设置播放器的大小
            }
        }
    }
}

