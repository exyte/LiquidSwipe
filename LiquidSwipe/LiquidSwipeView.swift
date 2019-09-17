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

    @State var wavesOffset: CGFloat = 0
    @State var leftWaveData = WaveData(side: .left)
    @State var rightWaveData = WaveData(side: .right)

    let colors = [0x0074D9, 0x7FDBFF, 0x39CCCC, 0x3D9970, 0x2ECC40, 0x01FF70,
                  0xFFDC00, 0xFF851B, 0xFF4136, 0xF012BE, 0xB10DC9, 0xAAAAAA]
                 .shuffled().map { val in Color(hex: val) }

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
        let wave = WaveView(data: leftWaveData)

        let dragGesture = DragGesture()
            .onChanged { result in
                self.topWave = WaveSide.left
                self.leftWaveData = self.leftWaveData.dragChange(location: result.location, translation: result.translation)
        }
        .onEnded { result in
            withAnimation(Animation.spring()) {
                self.leftWaveData = self.leftWaveData.dragEnd(location: result.location, translation: result.translation)
            }
            self.reload(actionWaveAlignment: .left, dx: result.translation.width)
        }

        let tapGesture = TapGesture().onEnded { result in
            withAnimation(Animation.spring()) {
                self.leftWaveData = self.leftWaveData.tapEnd()
            }
            self.reload(actionWaveAlignment: .left, dx: 1000)
        }

        return wave
            .foregroundColor(colors[prevIndex()])
            .gesture(dragGesture.simultaneously(with: tapGesture))
    }
    
    func rightWave() -> some View {
        let wave = WaveView(data: rightWaveData)

        let dragGesture = DragGesture()
            .onChanged { result in
                self.topWave = WaveSide.right
                self.rightWaveData = self.rightWaveData.dragChange(location: result.location, translation: result.translation)
        }
        .onEnded { result in
            withAnimation(.spring()) {
                self.rightWaveData = self.rightWaveData.dragEnd(location: result.location, translation: result.translation)
            }
            self.reload(actionWaveAlignment: .right, dx: -result.translation.width)
        }

        let tapGesture = TapGesture().onEnded { result in
            withAnimation(Animation.spring()) {
                self.rightWaveData = self.rightWaveData.tapEnd()
            }
            self.reload(actionWaveAlignment: .right, dx: 1000)
        }

        return wave
            .foregroundColor(colors[nextIndex()])
            .gesture(dragGesture.simultaneously(with: tapGesture))
    }

    func rightDragAreaIcon() -> some View {
        return rightWaveData.button()
    }

    func leftDragAreaIcon() -> some View {
        return leftWaveData.button()
    }

    private func reload(actionWaveAlignment: WaveSide, dx: CGFloat) {
        let progress = WaveView.getProgress(dx: dx)

        if progress > 0.15 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.pageIndex = actionWaveAlignment == .left ? self.prevIndex() : self.nextIndex()

                self.leftWaveData = self.leftWaveData.reload()
                self.rightWaveData = self.rightWaveData.reload()

                self.wavesOffset = 100

                withAnimation(.spring()) {
                    self.leftWaveData = self.leftWaveData.show()
                    self.rightWaveData = self.rightWaveData.show()
                    self.wavesOffset = 0
                }
            }
        } else {
            withAnimation(.basic()) {
                self.leftWaveData = self.leftWaveData.back()
                self.rightWaveData = self.rightWaveData.back()
            }
        }
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
