//
//  LiquidSwipeView.swift
//  LiquidSwipeSwiftUI
//
//  Created by Mark Goldin on 12/08/2019.
//  Copyright © 2019 Exyte. All rights reserved.
//

import SwiftUI

enum WaveSide {
    case left
    case right
}

struct WaveView: Shape {

    internal var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(dx, y) }
        set {
            dx = newValue.first
            y = newValue.second
        }
    }

    private let side: WaveSide
    private var dx: CGFloat
    private var y: CGFloat

    init(data: WaveData) {
        self.side = data.side
        self.dx = data.draggingPoint.x
        self.y = data.draggingPoint.y
    }

    func path(in rect: CGRect) -> Path {
        return build(cy: y, progress: dx)
    }
    
    private func build(cy: CGFloat, progress: CGFloat) -> Path {
        let side = WaveView.adjust(from: 15, to: WaveView.bounds.width, p: progress, min: 0.2, max: 0.8)
        let hr = WaveView.getHr(from: 48, to: WaveView.bounds.width * 0.8, p: progress)
        let vr = WaveView.adjust(from: 82, to: WaveView.bounds.height * 0.9, p: progress, max: 0.4)
        let opacity = max(1 - progress * 5, 0)
        return build(cy: cy, hr: hr, vr: vr, side: side, opacity: opacity)
    }

    static func adjustedDragPoint(point: CGPoint, alignment: WaveSide) -> (CGPoint, Double) {
        var dx = alignment == .left ? point.x : -point.x
        let progress = WaveView.getProgress(dx: dx)
        let side = WaveView.adjust(from: 15, to: bounds.width, p: progress, min: 0.2, max: 0.8)
        let hr = WaveView.getHr(from: 48, to: bounds.width * 0.8, p: progress)
        //  let vr = WaveView.adjust(from: 82, to: sizeH * 0.9, p: progress, max: 0.4)
        let opacity = max(1 - progress * 5, 0)
        
        let xSide = alignment == .left ? side : bounds.width - side
        let sign: CGFloat = alignment == .left ? 1.0 : -1.0
        
        dx = xSide + sign * hr
        let dx2 = alignment == .left ? -SwipeButton.radius - 8 : SwipeButton.radius + 8
        
        return (CGPoint(x: dx + dx2, y: point.y), Double(opacity))
    }

    private func build(cy: CGFloat, hr: CGFloat, vr: CGFloat, side: CGFloat, opacity: CGFloat) -> Path {
        let isLeft = self.side == .left
        let xSide = isLeft ? side : WaveView.bounds.width - side
        let curveStartY = vr + cy
        let sign: CGFloat = isLeft ? 1.0 : -1.0

        var path = Path()
        let x = isLeft ? -50 : WaveView.bounds.width + 50
        path.move(to: CGPoint(x: xSide, y: -100))
        path.addLine(to: CGPoint(x: x, y: -100))
        path.addLine(to: CGPoint(x: x, y: WaveView.bounds.height))
        path.addLine(to: CGPoint(x: xSide, y: WaveView.bounds.height))
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

    static var bounds: CGRect {
        return UIScreen.main.bounds
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

struct WaveData {

    let side: WaveSide
    let draggingPoint: CGPoint
    let buttonCenter: CGPoint
    let buttonOpacity: Double

    init(side: WaveSide, point: CGPoint, center: CGPoint, opacity: Double) {
        self.side = side
        self.draggingPoint = point
        self.buttonCenter = center
        self.buttonOpacity = opacity
    }

    init(side: WaveSide) {
        let x = SwipeButton.radius + 4
        let y: CGFloat = side == .left ? 100 : 300
        self.side = side
        self.draggingPoint = CGPoint(x: 0.01, y: y)
        self.buttonCenter = CGPoint(x: side == .left ? x : WaveView.bounds.width - x, y: y)
        self.buttonOpacity = 1
    }

    func tapEnd() -> WaveData {
        return WaveData(side: side, point: CGPoint(x: 1, y: 0), center: buttonCenter, opacity: 0)
    }

    func dragChange(location: CGPoint, translation: CGSize) -> WaveData {
        let point = self.calculatePoint(location: location, translation: translation, alignment: side, isDragging: true)
        let data = WaveView.adjustedDragPoint(point: CGPoint(x: translation.width, y: location.y), alignment: side)
        return WaveData(side: side, point: point, center: data.0, opacity: data.1)
    }

    func dragEnd(location: CGPoint, translation: CGSize) -> WaveData {
        let point = self.calculatePoint(location: location, translation: translation, alignment: side, isDragging: false)
        return WaveData(side: side, point: point, center: buttonCenter, opacity: 0)
    }

    func calculatePoint(location: CGPoint, translation: CGSize, alignment: WaveSide, isDragging: Bool) -> CGPoint {
        let dx = alignment == .left ? translation.width : -translation.width
        var progress = WaveView.getProgress(dx: dx)
        
        if !isDragging {
            let success = progress > 0.15
            progress = WaveView.adjust(from: progress, to: success ? 1 : 0, p: 1.0)
        }
        
        return CGPoint(x: progress, y: location.y)
    }

    func reload() -> WaveData {
        let pad: CGFloat = 16.0
        let x = SwipeButton.radius + 4
        let y: CGFloat = side == .left ? 100 : 300
        let point = calculatePoint(location: CGPoint(x: 0, y: y), translation: CGSize(width: pad, height: 0), alignment: .left, isDragging: false)
        let center = CGPoint(x: side == .left ? x : WaveView.bounds.width - x, y: y)
        return WaveData(side: side, point: point, center: center, opacity: buttonOpacity)
    }

    func show() -> WaveData {
        return WaveData(side: side, point: draggingPoint, center: buttonCenter, opacity: 1)
    }

    func back() -> WaveData {
        let x = SwipeButton.radius + 4
        let center = CGPoint(x: side == .left ? x : WaveView.bounds.width - x, y: draggingPoint.y)
        return WaveData(side: side, point: draggingPoint, center: center, opacity: 1)
    }

}

struct SwipeButton {

    static let radius: CGFloat = 24.0

}



