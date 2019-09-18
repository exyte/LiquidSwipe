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
                wave(data: $leftWaveData)
                    .foregroundColor(colors[prevIndex()])
                button()
                    .offset(x: leftWaveData.buttonCenter.x,
                            y: leftWaveData.buttonCenter.y)
                    .opacity(leftWaveData.buttonOpacity)
            }
            .zIndex(topWave == WaveSide.left ? 1 : 0)
            .offset(x: -wavesOffset)

            ZStack {
                wave(data: $rightWaveData)
                    .foregroundColor(colors[nextIndex()])
                button()
                    .offset(x: rightWaveData.buttonCenter.x,
                            y: rightWaveData.buttonCenter.y)
                    .opacity(rightWaveData.buttonOpacity)
            }
            .zIndex(topWave == WaveSide.left ? 0 : 1)
            .offset(x: wavesOffset)
        }
        .edgesIgnoringSafeArea(.vertical)
    }

    func button() -> some View {
        return ZStack {
            Path { path in
                path.addEllipse(in: CGRect(x: -SwipeButton.radius,
                   y: -SwipeButton.radius,
                   width: SwipeButton.radius * CGFloat(2),
                   height: SwipeButton.radius * CGFloat(2)))
            }
            .stroke().opacity(0.2)
            Path { path in
                path.move(to: CGPoint(x: -2, y: -5))
                path.addLine(to: CGPoint(x: 2, y: 0))
                path.addLine(to: CGPoint(x: -2, y: 5))
            }
            .stroke(Color.white, lineWidth: 2)
        }
    }

    func wave(data: Binding<WaveData>) -> some View {
        let gesture = DragGesture().onChanged { result in
            self.topWave = data.value.side
            data.value = data.value.dragChange(location: result.location, translation: result.translation)
        }
        .onEnded { result in
            withAnimation(.spring()) {
                data.value = data.value.dragEnd(location: result.location, translation: result.translation)
            }
            let sign: CGFloat = data.value.side == .left ? 1 : -1
            self.drop(at: sign * result.translation.width, side: data.value.side)
        }
        .simultaneously(with: TapGesture().onEnded { result in
            withAnimation(.spring()) {
                data.value = data.value.tapEnd()
            }
            self.swipe(to: data.value.side)
        })
        return WaveView(data: data.value).gesture(gesture)
    }

    private func drop(at dx: CGFloat, side: WaveSide) {
        if WaveView.getProgress(dx: dx) > 0.15 {
            swipe(to: side)
        } else {
            withAnimation(.spring()) {
                self.leftWaveData = self.leftWaveData.back()
                self.rightWaveData = self.rightWaveData.back()
            }
        }
    }

    private func swipe(to side: WaveSide) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.pageIndex = side == .left ? self.prevIndex() : self.nextIndex()

            self.leftWaveData = self.leftWaveData.reload()
            self.rightWaveData = self.rightWaveData.reload()
            self.wavesOffset = 100
            
            withAnimation(.spring()) {
                self.leftWaveData = self.leftWaveData.show()
                self.rightWaveData = self.rightWaveData.show()
                self.wavesOffset = 0
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
