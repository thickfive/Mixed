//
//  ClockViewController.swift
//  Mixed
//
//  Created by vvii on 2024/3/7.
//

import UIKit

// Objective-C 里面角度计算要注意整形与浮点型, 整数后面最好加上 .0 避免当做整数计算
class ClockViewController: UIViewController {
    
    var imageView1: UIImageView!
    var imageView2: UIImageView!
    
    var indexLabel: UILabel!
    
    var d0: CGFloat!
    var d1: CGFloat!
    
    var timer: Timer!
    var index: Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        
        imageView1 = UIImageView(image: UIImage(named: "biaopan2"))
        imageView1.sizeToFit()
        imageView1.center = view.center
        view.addSubview(imageView1)
        
        imageView2 = UIImageView(image: UIImage(named: "zhizhen2"))
        imageView2.sizeToFit()
        imageView2.layer.anchorPoint = CGPointMake(1, 0)
        imageView2.layer.position = CGPointMake(263 * 0.5, 263 * 0.5)
        imageView1.addSubview(imageView2)
        
        indexLabel = UILabel()
        indexLabel.textColor = .green
        indexLabel.font = .systemFont(ofSize: 40)
        indexLabel.center.x = imageView1.center.x
        indexLabel.center.y = imageView1.frame.maxY
        view.addSubview(indexLabel)
        
        d1 = -270 / 100 * 100 / 360 * 2 * Double.pi // 0
        d0 = 0 // 100
        self.imageView2.transform = CGAffineTransform(rotationAngle: self.d0)
        
        timer = Timer(timeInterval: 0.16, repeats: true, block: { _ in
            let i = self.index // Int(self.index) % 2 == 0 ? 0.0 : 100.0 //
            self.d1 = 270 / 100 * i / 360 * 2 * Double.pi
            self.imageView2.transform = CGAffineTransform(rotationAngle: self.d1)
            print(#function, self.d1!)
            
            self.indexLabel.text = "\(self.index)"
            self.indexLabel.sizeToFit()
            
            
            self.index += 1
            if self.index > 100 {
                self.index = 0
            }
        })
        
        RunLoop.main.add(timer, forMode: .common)
        
        timer.fire()
    }
    
    func viewDidLoad2() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        
        imageView1 = UIImageView(image: UIImage(named: "biaopan"))
        imageView1.sizeToFit()
        imageView1.center = view.center
        view.addSubview(imageView1)
        
        imageView2 = UIImageView(image: UIImage(named: "zhizhen"))
        imageView2.sizeToFit()
        imageView2.layer.anchorPoint = CGPointMake(0.12, 0.12)
        imageView2.layer.position = view.center
        view.addSubview(imageView2)
        
        indexLabel = UILabel()
        indexLabel.textColor = .green
        indexLabel.font = .systemFont(ofSize: 40)
        indexLabel.center.x = imageView1.center.x
        indexLabel.center.y = imageView1.frame.maxY
        view.addSubview(indexLabel)
        
        d0 = -90 / 33 * 100 / 360 * 2 * Double.pi // 0
        d1 = 0 // 100
        self.imageView2.transform = CGAffineTransform(rotationAngle: self.d0)
        
        timer = Timer(timeInterval: 0.16, repeats: true, block: { _ in
            let i = 100 - self.index
            self.d1 = -90 / 33 * i / 360 * 2 * Double.pi
            self.imageView2.transform = CGAffineTransform(rotationAngle: self.d1)
            print(#function, self.d1!)
            
            self.indexLabel.text = "\(self.index)"
            self.indexLabel.sizeToFit()
            
            self.index += 1
            if self.index > 100 {
                self.index = 0
            }
        })
        
        RunLoop.main.add(timer, forMode: .common)
        
        timer.fire()
    }
}
