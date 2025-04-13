//
//  BezierCurve.swift
//  Mixed
//
//  Created by vvii on 2024/7/30.
//

import UIKit

class BezierCurveViewController: UIViewController {
    
    lazy var start = makeLine(offset: -150)
    lazy var middle = makeLine(offset: 0)
    lazy var end = makeLine(offset: 150)
    
    func makeLine(offset x: Double) -> UIView {
        let line = UIView()
        line.backgroundColor = .black
        line.frame = CGRect(x: 0, y: 0, width: 1, height: sh - 200)
        line.center = CGPoint(x: view.center.x + x, y: view.center.y)
        return line
    }
    
    let views0 = [
        CubicBezierView(curve: .linear, color: .red),
        CubicBezierView(curve: .easeIn, color: .red),
        CubicBezierView(curve: .easeOut, color: .red),
        CubicBezierView(curve: .easeInOut, color: .red),
    ]
    
    let views1 = [
        CubicBezierView(curve: .linear, color: .green),
        CubicBezierView(curve: .easeIn, color: .green),
        CubicBezierView(curve: .easeOut, color: .green),
        CubicBezierView(curve: .easeInOut, color: .green),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(start)
        view.addSubview(middle)
        view.addSubview(end)
        views0.enumerated().forEach { item in
            view.addSubview(item.element)
            item.element.backgroundColor = .black.withAlphaComponent(0.2)
            item.element.frame = CGRect(x: start.frame.minX, y: 100 + 120 * Double(item.offset), width: 40, height: 40)
        }
        views1.enumerated().forEach { item in
            view.addSubview(item.element)
            item.element.backgroundColor = .black.withAlphaComponent(0.2)
            item.element.frame = CGRect(x: start.frame.minX, y: 160 + 120 * Double(item.offset), width: 40, height: 40)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let duration = 2.0 * 1
        views0.forEach { v in
            v.frame.origin.x = self.start.frame.minX
            UIView.animate(withDuration: duration, delay: 0, options: v.curve.animationOptions) {
                v.frame.origin.x = self.end.frame.minX
            } completion: { _ in
                print(#function, "uiview animation completion")
            }
        }
        views1.forEach { v in
            v.frame.origin.x = self.start.frame.minX
            var to = v.frame
            to.origin.x = self.end.frame.minX
            v.animate(from: v.frame, to: to, duration: duration, curve: v.curve, completion: {
                print(#function, "cubic bezier view animation completion")
            })
        }
        
        
        var values: Float = 0
        for i in 0..<4 {
            CAMediaTimingFunction(name: .easeIn).getControlPoint(at: i, values: &values)
            print("easeIn", values) // 0.0 0.42 0.58 1.0
        }
        for i in 0..<4 {
            CAMediaTimingFunction(name: .easeOut).getControlPoint(at: i, values: &values)
            print("easeOut", values)
        }
        for i in 0..<4 {
            CAMediaTimingFunction(name: .easeInEaseOut).getControlPoint(at: i, values: &values)
            print("easeInEaseOut", values)
        }
        for i in 0..<4 {
            CAMediaTimingFunction(name: .linear).getControlPoint(at: i, values: &values)
            print("linear", values)
        }
    }
}


class CubicBezierView: AnimationWrapperView {
    
    let color: UIColor
    
    init(curve: CubicBezierCurve, color: UIColor) {
        self.color = color
        super.init(nil)
        self.curve = curve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        for (index, point) in curve.points(count: 10).enumerated() {
            let x = rect.width * point.x
            let y = rect.height * point.y
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        ctx.translateBy(x: 0, y: rect.height)
        ctx.scaleBy(x: 1, y: -1)
        ctx.addPath(path.cgPath)
        ctx.setLineWidth(2)
        ctx.setStrokeColor(color.cgColor)
        ctx.drawPath(using: .stroke)
    }
}


class AnimationWrapperView: UIView {
    
    var curve: CubicBezierCurve = .linear
    
    var view: UIView?
    
    init(_ view: UIView?) {
        self.view = view
        super.init(frame: .zero)
        if let view = view {
            self.addSubview(view)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        view?.frame = bounds
    }
    
    var displayLink: CADisplayLink!
    var from: CGRect = .zero
    var to: CGRect = .zero
    var duration: Double = 0
    var timestamp: CFTimeInterval!
    var onChange: ((CGRect) -> Void)?
    var completion: (() -> Void)?
    
    @objc func tick() {
        if timestamp == nil {
            timestamp = displayLink.timestamp
        }
        // 时间差 + 延时补偿(实际测试中 1~2 帧最为接近)
        let time = displayLink.timestamp - timestamp + displayLink.duration * 1
        if time < duration {
            let t = min(time / duration, 1.0)
            let p = curve.valueAt(x: t)
            
            let x = from.minX + (to.minX - from.minX) * p
            let y = from.minY + (to.minY - from.minY) * p
            let w = from.width + (to.width - from.width) * p
            let h = from.height + (to.height - from.height) * p
            
            frame = CGRect(x: x, y: y, width: w, height: h)
            view?.frame = bounds
            onChange?(bounds)
        } else {
            displayLink.invalidate()
            displayLink = nil
            timestamp = nil
            frame = to
            view?.frame = bounds
            onChange?(bounds)
            completion?()
            onChange = nil
            completion = nil
        }
    }
    
    // 模拟 UIView 动画曲线, 结果基本一致
    func animate(from: CGRect, to: CGRect, duration: Double, curve: CubicBezierCurve, onChange: ((CGRect) -> Void)? = nil, completion: (() -> Void)? = nil) {
        if duration > 0 {
            // 强制执行第0帧
            frame = from
            view?.frame = bounds
            onChange?(bounds)
            //
            if displayLink == nil {
                displayLink = CADisplayLink(target: self, selector: #selector(tick))
                displayLink.add(to: .main, forMode: .common)
                self.from = from
                self.to = to
                self.duration = duration
                self.curve = curve
                self.onChange = onChange
                self.completion = completion
            }
        } else {
            frame = to
            view?.frame = bounds
            onChange?(bounds)
            completion?()
        }
    }
    
    deinit {
        print(#function, self)
    }
}

/// 通过控制参数 t = 0~1 求出一条时间与位置的曲线
/// 曲线的横坐标代表时间, 纵坐标代表位置. (注意 t 只是控制参数, 不要与时间搞混)
/// 反过来可以求出给定时间所处的位置
struct CubicBezierCurve: CustomStringConvertible {
    /// 起点
    var p0: CGPoint
    /// 控制点1
    var p1: CGPoint
    /// 控制点2
    var p2: CGPoint
    /// 终点
    var p3: CGPoint
    
    static let `default` = CubicBezierCurve.ease // 对应 default
   
    static let linear = CubicBezierCurve(
        p0: CGPoint(x: 0, y: 0),
        p1: CGPoint(x: 0, y: 0),
        p2: CGPoint(x: 1, y: 1),
        p3: CGPoint(x: 1, y: 1)
    )
    
    static let ease = CubicBezierCurve(
        p0: CGPoint(x: 0, y: 0),
        p1: CGPoint(x: 0.25, y: 0.1),
        p2: CGPoint(x: 0.25, y: 1),
        p3: CGPoint(x: 1, y: 1)
    )
    
    static let easeIn = CubicBezierCurve(
        p0: CGPoint(x: 0, y: 0),
        p1: CGPoint(x: 0.42, y: 0),
        p2: CGPoint(x: 1, y: 1),
        p3: CGPoint(x: 1, y: 1)
    )
    
    static let easeOut = CubicBezierCurve(
        p0: CGPoint(x: 0, y: 0),
        p1: CGPoint(x: 0, y: 0),
        p2: CGPoint(x: 0.58, y: 1),
        p3: CGPoint(x: 1, y: 1)
    )
    
    // [CSS 过度中ease与ease-in-out的区别（ease曲线）](https://www.bilibili.com/read/cv11269464/)
    //  var values: Float = 0
    //  for i in 0..<4 {
    //      CAMediaTimingFunction(name: .easeInEaseOut).getControlPoint(at: i, values: &values)
    //      print(values) // 0.0 0.42 0.58 1.0
    //  }
    static let easeInOut = CubicBezierCurve(
        p0: CGPoint(x: 0, y: 0),
        p1: CGPoint(x: 0.42, y: 0),
        p2: CGPoint(x: 0.58, y: 1),
        p3: CGPoint(x: 1, y: 1)
    )
    
    /// 求曲线上的点
    /// - Parameter t: 控制参数 0~1, 不是时间
    /// - Returns: 对应坐标 (时间, 位置)
    func pointAt(t: Double) -> CGPoint {
        let x0 = pow(1-t, 3) * p0.x
        let x1 = 3 * pow(1-t, 2) * pow(t, 1) * p1.x
        let x2 = 3 * pow(1-t, 1) * pow(t, 2) * p2.x
        let x3 = pow(t, 3) * p3.x
        
        let y0 = pow(1-t, 3) * p0.y
        let y1 = 3 * pow(1-t, 2) * pow(t, 1) * p1.y
        let y2 = 3 * pow(1-t, 1) * pow(t, 2) * p2.y
        let y3 = pow(t, 3) * p3.y
        
        return CGPoint(x: x0 + x1 + x2 + x3, y: y0 + y1 + y2 + y3)
    }
    
    /// https://zhuanlan.zhihu.com/p/37057167?utm_source=wechat_session&utm_medium=social&utm_oi=932767012204236800&utm_campaign=shareopn
    /// 求曲线上给定横坐标 (时间) 对应的纵坐标 (位置)
    /// 相当于解三次方程 f(t) = a*t^3 + b*t^2 + c*t^1 + d*t^0
    /// 解析解过于复杂, 因此采用二分或者牛顿迭代法逼近数值解
    /// - Parameter x: 横坐标  (时间)
    /// - Parameter diff: 误差, 小于 1 个像素
    /// - Returns: 纵坐标  (位置)
    func valueAt(x: Double, diff: Double = 0.0001) -> Double {
        var min = 0.0
        var mid = 0.5
        var max = 1.0
        while true {
            let p = pointAt(t: mid)
            if p.x < x {
                min = mid
                mid = (mid + max) / 2
            } else {
                max = mid
                mid = (mid + min) / 2
            }
            if Swift.abs(p.x - x) <= diff {
                return p.y
            }
        }
    }
    
    func points(count: Int) -> [CGPoint] {
        let points = (0..<count).map {
            pointAt(t: Double($0) / Double(count - 1))
        }
        return points
    }
    
    var description: String {
        return "CubicBezierCurve control points: \(p1.x) \(p1.y) \(p2.x) \(p2.y)"
    }
}

extension CubicBezierCurve: Equatable {
    
    var animationOptions: UIView.AnimationOptions {
        if self == .linear { return .curveLinear }
        if self == .easeIn { return .curveEaseIn }
        if self == .easeOut { return .curveEaseOut }
        if self == .easeInOut { return .curveEaseInOut }
        return UIView.AnimationOptions(rawValue: 0)
    }
}
