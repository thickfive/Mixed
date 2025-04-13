//
//  FullScreen.swift
//  Mixed
//
//  Created by vvii on 2024/9/11.
//

import UIKit

class FullScreenViewController: UIViewController, AutorotateProtocol {
    
    lazy var videoView: UIView = {
        let videoView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.width * 9 / 16))
        videoView.backgroundColor = .clear
        return videoView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(videoView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        VideoPlayer.shared.play(in: videoView)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let isPortrait = view.bounds.width < view.bounds.height // 平放时 UIDeviceOrientation == isFlat
        let screenW = isPortrait ? view.bounds.width : view.bounds.height
        let screenH = isPortrait ? view.bounds.height : view.bounds.width
        let from = self.videoView.bounds
        let to = isPortrait ? CGRect(x: 0, y: 0, width: screenH, height: screenW) : CGRect(x: 0, y: 0, width: screenW, height: screenW * 9 / 16)

        let isCustomAnimation = UIDevice.current.orientation.isFlat
        if isCustomAnimation {
            AnimationWrapperView(videoView).animate(from: from, to: to, duration: coordinator.transitionDuration, curve: .easeInOut) { rect in
                VideoPlayer.shared.updatePlayerLayer(frame: rect)
                print(#function, rect)
            }
        } else {
            let anim1 = CABasicAnimation(keyPath: "bounds")
            anim1.fromValue = NSValue(cgRect: from)
            anim1.toValue = NSValue(cgRect: to)
            
            let anim2 = CABasicAnimation(keyPath: "position")
            anim2.fromValue = NSValue(cgPoint: CGPoint(x: from.width / 2, y: from.height / 2))
            anim2.toValue = NSValue(cgPoint: CGPoint(x: to.width / 2, y: to.height / 2))
            
            let groupAnim = CAAnimationGroup()
            groupAnim.animations = [anim1, anim2]
            groupAnim.duration = coordinator.transitionDuration
            groupAnim.fillMode = .forwards
            groupAnim.isRemovedOnCompletion = false
            groupAnim.timingFunction = .easeInOut
            
            coordinator.animate { ctx in
                self.videoView.frame = to
                VideoPlayer.shared.playerLayer.add(groupAnim, forKey: "groupAnim")
                VideoPlayer.shared.playerLayer.frame = to
            } completion: { ctx in
                
            }
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.landscapeRight, .portrait]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        toggleOrientation()
    }
    
    func toggleOrientation() {
        if #available(iOS 16.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                let orientation: UIInterfaceOrientationMask = windowScene.interfaceOrientation.isPortrait ? .landscapeRight : .portrait
                let preferences = UIWindowScene.GeometryPreferences.iOS.init(interfaceOrientations: orientation)
                windowScene.requestGeometryUpdate(preferences) { error in
                    print(#function, error)
                }
            }
        } else {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                let orientation: UIDeviceOrientation = windowScene.interfaceOrientation.isPortrait ? .landscapeRight : .portrait
                UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
                UIViewController.attemptRotationToDeviceOrientation()
            }
        }
    }
}
