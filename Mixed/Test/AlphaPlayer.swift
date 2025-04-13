//
//  AlphaPlayer.swift
//  Mixed
//
//  Created by vvii on 2024/7/15.
//

import UIKit
import SnapKit

class AlphaPlayerViewController: UIViewController {
    
    let imageView = AlphaImageView()
    
    let player = AlphaPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.layer.contents = UIImage(named: "image-alpha")?.cgImage
        imageView.image = UIImage(named: "image-alpha") // "image-alpha" "image2"
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.layer.contents = UIImage(named: "image2")?.cgImage
        player.play(imageView: imageView)
    }
}

import AVFoundation

class AlphaPlayer: NSObject, AVPlayerItemOutputPullDelegate {
    
    var displayLink: CADisplayLink!
    var videoOutput: AVPlayerItemVideoOutput!
    weak var imageView: AlphaImageView!
    var playerView: UIView = UIView()
    
    let item = AVPlayerItem(url: Bundle.main.url(forResource: "image-video", withExtension: "mp4")!)
    
    lazy var videoPlayer: AVPlayer = {
        let player = AVPlayer(playerItem: item)
        return player
    }()
    
    lazy var playerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer(player: videoPlayer)
        return playerLayer
    }()
    
    
    func play(imageView: AlphaImageView!) {
        displayLink?.invalidate()
        displayLink = nil
    
        self.imageView = imageView
        self.playerView.layer.addSublayer(playerLayer)
        
        let videoOutputSettings: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32RGBA
        ]
        videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: videoOutputSettings)
        let outputQueue = DispatchQueue(label: "videoOutputQueue")
        videoOutput.setDelegate(self, queue: outputQueue)
        
        item.add(videoOutput)
        
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkCallback))
        displayLink.add(to: .main, forMode: .default)
        
        imageView.addSubview(playerView)
        videoPlayer.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    @objc func displayLinkCallback() {
        guard let pixelBuffer = videoOutput.copyPixelBuffer(forItemTime: item.currentTime(), itemTimeForDisplay: nil) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let image = UIImage(ciImage: ciImage)
        let ctx = CIContext()
        let cgImage = ctx.createCGImage(ciImage, from: CGRect(origin: .zero, size: image.size))!
        imageView.image = UIImage(cgImage: cgImage)
    }
    
    @objc func playerItemDidReachEnd() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
}

// 渲染透明图像
class AlphaImageView: UIView {
    var image: UIImage! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let size = image?.size ?? super.intrinsicContentSize
        return CGSizeMake(size.width / 4, size.height / 2)
    }
    
    override func draw(_ rect: CGRect) {

        guard let image = image.cgImage else {
            return
        }
        
        let context = UIGraphicsGetCurrentContext()!
        
        // 获取 CGImage 对象的像素数据
        let width = image.width
        let height = image.height
        let bytesPerPixel = 4 // RGBA
        let bytesPerRow = width * bytesPerPixel
        let dataProvider = image.dataProvider!
        let data = dataProvider.data!
        let range = CFRange(location: 0, length: bytesPerRow * height)
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bytesPerRow * height)
        defer {
            buffer.deallocate() // 必须释放否则导致严重内存泄漏
        }
        CFDataGetBytes(data, range, buffer)
        
        //
        let outputWidth = width / 2
        
        // 遍历像素数据，获取每个像素的 RGB 值
        var rgbValues = [UInt8]()
        for y in 0..<height {
            for x in 0..<outputWidth {
                let offset0 = y * bytesPerRow + x * bytesPerPixel
                let offset1 = y * bytesPerRow + (x + outputWidth) * bytesPerPixel
                
                let r = buffer[offset1 + 0]
                let g = buffer[offset1 + 1]
                let b = buffer[offset1 + 2]
                let a = buffer[offset0]
                
                rgbValues.append(r)
                rgbValues.append(g)
                rgbValues.append(b)
                rgbValues.append(a)
            }
        }
        
        let dataProvider2 = CGDataProvider(data: CFDataCreate(nil, rgbValues, rgbValues.count))!
        
        let cgImage = CGImage(
            width: outputWidth,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: outputWidth * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue),
            provider: dataProvider2,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        )!
        
        context.clear(rect)
        context.translateBy(x: 0, y: rect.size.height)
        context.scaleBy(x: 1, y: -1)
        context.draw(cgImage, in: rect, byTiling: false)
    }
}
