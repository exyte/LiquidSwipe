//
//  ContentView.swift
//  LiquidSwipeSwiftUI
//
//  Created by Mark Goldin on 08/08/2019.
//  Copyright © 2019 Exyte. All rights reserved.
//

import SwiftUI

struct LiquidSwipeView: View {

    @State var leftData = WaveData(side: .left)
    @State var rightData = WaveData(side: .right)

    @State var pageIndex = 0
    @State var topWave = WaveSide.right
    @State var waveOffset: CGFloat = 0

    var body: some View {
        ZStack {
            content()
            slider(data: $leftData)
            slider(data: $rightData)
        }
        .edgesIgnoringSafeArea(.vertical)
    }

    func slider(data: Binding<WaveData>) -> some View {
        return ZStack {
            wave(data: data)
            button(data: data.value)
        }
        .zIndex(topWave == data.value.side ? 1 : 0)
        .offset(x: data.value.side == .left ? -waveOffset : waveOffset)
    }

    func content() -> some View {
        return Rectangle().foregroundColor(WaveConfig.colors[pageIndex])
    }

    func button(data: WaveData) -> some View {
        let aw = (data.side == .left ? 1 : -1) * WaveConfig.arrowWidth / 2
        let ah = WaveConfig.arrowHeight / 2
        return ZStack {
            circle(radius: WaveConfig.buttonRadius).stroke().opacity(0.2)
            polyline(-aw, -ah, aw, 0, -aw, ah).stroke(Color.white, lineWidth: 2)
        }
        .offset(data.buttonOffset)
        .opacity(data.buttonOpacity)
    }

    func wave(data: Binding<WaveData>) -> some View {
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
            self.topWave = data.value.side
            self.swipe(data: data)
        })
        return WaveView(data: data.value).gesture(gesture)
            .foregroundColor(WaveConfig.colors[index(of: data.value)])
    }

    private func swipe(data: Binding<WaveData>) {
        withAnimation(.spring()) {
            data.value = data.value.final()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.pageIndex = self.index(of: data.value)
            self.leftData = self.leftData.initial()
            self.rightData = self.rightData.initial()

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

    private func circle(radius: Double) -> Path {
        return Path { path in
            path.addEllipse(in: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2))
        }
    }
    
    private func polyline(_ values: Double...) -> Path {
        return Path { path in
            path.move(to: CGPoint(x: values[0], y: values[1]))
            for i in stride(from: 2, to: values.count, by: 2) {
                path.addLine(to: CGPoint(x: values[i], y: values[i + 1]))
            }
        }
    }

}
