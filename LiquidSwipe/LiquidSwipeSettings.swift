//
//  LiquidSwipeSettings.swift
//  LiquidSwipeSwiftUI
//
//  Created by Mark Goldin on 22/08/2019.
//  Copyright © 2019 Exyte. All rights reserved.
//

import SwiftUI

let pad: CGFloat = 16.0
let circleRadius: CGFloat = 24.0

let sizeW: CGFloat = UIScreen.main.bounds.width
let sizeH: CGFloat = UIScreen.main.bounds.height

extension Color {
    init(hex: Int) {
        self.init(
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255
        )
    }
}
