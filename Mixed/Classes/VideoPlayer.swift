//
//  VideoPlayer.swift
//  Mixed
//
//  Created by vvii on 2024/8/2.
//

import UIKit
import AVFoundation
import KTVHTTPCache
import AVKit

/* AVPlayerLayer 动画
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
 */
class VideoPlayer: NSObject {
    
    class PlayerView: UIView {
        override class var layerClass: AnyClass {
            return AVPlayerLayer.self
        }
    }
    
    static let shared = VideoPlayer()
    
    override init() {
        super.init()
        do {
            // KTVHTTPCache.logSetConsoleLogEnable(true)
            try KTVHTTPCache.proxyStart()
        } catch {
            print("KTVHTTPCache \(error)")
        }
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    let url0 = Bundle.main.url(forResource: "video-no-faststart", withExtension: "mp4")!
    let url1 = URL(string: "https://transfer-ali-oss.oss-cn-shenzhen.aliyuncs.com/2024/video-no-faststart.mp4")!
    let url2 = URL(string: "https://transfer-ali-oss.oss-cn-shenzhen.aliyuncs.com/2024/video-faststart.mp4")!
    let url3 = URL(string: "http://192.168.0.101:8088/video/video-faststart.mp4")!
    
    // 除了用 KTVHTTPCache 本地服务器代理, 可以简单利用 AVAssetResourceLoaderDelegate 实现边下边播
    lazy var playerItem = {
        let playerItem = AVPlayerItem(url:  KTVHTTPCache.proxyURL(withOriginalURL: self.url2))
        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: [.new], context: nil)
        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.seekableTimeRanges), options: [.new], context: nil)
        return playerItem
    }()
    
    lazy var player: AVPlayer = {
        let player = AVPlayer(playerItem: playerItem)
        return player
    }()
    
    lazy var playerView: PlayerView = {
        let playerView = PlayerView()
        let layer = playerView.layer as! AVPlayerLayer
        layer.player = player
        return playerView
    }()
    
    lazy var pictureInPictureController: AVPictureInPictureController? = {
        let pictureInPictureController = AVPictureInPictureController(playerLayer: self.playerLayer)
        return pictureInPictureController
    }()
    
    // 在需要修改视频大小的地方, 最好用 transfrom 和 anchorpoint 来做, 因为 UIView 动画对它不管用
    lazy var playerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer(player: player)
        // playerLayer.contentsGravity = .resizeAspectFill
        playerLayer.videoGravity = .resizeAspectFill // 这个有效 resizeAspect 为默认效果, 相当于 UIContentModeAspectFit
        return playerLayer
    }()
    
    func startPictureInPicture() {
        // [iPhone上使用画中画（PictureInPicture of iOS14）](https://www.jianshu.com/p/2aec0f454e02)
        if AVPictureInPictureController.isPictureInPictureSupported() {  // 模拟器不支持?
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
                try AVAudioSession.sharedInstance().setActive(true, options: [])
            } catch {
                // 必须设置 AVAudioSession, 否则无效
            }
            pictureInPictureController?.canStartPictureInPictureAutomaticallyFromInline = true
            mainAsyncAfter(second: 0.1) {
                self.pictureInPictureController?.startPictureInPicture()
            }
        } else {
            print("AVPictureInPictureController.isPictureInPictureSupported() == false")
        }
    }
    
    func stopPictureInPicture() {
        if pictureInPictureController?.isPictureInPictureActive == true {
            pictureInPictureController?.stopPictureInPicture()
        }
    }
    
    func play(in view: UIView, animation: Bool = false) {
        player.isMuted = true
        player.play()
        view.layer.insertSublayer(playerLayer, at: 0)
        updatePlayerLayer(frame: view.bounds, animation: animation)
    }
    
    func updatePlayerLayer(frame: CGRect, animation: Bool = false) {
        // 关闭 CALayer 隐式动画
        CATransaction.begin()
        CATransaction.setDisableActions(!animation)
        playerLayer.frame = frame
        CATransaction.commit()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        NSLog("\(keyPath!) \(change![.newKey]!)")
    }
    
    @objc func playerItemDidReachEnd() {
        playerItem.seek(to: CMTime(value: 0, timescale: 1), completionHandler: nil)
        player.play()
    }
    
    func seek(to time: Int64) {
        player.seek(to: CMTime(value: time, timescale: 1), toleranceBefore: CMTime(value: 0, timescale: 1), toleranceAfter: CMTime(value: 0, timescale: 1)) { success in
            print("seek to time: \(time), success: \(success)")
        }
    }
    
    func clearCache() {
        KTVHTTPCache.cacheDeleteAllCaches()
    }
    
    deinit {
        removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges))
        removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.seekableTimeRanges))
    }
}

