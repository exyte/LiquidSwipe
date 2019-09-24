//
//  LiquidSwipeView.swift
//  LiquidSwipeSwiftUI
//
//  Created by Mark Goldin on 12/08/2019.
//  Copyright © 2019 Exyte. All rights reserved.
//

import SwiftUI

struct WaveView: Shape {

    private let side: SliderSide
    private var centerY: Double
    private var progress: Double

    init(data: SliderData) {
        self.side = data.side
        self.centerY = data.centerY
        self.progress = data.progress
    }

    internal var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(centerY, progress) }
        set {
            centerY = newValue.first
            progress = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let data = SliderData(side: side, centerY: centerY, progress: progress)
        let waveLedge = data.waveLedgeX
        let hr = data.waveHorizontalRadius
        let vr = data.waveVerticalRadius
        let curveStartY = vr + data.centerY
        let isLeft = self.side == .left
        let sign = isLeft ? 1.0 : -1.0

        let x = isLeft ? -50 : SliderData.width + 50
        path.move(to: CGPoint(x: waveLedge, y: -100))
        path.addLine(to: CGPoint(x: x, y: -100))
        path.addLine(to: CGPoint(x: x, y: SliderData.height))
        path.addLine(to: CGPoint(x: waveLedge, y: SliderData.height))
        path.addLine(to: CGPoint(x: waveLedge, y: curveStartY))

        var index = 0
        while index < WaveView.data.count {
            let x1 = waveLedge + sign * hr * WaveView.data[index]
            let y1 = curveStartY - vr * WaveView.data[index + 1]
            let x2 = waveLedge + sign * hr * WaveView.data[index + 2]
            let y2 = curveStartY - vr * WaveView.data[index + 3]
            let x = waveLedge + sign * hr * WaveView.data[index + 4]
            let y = curveStartY - vr * WaveView.data[index + 5]
            index += 6

            path.addCurve(to: CGPoint(x: x, y: y),
                          control1: CGPoint(x: x1, y: y1),
                          control2: CGPoint(x: x2, y: y2))
        }

        return path
    }

    private static let data = [
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
