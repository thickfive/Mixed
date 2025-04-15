//
//  VideoPlayerController3.swift
//  Mixed
//
//  Created by vvii on 2025/4/11.
//

import UIKit
/*
    1. CAAnimation 开始之后不能像 UIView 动画一样被 UIPercentDrivenInteractiveTransition 接管进度
    2. 只能手动修改 layer.speed = 0 和 layer.timeoffset = xxx 控制进度
    3. 注意是设置在 layer 上, 而不是在 animation 上, animation 属性修改只对动画开始之前有效
    需要自定义 UIViewControllerInteractiveTransitioning 来实现
    https://stackoverflow.com/questions/22868376/uipercentdriveninteractivetransition-with-cabasicanimation
 */
/*
    1. UIView 动画 block 里对应的属性修改, 会在 layer 加上 key 为对应属性的动画
    2. 但是只有 UIViewControllerAnimatedTransitioning 方法里的会被 UIPercentDrivenInteractiveTransition 控制进度
    3. 说明不是简单的修改 layer.speed = 0 & layer.timeOffset = xxx 来实现的, 因为这会影响所有的动画效果
    4. 实际上是分开修改的是动画的 speed 和 timeOffset, layer.presentation 的属性是多个动画效果叠加的结果
    5. 动画一旦添加之后就不允许修改属性, 否则会崩溃, 但是 UIViewControllerAnimatedTransitioning 里面的动画属性可以改变, 不知道是如何实现的
    6. 通过 animation(forKey:) 得到的动画对象不是原来的对象, 是一个不可以手动修改属性的副本, 只有系统自己能改
    总结: CAAnimation 动画开始后属性不能修改, 轻则无效(修改原始对象), 重则崩溃(修改animation(forKey:)副本)
        print(view.layer.animationKeys() ?? [], view.layer.presentation()!.opacity)
        if let anim = view.layer.animation(forKey: "opacity") {
            print("🙂", anim.speed, anim.timeOffset, anim.beginTime, CACurrentMediaTime())
        }
        if let anim = view.layer.animation(forKey: "backgroundColor") {
            print("👻", anim.speed, anim.timeOffset, anim)
        }
        // onPanGesture(_:) 0.24133333333333334
        // ["opacity", "UIPacingAnimationForAnimatorsKey", "backgroundColor"] 0.763347
        // 🙂 1.0 0.0 31002.332901000005 31002.78448145834
        // 👻 0.0 0.12066666666666667 <CABasicAnimation: 0x283a0d180>
        // onPanGesture(_:) 0.24133333333333334
        // ["opacity", "UIPacingAnimationForAnimatorsKey", "backgroundColor"] 0.763347
        // 🙂 1.0 0.0 31002.332901000005 31002.817638041673
        // 👻 0.0 0.12066666666666667 <CABasicAnimation: 0x283a0d180>
        // 显而易见: 副本的 beginTime ~= CACurrentMediaTime()
 
        // <CAAnimationGroup: 0x2822fe400> <CAAnimationGroup: 0x2822fe680>
        // <CAAnimationGroup: 0x2822fe400> <CAAnimationGroup: 0x2822fe680> mainAsyncAfter(second: 0.1)
 */
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

