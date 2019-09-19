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

    @State var waveOffset: CGFloat = 0
    @State var leftWave = WaveData(side: .left)
    @State var rightWave = WaveData(side: .right)

    var body: some View {
        ZStack {
            content()

            ZStack {
                wave(of: $leftWave)
                button(of: leftWave)
            }
            .zIndex(topWave == WaveSide.left ? 1 : 0)
            .offset(x: -waveOffset)

            ZStack {
                wave(of: $rightWave)
                button(of: rightWave)
            }
            .zIndex(topWave == WaveSide.left ? 0 : 1)
            .offset(x: waveOffset)
        }
        .edgesIgnoringSafeArea(.vertical)
    }

    func content() -> some View {
        return Rectangle().foregroundColor(WaveConfig.colors[pageIndex])
    }

    func button(of wave: WaveData) -> some View {
        let r = WaveConfig.buttonRadius
        let d = r * 2
        let hw = (wave.side == .left ? 1 : -1) * WaveConfig.arrowWidth / 2
        let hh = WaveConfig.arrowHeight / 2
        return ZStack {
            Path { path in
                path.addEllipse(in: CGRect(x: -r, y: -r, width: d, height: d))
            }
            .stroke().opacity(0.2)
            Path { path in
                path.move(to: CGPoint(x: -hw, y: -hh))
                path.addLine(to: CGPoint(x: hw, y: 0))
                path.addLine(to: CGPoint(x: -hw, y: hh))
            }
            .stroke(Color.white, lineWidth: 2)
        }
        .offset(wave.buttonOffset)
        .opacity(wave.buttonOpacity)
    }

    func wave(of data: Binding<WaveData>) -> some View {
        let gesture = DragGesture().onChanged {
            self.topWave = data.value.side
            data.value = data.value.drag(value: $0)
        }
        .onEnded {
            if data.value.isCancelled(value: $0) {
                withAnimation(.spring()) {
                    data.value = data.value.initial()
                }
            } else {
                self.swipe(data: data)
            }
        }
        .simultaneously(with: TapGesture().onEnded {
            self.swipe(data: data)
        })
        return WaveView(data: data.value).gesture(gesture)
            .foregroundColor(WaveConfig.colors[index(of: data.value)])
    }

    private func swipe(data: Binding<WaveData>) {
        withAnimation(.spring()) {
            data.value = data.value.swipe()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.pageIndex = self.index(of: data.value)
            self.leftWave = self.leftWave.initial()
            self.rightWave = self.rightWave.initial()
            self.waveOffset = 100

            withAnimation(.spring()) {
                self.waveOffset = 0
            }
        }
    }

    private func index(of wave: WaveData) -> Int {
        let last = WaveConfig.colors.count - 1
        return wave.side == .left
            ? (pageIndex == 0 ? last : pageIndex - 1)
            : (pageIndex == last ? 0 : pageIndex + 1)
    }

}
