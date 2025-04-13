//
//  BlurViewController.swift
//  Mixed
//
//  Created by vvii on 2024/7/11.
//

import UIKit
import SnapKit
import AVFoundation

class BlurViewController: UIViewController {
    
    lazy var videoPlayer: AVPlayer = {
        let item = AVPlayerItem(url: Bundle.main.url(forResource: "video", withExtension: "mp4")!)
        let player = AVPlayer(playerItem: item)
        return player
    }()
    
    lazy var playerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer(player: videoPlayer)
        return playerLayer
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
//        imageView.image = UIImage(named: "image")
        return imageView
    }()
    
    lazy var slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0.05
        slider.maximumValue = 1.0
        slider.addTarget(self, action: #selector(onValueChanged(_:)), for: .valueChanged)
        return slider
    }()
    
    lazy var blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView.init(effect: effect)
        return blurView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(720 / 2)
            make.height.equalTo(960 / 2)
        }
        
        imageView.layer.addSublayer(playerLayer)
        imageView.addSubview(blurView)
        
        view.addSubview(slider)
        slider.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.width.equalTo(imageView)
        }
        
        videoPlayer.play()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = playerLayer.superlayer?.bounds ?? .zero
    }
    
    @objc func onValueChanged(_ slider: UISlider) {
        let scale = CGFloat(slider.value)
        if false {
            // UIKit 画面可能会抖
            blurView.frame = CGRect(x: 0, y: 100, width: 200, height: 200)
            blurView.transform = CGAffineTransform(scaleX: scale, y: scale)
        } else {
            // SwiftUI 画面稳定
            imageView.subviews.forEach({ $0.removeFromSuperview() })
            let hostView = UIHostingController(rootView: BlurEffectView(scale: scale)).view!
            hostView.backgroundColor = .clear
            imageView.addSubview(hostView)
            hostView.snp.remakeConstraints { make in
                make.top.equalTo(imageView.snp.centerY)
                make.left.right.bottom.equalToSuperview()
            }
        }
        
        if scale == 1 {
            videoPlayer.currentItem?.seek(to: CMTime.init(seconds: 5, preferredTimescale: 1), completionHandler: { _ in
                self.videoPlayer.play()
            })
        }
    }
}


import SwiftUI

struct BlurEffectView: UIViewRepresentable {
    var scale: CGFloat = 1.0
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let effect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: effect)
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        let view = uiView
        view.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
}

extension BlurEffectView {
    func scale(_ scale: CGFloat) -> Self {
        var copy = self
        copy.scale = scale
        return copy
    }
}


// -- ---
import UIKit
import AVFoundation

class TestViewController: UIViewController {

    var displayLink: CADisplayLink!
    var videoOutput: AVPlayerItemVideoOutput!
    var context: CIContext!
    var blurFilter: CIFilter!
    var clampFilter: CIFilter!
    var videoContainerView: UIView!
    var playView: PlayerView!
    lazy var imageView = UIImageView(frame: videoContainerView.bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playView = PlayerView(frame: view.bounds)
        videoContainerView = UIView(frame: view.bounds)
        view.addSubview(playView)
        
        let videoURL = URL(string: "https://sunny-sd.oss-cn-shenzhen.aliyuncs.com/output_image/319473/qc_319473_731142_22/9d252382b136c521a8f549f30dec885a.mp4")!
        playView.player.play()
        
        setBlurFilter()
    }
    

}
extension TestViewController {
    func setBlurFilter() {
        context = CIContext()
        blurFilter = CIFilter(name: "CIGaussianBlur")
        clampFilter = CIFilter(name: "CIAffineClamp")
        startVideoProcessing()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: playView.playerAsset.player.currentItem)
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        playView.playerAsset.player.seek(to: .zero)
        playView.playerAsset.player.play()
    }
    
    func startVideoProcessing() {
//        guard let asset = playView.playerAsset.asset else { return }
        
        let videoOutputSettings: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: videoOutputSettings)
        let outputQueue = DispatchQueue(label: "videoOutputQueue")
        videoOutput.setDelegate(self, queue: outputQueue)
        
        playView.item.add(videoOutput)
//        playView.playerAsset.player.replaceCurrentItem(with: playerItem)
        
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkCallback))
        displayLink.add(to: .main, forMode: .default)
    }
    
    @objc func displayLinkCallback() {
        guard let pixelBuffer = videoOutput.copyPixelBuffer(forItemTime: playView.playerAsset.player.currentTime(), itemTimeForDisplay: nil) else { return }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        clampFilter.setDefaults()
        clampFilter.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let image = clampFilter.outputImage else {
            print(clampFilter, 1)
            return
        }
        print(image)
//
        blurFilter.setValue(image, forKey: kCIInputImageKey)
        blurFilter.setValue(100, forKey: kCIInputRadiusKey)
        
        guard let blurredImage = blurFilter.outputImage else { return }
        
        let blurredCGImage = context.createCGImage(blurredImage, from: ciImage.extent)
        let blurredUIImage = UIImage(cgImage: blurredCGImage!)
        
        
        imageView.image = blurredUIImage
        imageView.contentMode = .scaleAspectFill
        playView.addSubview(imageView)
        
//        playView.image = blurredUIImage
    }
}

extension TestViewController: AVPlayerItemOutputPullDelegate {
    func outputMediaDataWillChange(_ sender: AVPlayerItemOutput) {
        // 处理输出数据变化
    }
}


class PlayerView: UIView {
    lazy var videoPlayer: AVPlayer = {
        let player = AVPlayer(playerItem: item)
        return player
    }()
    
    lazy var item: AVPlayerItem = {
//        let item = AVPlayerItem(url: Bundle.main.url(forResource: "video", withExtension: "mp4")!)
        let videoURL = URL(string: "https://sunny-sd.oss-cn-shenzhen.aliyuncs.com/output_image/319473/qc_319473_731142_22/9d252382b136c521a8f549f30dec885a.mp4")!
        let item = AVPlayerItem(url: videoURL)
        return item
    }()
    
    lazy var playerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer(player: videoPlayer)
        return playerLayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(playerLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var player: AVPlayer {
        return videoPlayer
    }
    
    var playerAsset: PlayerView {
        return self
    }
}
