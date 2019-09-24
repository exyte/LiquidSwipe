//
//  WaveData.swift
//  LiquidSwipe
//
//  Created by Yuri Strot on 9/18/19.
//  Copyright © 2019 Exyte. All rights reserved.
//

import SwiftUI

struct Config {

    static let leftWaveY = 100.0
    static let rightWaveY = 300.0
    static let buttonRadius = 24.0
    static let buttonMargin = 8.0
    static let arrowWidth = 4.0
    static let arrowHeight = 10.0
    static let swipeVelocity = 0.45
    static let swipeCancelThreshold = 0.15
    static let waveMinLedge = 15.0
    static let waveMinHR = 48.0
    static let waveMinVR = 82.0

    static let colors = [0x0074D9, 0x7FDBFF, 0x39CCCC, 0x3D9970, 0x2ECC40, 0x01FF70,
                         0xFFDC00, 0xFF851B, 0xFF4136, 0xF012BE, 0xB10DC9, 0xAAAAAA]
                        .shuffled().map { val in Color(hex: val) }

}

enum SliderSide {
    case left
    case right
}

struct SliderData {

    let side: SliderSide
    let centerY: Double
    let progress: Double

    init(side: SliderSide) {
        self.init(side: side, centerY: side == .left ? Config.leftWaveY : Config.rightWaveY, progress: 0)
    }

    init(side: SliderSide, centerY: Double, progress: Double) {
        self.side = side
        self.centerY = centerY
        self.progress = progress
    }

    var buttonOffset: CGSize {
        let sign = side == .left ? 1.0 : -1.0
        let hs = Config.buttonRadius + Config.buttonMargin
        return CGSize(width: waveLedgeX + sign * (waveHorizontalRadius - hs), height: centerY)
    }

    var buttonOpacity: Double {
        return max(1 - progress * 5, 0)
    }

    var waveLedgeX: Double {
        let ledge = Config.waveMinLedge.interpolate(to: SliderData.width, in: progress, min: 0.2, max: 0.8)
        return side == .left ? ledge : SliderData.width - ledge
    }

    var waveHorizontalRadius: Double {
        let p1: Double = 0.4
        let to = SliderData.width * 0.8
        if progress <= p1 {
            return Config.waveMinHR.interpolate(to: to, in: progress, max: p1)
        } else if progress >= 1 {
            return to
        }
        let t = (progress - p1) / (1 - p1)
        let m: Double = 9.8
        let beta: Double = 40.0 / (2 * m)
        let omega = pow(-pow(beta, 2) + pow(50.0 / m, 2), 0.5)
        return to * exp(-beta * t) * cos(omega * t)
    }

    var waveVerticalRadius: Double {
        return Config.waveMinVR.interpolate(to: SliderData.height * 0.9, in: progress, max: 0.4)
    }

    func initial() -> SliderData {
        return SliderData(side: side, centerY: centerY, progress: 0)
    }

    func final() -> SliderData {
        return SliderData(side: side, centerY: centerY, progress: 1)
    }

    func drag(value: DragGesture.Value) -> SliderData {
        let dx = (side == .left ? 1 : -1) * Double(value.translation.width)
        let progress = min(1.0, max(0, dx * Config.swipeVelocity / SliderData.width))
        return SliderData(side: side, centerY: Double(value.location.y), progress: progress)
    }

    func isCancelled(value: DragGesture.Value) -> Bool {
        return drag(value: value).progress < Config.swipeCancelThreshold
    }

    static var width: Double {
        return Double(UIScreen.main.bounds.width)
    }

    static var height: Double {
        return Double(UIScreen.main.bounds.height)
    }

}

extension Color {
    init(hex: Int) {
        self.init(red: hex.ff(16), green: hex.ff(08), blue: hex.ff(00))
    }
}

extension Int {
    func ff(_ shift: Int) -> Double {
        return Double((self >> shift) & 0xff) / 255
    }
}

extension Double {
    func interpolate(to: Double, in fraction: Double, min: Double = 0, max: Double = 1) -> Double {
        if fraction <= min {
            return self
        } else if fraction >= max {
            return to
        }
        return self + (to - self) * (fraction - min) / (max - min)
    }
}
