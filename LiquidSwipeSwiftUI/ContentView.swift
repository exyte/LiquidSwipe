//
//  ContentView.swift
//  LiquidSwipeSwiftUI
//
//  Created by Mark Goldin on 08/08/2019.
//  Copyright © 2019 Exyte. All rights reserved.
//

import SwiftUI

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

struct ContentView: View {
    
    @State var backColor: Color = LiquidSwipeSettings.shared.nextColor
    
    @State var leftWaveZIndex: Double = 1
    @State var leftDraggingPoint: CGPoint = CGPoint(x: pad, y: 100)
    @State var leftIsDragging: Bool = false
    @State var leftColor: Color = LiquidSwipeSettings.shared.nextColor
    
    @State var rightWaveZIndex: Double = 2
    @State var rightDraggingPoint: CGPoint = CGPoint(x: pad, y: 300)
    @State var rightIsDragging: Bool = false
    @State var rightColor: Color = LiquidSwipeSettings.shared.nextColor
    
    var body: some View {
        ZStack {
            Rectangle().foregroundColor(backColor)
            leftWave().zIndex(leftWaveZIndex)
            rightWave().zIndex(rightWaveZIndex)
        }
    }

    func leftWave() -> some View {
        func path(in rect: CGRect) -> Path {
            return WaveView(draggingPoint: leftDraggingPoint,
                            isDragging: leftIsDragging,
                            alignment: .left ).path(in: rect)
        }
        
        return GeometryReader { geometry -> AnyView in
            let rect = geometry.frame(in: CoordinateSpace.local)
            return AnyView(SimilarShape(path: path(in: rect)))
        }
        .foregroundColor(leftColor)
            .gesture(DragGesture()
                .onChanged { result in
                    self.leftWaveZIndex = 2
                    self.rightWaveZIndex = 1
                    
                    self.leftIsDragging = true
                    self.leftDraggingPoint = CGPoint(x: result.translation.width, y: result.location.y)
            }
            .onEnded { result in
                withAnimation(.spring()) {
                    self.leftIsDragging = false
                    self.leftDraggingPoint = CGPoint(x: result.translation.width, y: result.location.y)
                }
                self.reload(actionWaveAlignment: .right, dx: self.leftDraggingPoint.x)
            })
    }
    
    func rightWave() -> some View {
        func path(in rect: CGRect) -> Path {
            return WaveView(draggingPoint: rightDraggingPoint,
                            isDragging: rightIsDragging,
                            alignment: .right).path(in: rect)
        }
        
        return GeometryReader { geometry -> AnyView in
            let rect = geometry.frame(in: CoordinateSpace.local)
            return AnyView(SimilarShape(path: path(in: rect)))
        }
        .foregroundColor(rightColor)
            .gesture(DragGesture()
                .onChanged { result in
                    self.leftWaveZIndex = 1
                    self.rightWaveZIndex = 2
                    
                    self.rightIsDragging = true
                    self.rightDraggingPoint = CGPoint(x: result.translation.width, y: result.location.y)
            }
            .onEnded { result in
                withAnimation(.spring()) {
                    self.rightIsDragging = false
                    self.rightDraggingPoint = CGPoint(x: result.translation.width, y: result.location.y)
                }
                self.reload(actionWaveAlignment: .right, dx: self.rightDraggingPoint.x)
            })
    }
    
    private func reload(actionWaveAlignment: WaveAlignment, dx: CGFloat) {
        let progress = WaveView.getProgress(dx: dx)
        if progress > 0.15 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.backColor = actionWaveAlignment == .left ? self.rightColor : self.leftColor
                
                self.leftColor = LiquidSwipeSettings.shared.nextColor
                self.rightColor = LiquidSwipeSettings.shared.nextColor
                
                self.leftDraggingPoint = CGPoint(x: pad, y: 100)
                self.rightDraggingPoint = CGPoint(x: pad, y: 300)
            }
        }
    }
}
