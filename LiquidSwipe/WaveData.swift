//
//  WaveData.swift
//  LiquidSwipe
//
//  Created by Yuri Strot on 9/18/19.
//  Copyright © 2019 Exyte. All rights reserved.
//

import SwiftUI

public struct WaveConfig {

    static let buttonRadius: Double = 24.0
    static let arrowWidth: Double = 4.0
    static let arrowHeight: Double = 10.0

    static let colors = [0x0074D9, 0x7FDBFF, 0x39CCCC, 0x3D9970, 0x2ECC40, 0x01FF70,
                         0xFFDC00, 0xFF851B, 0xFF4136, 0xF012BE, 0xB10DC9, 0xAAAAAA]
                        .shuffled().map { val in Color(hex: val) }

}

public enum WaveSide {
    case left
    case right
}

public struct WaveData {

    let side: WaveSide
    let y: Double
    let progress: Double

    let buttonOffset: CGSize
    var buttonOpacity: Double {
        return max(1 - progress * 5, 0)
    }

    init(side: WaveSide) {
        self.init(side: side, y: side == .left ? 100.0 : 300.0, progress: 0)
    }

    init(side: WaveSide, y: CGFloat, dx: CGFloat) {
        self.init(side: side, y: Double(y), dx: Double(dx))
    }

    init(side: WaveSide, y: Double, dx: Double) {
        let progress = min(1.0, max(0, (side == .left ? dx : -dx) * 0.45 / WaveData.width))
        self.init(side: side, y: y, progress: progress)
    }

    init(side: WaveSide, y: Double, progress: Double) {
        let width = WaveData.width

        let shift = 15.0.interpolate(to: width, fraction: progress, min: 0.2, max: 0.8)
        let hr = WaveData.getHr(from: 48, to: width * 0.8, p: progress)

        let xSide = side == .left ? shift : width - shift
        let sign = side == .left ? 1.0 : -1.0
        let hs = WaveConfig.buttonRadius + 8
        let offset = CGSize(width: xSide + sign * (hr - hs), height: y)
        self.init(side: side, y: y, progress: progress, offset: offset)
    }

    init(side: WaveSide, y: Double, progress: Double, offset: CGSize) {
        self.side = side
        self.y = y
        self.progress = progress
        self.buttonOffset = offset
    }

    func drag(value: DragGesture.Value) -> WaveData {
        return WaveData(side: side, y: value.location.y, dx: value.translation.width)
    }

    func swipe() -> WaveData {
        return WaveData(side: side, y: y, progress: 1)
    }

    func isCancelled(value: DragGesture.Value) -> Bool {
        return drag(value: value).progress < 0.15
    }

    func initial() -> WaveData {
        return WaveData(side: side, y: y, progress: 0)
    }

    private static var width: Double {
        return Double(UIScreen.main.bounds.width)
    }

    private static var height: Double {
        return Double(UIScreen.main.bounds.height)
    }

    private static func getHr(from: Double, to: Double, p: Double) -> Double {
        let p1: Double = 0.4
        if p <= p1 {
            return from.interpolate(to: to, fraction: p, max: p1)
        } else if p >= 1 {
            return to
        }
        let t = (p - p1) / (1 - p1)
        let m: Double = 9.8
        let beta: Double = 40.0 / (2 * m)
        let omega = pow(-pow(beta, 2) + pow(50.0 / m, 2), 0.5)
        return to * exp(-beta * t) * cos(omega * t)
    }

}

extension Color {
    init(hex: Int) {
        self.init(
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255
        )
    }
}

extension Double {
    func interpolate(to: Double, fraction: Double, min: Double = 0, max: Double = 1) -> Double {
        if fraction <= min {
            return self
        } else if fraction >= max {
            return to
        }
        return self + (to - self) * (fraction - min) / (max - min)
    }
}
