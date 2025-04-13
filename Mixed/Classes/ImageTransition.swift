//
//  ImageTransition.swift
//  Mixed
//
//  Created by vvii on 2024/7/23.
//

import UIKit

private let DURATION = 0.25

/// 长图预览, 需要提前知道图片的尺寸, 通过修改 contentsRect 来控制显示的部位
class ImagePreviewViewController: UIViewController {
    
    let image = UIImage(named: "image-long")!
    
    lazy var imageView = {
        let imageView = UIImageView(image: image)
        // contentMode 为 scaleAspectFit/scaleAspectFill/scaleToFill 时能与放大后的图片完全重合
        // 1. scaleAspectFit(👍🏻) 视觉效果最佳, 没有变形抖动
        // 2. scaleAspectFill 其次, 动画末端有轻微的放大后再缩小
        // 3. scaleToFill 动画过程中间有变形
        // 其他只能显示一小部分, 不符合要求
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: image.size.width / image.size.height)
        return imageView
    }()
    
    lazy var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapGesture(_:)))
        tapGesture.numberOfTapsRequired = 1
        return tapGesture
    }()
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        imageView.addGestureRecognizer(tapGesture)
        imageView.frame = CGRect(x: 100, y: 300, width: 15 * 9, height: 15 * 9)
        view.addSubview(imageView)
    }
    
    var transitionWindow: UIWindow!
    
    @objc func onTapGesture(_ ges: UITapGestureRecognizer) {
        let imagePreview = ImagePreview(frame: view.bounds)
        view.window?.addSubview(imagePreview)
        imagePreview.show(imageView)
    }
}

class ImagePreview: UIView {
    
    lazy var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapGesture(_:)))
        tapGesture.numberOfTapsRequired = 1
        return tapGesture
    }()
    
    lazy var scrollView = {
        let scrollView = UIScrollView(frame: bounds)
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    let sourceView = UIImageView()
    let targetView = UIImageView()
    weak var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(scrollView)
        scrollView.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(_ imageView: UIImageView) {
        self.imageView = imageView
        let size = imageView.image!.size
        scrollView.contentSize.height = sw * size.height / size.width
        
        sourceView.image = imageView.image
        sourceView.frame = imageView.frame
        sourceView.contentMode = imageView.contentMode
        sourceView.clipsToBounds = true
        sourceView.layer.contentsRect = imageView.layer.contentsRect // 缩小时显示部分
        
        targetView.image = imageView.image
        targetView.frame = CGRect(x: 0, y: 0, width: sw, height: sw * size.height / size.width)
        targetView.contentMode = imageView.contentMode
        targetView.clipsToBounds = true
        targetView.layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: 1) // 显示全部
        
        addSubview(sourceView)
        self.backgroundColor = .black.withAlphaComponent(0.0)
        UIView.animate(withDuration: DURATION) {
            self.backgroundColor = .black.withAlphaComponent(0.8)
            self.sourceView.frame = self.bounds
            let scale = sh / (sw * size.height / size.width)
            self.sourceView.layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: scale) // 放大后显示部分(屏幕)
        } completion: { _ in
            self.sourceView.isHidden = true
            self.scrollView.addSubview(self.targetView)
        }
    }
    
    @objc func onTapGesture(_ ges: UITapGestureRecognizer) {
        self.sourceView.isHidden = false
        self.targetView.isHidden = true
        UIView.animate(withDuration: DURATION) {
            self.sourceView.frame = self.imageView.frame
            self.sourceView.layer.contentsRect = self.imageView.layer.contentsRect
            self.backgroundColor = .black.withAlphaComponent(0.0)
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
    deinit {
        print(#function, self)
    }
}
