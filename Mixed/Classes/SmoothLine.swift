//
//  SmoothLine.swift
//  Mixed
//
//  Created by vvii on 2024/8/9.
//

import UIKit
import SwiftCubicSpline

class SmoothLineViewController: UIViewController {
    
    lazy var lineView = SmoothLineView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(lineView)
        lineView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        lineView.center = view.center
        lineView.backgroundColor = .lightGray
    }
}


class SmoothLineView: UIView {
    
    // [0, 1]
    let points0: [CGPoint] = [
        CGPoint(x: 0.05, y: 0.05),
        CGPoint(x: 0.25, y: 0.75),
        CGPoint(x: 0.5, y: 0.5),
        CGPoint(x: 0.75, y: 0.25),
        CGPoint(x: 0.95, y: 0.95),
    ]
    
    lazy var points: [CGPoint] = {
        return (0..<10).map { _ in
            let x = Double.random(in: 0..<1)
            let y = Double.random(in: 0..<1)
            return CGPoint(x: x, y: y)
        }.sorted {
            $0.x < $1.x
        }
    }()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        ctx.translateBy(x: 0, y: rect.height)
        ctx.scaleBy(x: 1, y: -1)
        drawCubicSplineCurve(ctx, rect)
        drawCubicBezierCurve(ctx, rect)
        drawPoints(ctx, rect)
    }
    
    func drawCubicSplineCurve(_ ctx: CGContext, _ rect: CGRect) {
        // CubicSpline
        let spline = CubicSpline(points: points.map({ Point(x: $0.x, y: $0.y) }))
        var points: [CGPoint] = []
        for i in 0..<200 {
            let x = Double(i) / 200.0
            let y = spline[x: x]
            points.append(CGPoint(x: x * rect.width, y: y * rect.height))
        }
        
        let path = UIBezierPath()
        for (index, point) in points.enumerated() {
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        ctx.addPath(path.cgPath)
        ctx.setLineWidth(1)
        ctx.setStrokeColor(UIColor.systemGreen.cgColor)
        ctx.drawPath(using: .stroke)
    }
    
    func drawCubicBezierCurve(_ ctx: CGContext, _ rect: CGRect) {
        // BezierPath
        let points = points.map({ CGPoint(x: $0.x * rect.width, y: $0.y * rect.height) })
        let path = UIBezierPath()
     
        for (i, point) in points.enumerated() {
            // 斜率 k = (y2 - y0) / (x2 - x0) = (cpy - y1) / (cpx - x1)
            // 1> cpx = x1 + dx
            // 2> cpy = y1 + dy = y1 + (y2 - y0) / (x2 - x0) * dx
            // 令 dx = (x2 - x0) * x, x 为一个系数, 那么 cpx, cpy 简化为
            // 1> cpx = x1 + (x2 - x0) * x
            // 2> cpy = y1 + (y2 - y0) * x
            // 两个控制点可以用同样的公式计算, 只不过参考点不同, x 越小越接近直线, x 越大越平滑但是会交叉
            let ppreX = (i <= 1) ? point.x : points[i - 2].x
            let ppreY = (i <= 1) ? point.y : points[i - 2].y
            let prevX = (i == 0) ? point.x : points[i - 1].x
            let prevY = (i == 0) ? point.y : points[i - 1].y
            let currX = point.x
            let currY = point.y
            let nextX = (i == points.count - 1) ? point.x : points[i + 1].x
            let nextY = (i == points.count - 1) ? point.y : points[i + 1].y
            
            let cpx0 = prevX + (currX - ppreX) * 0.1
            let cpy0 = prevY + (currY - ppreY) * 0.1
            let cpx1 = currX - (nextX - prevX) * 0.1
            let cpy1 = currY - (nextY - prevY) * 0.1
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addCurve(to: point, controlPoint1: CGPoint(x: cpx0, y: cpy0), controlPoint2: CGPoint(x: cpx1, y: cpy1))
            }
        }
        
        ctx.addPath(path.cgPath)
        ctx.setLineWidth(1)
        ctx.setStrokeColor(UIColor.systemRed.cgColor)
        ctx.drawPath(using: .stroke)
    }
    
    func drawPoints(_ ctx: CGContext, _ rect: CGRect) {
        let points = points.map({ CGPoint(x: $0.x * rect.width, y: $0.y * rect.height) })
        let path = UIBezierPath()
        
        for point in points {
            path.move(to: point)
            path.addArc(withCenter: point, radius: 2, startAngle: -Double.pi, endAngle: Double.pi, clockwise: true)
        }
        
        ctx.addPath(path.cgPath)
        ctx.setLineWidth(1)
        ctx.setStrokeColor(UIColor.systemBlue.cgColor)
        ctx.drawPath(using: .stroke)
    }
}
