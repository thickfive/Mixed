//
//  Color+Ex.swift
//  Mixed
//
//  Created by vvii on 2024/7/18.
//

import SwiftUI

struct ColorComponents {
    let color: UIColor
    let r: CGFloat /// red
    let g: CGFloat /// green
    let b: CGFloat /// blue
    let a: CGFloat /// alpha
    let h: CGFloat /// hue
    let s: CGFloat /// saturation
    let v: CGFloat /// brightness, hsv == hsb
    let w: CGFloat /// white
    
    init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        self.init(UIColor(red: r, green: g, blue: b, alpha: a))
    }
    
    init(h: CGFloat, s: CGFloat, v: CGFloat, a: CGFloat) {
        self.init(UIColor(hue: h, saturation: s, brightness: v, alpha: a))
    }
    
    init(_ color: Color) {
        self.init(UIColor(color))
    }
    
    init(_ color: UIColor) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        var h: CGFloat = 0
        var s: CGFloat = 0
        var v: CGFloat = 0
        var w: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        color.getHue(&h, saturation: &s, brightness: &v, alpha: &a)
        color.getWhite(&w, alpha: &a)
        
        self.color = color
        self.r = r
        self.g = g
        self.b = b
        self.a = a
        self.h = h
        self.s = s
        self.v = v
        self.w = w
    }
}

public extension UIColor {
    convenience init?(hexString: String) {
        self.init(Int(hexString) ?? 0)
    }
    
    convenience init(_ hex: Int) {
        let r: Double = Double(hex & 0xFF0000 >> 4) / 255.0
        let g: Double = Double(hex & 0x00FF00 >> 2) / 255.0
        let b: Double = Double(hex & 0x0000FF >> 0) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    static var random: UIColor {
        let r: Double = Double(Int.random(in: 0..<256)) / 255.0
        let g: Double = Double(Int.random(in: 0..<256)) / 255.0
        let b: Double = Double(Int.random(in: 0..<256)) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}

