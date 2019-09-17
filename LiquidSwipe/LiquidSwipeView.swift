//
//  ContentView.swift
//  LiquidSwipeSwiftUI
//
//  Created by Mark Goldin on 08/08/2019.
//  Copyright © 2019 Exyte. All rights reserved.
//

import SwiftUI

struct LiquidSwipeView: View {

    @State var topWave = WaveSide.right
    @State var pageIndex = 0

    @State var leftDraggingPoint: CGPoint = CGPoint(x: 0.01, y: 100)
    @State var leftDraggingPointAdjusted: CGPoint = CGPoint(x: DragAreaIcon.radius + 4, y: 100)
    @State var leftDraggingOpacity: Double = 1

    @State var rightDraggingPoint: CGPoint = CGPoint(x: 0.01, y: 300)
    @State var rightDraggingPointAdjusted: CGPoint = CGPoint(x: WaveView.bounds.width - DragAreaIcon.radius - 4, y: 300)
    @State var rightDraggingOpacity: Double = 1

    @State var wavesOffset: CGFloat = 0

    let colors = [0x0074D9, 0x7FDBFF, 0x39CCCC, 0x3D9970, 0x2ECC40, 0x01FF70,
                  0xFFDC00, 0xFF851B, 0xFF4136, 0xF012BE, 0xB10DC9, 0xAAAAAA]
                 .shuffled().map { val in Color(hex: val) }

    let pad: CGFloat = 16.0

    var body: some View {
        ZStack {
            Rectangle().foregroundColor(colors[pageIndex])

            ZStack {
                leftWave()
                leftDragAreaIcon()
            }
            .zIndex(topWave == WaveSide.left ? 1 : 0)
            .offset(x: -wavesOffset)

            ZStack {
                rightWave()
                rightDragAreaIcon()
            }
            .zIndex(topWave == WaveSide.left ? 0 : 1)
            .offset(x: wavesOffset)
        }
        .edgesIgnoringSafeArea(.vertical)
    }
    
    func leftWave() -> some View {
        let wave = WaveView(draggingPoint: leftDraggingPoint, alignment: WaveSide.left)

        let dragGesture = DragGesture()
            .onChanged { result in
                self.topWave = WaveSide.left

                self.leftDraggingPoint = self.calculatePoint(location: result.location, translation: result.translation, alignment: .left, isDragging: true)

                let data = WaveView.adjustedDragPoint(point: CGPoint(x: result.translation.width, y: result.location.y), alignment: .left)

                self.leftDraggingPointAdjusted = data.0
                self.leftDraggingOpacity = data.1
        }
        .onEnded { result in
            withAnimation(Animation.spring()) {
                self.leftDraggingPoint = self.calculatePoint(location: result.location, translation: result.translation, alignment: .left, isDragging: false)

                self.leftDraggingOpacity = 0
            }
            self.reload(actionWaveAlignment: .left, dx: result.translation.width)
        }

        let tapGesture = TapGesture().onEnded { result in
            withAnimation(Animation.spring()) {
                self.leftDraggingPoint = CGPoint(x: 1, y: 0)
                self.leftDraggingOpacity = 0
            }
            self.reload(actionWaveAlignment: .left, dx: 1000)
        }

        return wave
            .foregroundColor(colors[prevIndex()])
            .gesture(dragGesture.simultaneously(with: tapGesture))
    }
    
    func rightWave() -> some View {
        let wave = WaveView(draggingPoint: rightDraggingPoint, alignment: WaveSide.right)

        let dragGesture = DragGesture()
            .onChanged { result in
                self.topWave = WaveSide.right

                self.rightDraggingPoint = self.calculatePoint(location: result.location, translation: result.translation, alignment: .right, isDragging: true)

                let data = WaveView.adjustedDragPoint(point: CGPoint(x: result.translation.width, y: result.location.y), alignment: .right)

                self.rightDraggingPointAdjusted = data.0
                self.rightDraggingOpacity = data.1
        }
        .onEnded { result in
            withAnimation(.spring()) {
                self.rightDraggingPoint = self.calculatePoint(location: result.location, translation: result.translation, alignment: .right, isDragging: false)

                self.rightDraggingOpacity = 0
            }
            self.reload(actionWaveAlignment: .right, dx: -result.translation.width)
        }

        let tapGesture = TapGesture().onEnded { result in
            withAnimation(Animation.spring()) {
                self.rightDraggingPoint = CGPoint(x: 1, y: 0)
                self.rightDraggingOpacity = 0
            }
            self.reload(actionWaveAlignment: .right, dx: 1000)
        }

        return wave
            .foregroundColor(colors[nextIndex()])
            .gesture(dragGesture.simultaneously(with: tapGesture))
    }
    
    func rightDragAreaIcon() -> some View {
        return DragAreaIcon(draggingPoint: rightDraggingPointAdjusted, alignment: WaveSide.right)
            .opacity(rightDraggingOpacity)
    }
    
    func leftDragAreaIcon() -> some View {
        return DragAreaIcon(draggingPoint: leftDraggingPointAdjusted, alignment: WaveSide.left)
            .opacity(leftDraggingOpacity)
    }
    
    private func reload(actionWaveAlignment: WaveSide, dx: CGFloat) {
        let progress = WaveView.getProgress(dx: dx)

        if progress > 0.15 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.pageIndex = actionWaveAlignment == .left ? self.prevIndex() : self.nextIndex()

                self.leftDraggingPoint = self.calculatePoint(location: CGPoint(x: 0, y: 100), translation: CGSize(width: self.pad, height: 0), alignment: .left, isDragging: false)
     
                self.rightDraggingPoint = self.calculatePoint(location: CGPoint(x: 0, y: 300), translation: CGSize(width: self.pad, height: 0), alignment: .left, isDragging: false)
               
                self.leftDraggingPointAdjusted = CGPoint(x: DragAreaIcon.radius + 4, y: 100)
                self.rightDraggingPointAdjusted = CGPoint(x: WaveView.bounds.width - DragAreaIcon.radius - 4, y: 300)

                self.wavesOffset = 100

                withAnimation(.spring()) {
                    self.leftDraggingOpacity = 1.0
                    self.rightDraggingOpacity = 1.0
                    self.wavesOffset = 0
                }
            }
        } else {
            withAnimation(.spring()) {
                self.leftDraggingOpacity = 1.0
                self.leftDraggingPointAdjusted = CGPoint(x: DragAreaIcon.radius + 4, y: leftDraggingPoint.y)

                self.rightDraggingOpacity = 1.0
                self.rightDraggingPointAdjusted = CGPoint(x: WaveView.bounds.width - DragAreaIcon.radius - 4, y: rightDraggingPoint.y)
            }
        }
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

    private func nextIndex() -> Int {
        return pageIndex == colors.count - 1 ? 0 : pageIndex + 1
    }

    private func prevIndex() -> Int {
        return pageIndex == 0 ? colors.count - 1 : pageIndex - 1
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
