//
//  LiquidSwipeSettings.swift
//  LiquidSwipeSwiftUI
//
//  Created by Mark Goldin on 22/08/2019.
//  Copyright © 2019 Exyte. All rights reserved.
//

import SwiftUI

let pad: CGFloat = 16.0
let circleRadius: CGFloat = 25.0

let sizeW: CGFloat = UIScreen.main.bounds.size.width
let sizeH: CGFloat = UIScreen.main.bounds.size.height

class LiquidSwipeSettings {
    static let shared = LiquidSwipeSettings()
    
    let colors: [Color] = [
        Color(hex: 0x0074D9),
        Color(hex: 0x7FDBFF),
        Color(hex: 0x39CCCC),
        
        Color(hex: 0x3D9970),
        Color(hex: 0x2ECC40),
        Color(hex: 0x01FF70),
        
        Color(hex: 0xFFDC00),
        Color(hex: 0xFF851B),
        Color(hex: 0xFF4136),
        Color(hex: 0xF012BE),
        
        Color(hex: 0xB10DC9),
        Color(hex: 0xAAAAAA),
        Color(hex: 0xDDDDDD)
        ].shuffled()
    
    var nextColor: Color {
        if colorIndex < colors.count - 1 {
            colorIndex += 1
        } else {
            colorIndex = 0
        }
        
        return colors[colorIndex]
    }
    
    private var colorIndex = -1
    
    var prevColor: Color {
        if colorIndex > 0 {
            colorIndex -= 1
        } else {
            colorIndex = colors.count - 1
        }
        
        return colors[colorIndex]
    }
}

extension Color {
    init(hex: Int, alpha: Double = 1) {
        let components = (
            R: Double((hex >> 16) & 0xff) / 255,
            G: Double((hex >> 08) & 0xff) / 255,
            B: Double((hex >> 00) & 0xff) / 255
        )
        self.init(
            .sRGB,
            red: components.R,
            green: components.G,
            blue: components.B,
            opacity: alpha
        )
    }
}
