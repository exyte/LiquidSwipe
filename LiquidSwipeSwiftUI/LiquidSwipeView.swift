//
//  LiquidSwipeView.swift
//  LiquidSwipeSwiftUI
//
//  Created by Mark Goldin on 12/08/2019.
//  Copyright © 2019 Exyte. All rights reserved.
//

import SwiftUI

enum WaveAlignment {
    case left
    case right
}

struct DragPointData: Equatable {
    var point: CGPoint
    var translation: CGSize
}

struct WaveView: Shape {
    
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(draggingPoint.x, draggingPoint.y) }
        set {
            draggingPoint.x = newValue.first
            draggingPoint.y = newValue.second
        }
    }
    
    var draggingPoint: CGPoint
    let alignment: WaveAlignment
    
    init(draggingPoint: CGPoint, alignment: WaveAlignment) {
        self.draggingPoint = draggingPoint
        self.alignment = alignment
    }
    
    func path(in rect: CGRect) -> Path {
        return build(cy: draggingPoint.y, progress: draggingPoint.x)
    }
    
    private func build(cy: CGFloat, progress: CGFloat) -> Path {
        let side = WaveView.adjust(from: 15, to: sizeW, p: progress, min: 0.2, max: 0.8)
        let hr = WaveView.getHr(from: 48, to: sizeW * 0.8, p: progress)
        let vr = WaveView.adjust(from: 82, to: sizeH * 0.9, p: progress, max: 0.4)
        let opacity = max(1 - progress * 5, 0)
        return build(cy: cy, hr: hr, vr: vr, side: side, opacity: opacity)
    }
    
    private func build(cy: CGFloat, hr: CGFloat, vr: CGFloat, side: CGFloat, opacity: CGFloat) -> Path {
        let xSide = alignment == .left ? side : sizeW - side
        let curveStartY = vr + cy
        let sign: CGFloat = alignment == .left ? 1.0 : -1.0
        
        var path = Path()
        path.move(to: CGPoint(x: xSide, y: -100))
        path.addLine(to: CGPoint(x: alignment == .left ? 0 : sizeW, y: -100))
        path.addLine(to: CGPoint(x: alignment == .left ? 0 : sizeW, y: sizeH))
        path.addLine(to: CGPoint(x: xSide, y: sizeH))
        path.addLine(to: CGPoint(x: xSide, y: curveStartY))
    
        var index = 0
        while index < WaveView.data.count {
            let x1 = xSide + sign * hr * WaveView.data[index]
            let y1 = curveStartY - vr * WaveView.data[index + 1]
            let x2 = xSide + sign * hr * WaveView.data[index + 2]
            let y2 = curveStartY - vr * WaveView.data[index + 3]
            let x = xSide + sign * hr * WaveView.data[index + 4]
            let y = curveStartY - vr * WaveView.data[index + 5]

            let point = CGPoint(x: x, y: y)
            let control1 = CGPoint(x: x1, y: y1)
            let control2 = CGPoint(x: x2, y: y2)

            path.addCurve(to: point, control1: control1, control2: control2)

            index += 6
        }
     
        return path
    }
    
    static func getProgress(dx: CGFloat) -> CGFloat {
        return min(1.0, max(0, dx * 0.45 / UIScreen.main.bounds.size.width))
    }
    
    static func getHr(from: CGFloat, to: CGFloat, p: CGFloat) -> CGFloat {
        let p1: CGFloat = 0.4
        if p <= p1 {
            return adjust(from: from, to: to, p: p, max: p1)
        } else if p >= 1 {
            return to
        }
        let t = (p - p1) / (1 - p1)
        let m: CGFloat = 9.8
        let beta: CGFloat = 40.0 / (2 * m)
        let omega = pow(-pow(beta, 2) + pow(50.0 / m, 2), 0.5)
        return to * exp(-beta * t) * cos(omega * t)
    }
    
    static func adjust(from: CGFloat, to: CGFloat, p: CGFloat, min: CGFloat = 0, max: CGFloat = 1) -> CGFloat {
        if p <= min {
            return from
        } else if p >= max {
            return to
        }
        return from + (to - from) * (p - min) / (max - min)
    }
    
    static func adjustedDragPoint(point: CGPoint, alignment: WaveAlignment) -> (CGPoint, Double) {
        var dx = alignment == .left ? point.x : -point.x
        let progress = WaveView.getProgress(dx: dx)
        
        //        if !isDragging {
        //            let success = progress > 0.15
        //            progress = WaveView.self.adjust(from: progress, to: success ? 1 : 0, p: 1.0)
        //        }
        
        let side = WaveView.adjust(from: 15, to: sizeW, p: progress, min: 0.2, max: 0.8)
        let hr = WaveView.getHr(from: 48, to: sizeW * 0.8, p: progress)
      //  let vr = WaveView.adjust(from: 82, to: sizeH * 0.9, p: progress, max: 0.4)
        let opacity = max(1 - progress * 5, 0)
        
        let xSide = alignment == .left ? side : sizeW - side
        let sign: CGFloat = alignment == .left ? 1.0 : -1.0
        
        dx = xSide + sign * hr
        let dx2 = alignment == .left ? -circleRadius - 8 : circleRadius + 8
        
        return (CGPoint(x: dx + dx2, y: point.y), Double(opacity))
    }
    
    private static let data: [CGFloat] = [
        0, 0.13461, 0.05341, 0.24127, 0.15615, 0.33223,
        0.23616, 0.40308, 0.33052, 0.45611, 0.50124, 0.53505,
        0.51587, 0.54182, 0.56641, 0.56503, 0.57493, 0.56896,
        0.72837, 0.63973, 0.80866, 0.68334, 0.87740, 0.73990,
        0.96534, 0.81226,       1, 0.89361,       1,       1,
        1, 1.10014, 0.95957, 1.18879, 0.86084, 1.27048,
        0.78521, 1.33305, 0.70338, 1.37958, 0.52911, 1.46651,
        0.52418, 1.46896, 0.50573, 1.47816, 0.50153, 1.48026,
        0.31874, 1.57142, 0.23320, 1.62041, 0.15411, 1.68740,
        0.05099, 1.77475,       0, 1.87092,       0,       2]
}
