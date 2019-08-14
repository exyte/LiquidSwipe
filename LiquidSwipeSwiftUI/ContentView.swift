//
//  ContentView.swift
//  LiquidSwipeSwiftUI
//
//  Created by Mark Goldin on 08/08/2019.
//  Copyright © 2019 Exyte. All rights reserved.
//

import SwiftUI
//
//let dragCircleRadius: CGFloat = 30.0
//let pad: CGFloat = 8.0
//
//struct Bloop : View {
//
//    var draggedOffset: CGSize
//    var color: Color
//
//    var body: some View {
//
//        GeometryReader { geometry in
//
//            Path { path in
//                path.move(
//                    to: CGPoint(x: 0, y: 0)
//                )
//
//                path.addLine(
//                    to: CGPoint(x: pad, y: 0)
//                )
//
//                path.addLine(
//                    to: CGPoint(x: self.draggedOffset.width, y: self.draggedOffset.height)
//                )
//
//                path.addLine(
//                    to: CGPoint(x: pad, y: geometry.size.height)
//                )
//
//                path.addLine(
//                    to: CGPoint(x: 0, y: geometry.size.height)
//                )
//            }
//            .foregroundColor(self.color)
//        }
//    }
//}
//
//struct ContentView: View {
//
//    var body: some View {
//        let screenSize = UIScreen.main.bounds.size
//
//        let viewStateLeft = CGSize(width: -screenSize.width / 2 + dragCircleRadius + pad,
//                                   height: -screenSize.height / 4)
//        let lCircle = DragCircle(viewState: viewStateLeft, color: .red)
//
//
//        let viewStateRight = CGSize(width: screenSize.width / 2 - dragCircleRadius - pad,
//                                    height: screenSize.height / 4)
//        let rCircle = DragCircle(viewState: viewStateRight, color: .blue)
//
//        return lCircle
//
////        return ZStack {
////            lCircle
////            rCircle
////        }
//    }
//
//}
//
//struct DragCircle: View {
//
//    enum DragState {
//        case inactive
//        case pressing
//        case dragging(translation: CGSize)
//
//        var translation: CGSize {
//            switch self {
//            case .inactive, .pressing:
//                return .zero
//            case .dragging(let translation):
//                return translation
//            }
//        }
//
//        var isActive: Bool {
//            switch self {
//            case .inactive:
//                return false
//            case .pressing, .dragging:
//                return true
//            }
//        }
//
//        var isDragging: Bool {
//            switch self {
//            case .inactive, .pressing:
//                return false
//            case .dragging:
//                return true
//            }
//        }
//    }
//
//    @GestureState var dragState = DragState.inactive
//    @State var viewState: CGSize
//
//    var color: Color
//
//    var body: some View {
//        let viewStateInitial = viewState
//
//        let minimumLongPressDuration = 0.0
//        let longPressDrag = LongPressGesture(minimumDuration: minimumLongPressDuration)
//            .sequenced(before: DragGesture())
//            .updating($dragState) { value, state, transaction in
//                switch value {
//                // Long press begins.
//                case .first(true):
//                    state = .pressing
//                // Long press confirmed, dragging may begin.
//                case .second(true, let drag):
//                    state = .dragging(translation: drag?.translation ?? .zero)
//                // Dragging ended or the long press cancelled.
//                default:
//                    state = .inactive
//                }
//        }
//        .onEnded { value in
//            guard case .second(true, let drag?) = value else {
//                return
//            }
//
//            self.viewState.width = viewStateInitial.width
//            self.viewState.height += drag.translation.height
//        }
//
//        let bloop = Bloop(draggedOffset: CGSize(width: viewState.width + dragState.translation.width + UIScreen.main.bounds.size.width / 2,
//                                                height: viewState.height + dragState.translation.height + UIScreen.main.bounds.size.height / 2 - dragCircleRadius - pad),
//
//                          color: color)
//
//        let circle = Circle()
//            .fill(self.color)
//            .overlay(Circle().stroke(Color.black, lineWidth: 1))
//            .frame(width: dragCircleRadius * 2, height: dragCircleRadius * 2, alignment: .center)
//            .offset(
//                x: viewState.width + dragState.translation.width,
//                y: viewState.height + dragState.translation.height
//        )
//            .animation(nil)
//            .gesture(longPressDrag)
//
//        let arrow = Text(">")
//        .offset(
//            x: viewState.width + dragState.translation.width,
//            y: viewState.height + dragState.translation.height
//        )
//        .animation(nil)
//
//        return ZStack {
//            bloop
//            circle
//            arrow
//        }
//    }
//}


//import SwiftUIPathAnimations

struct ContentView: View {
    
    @State var draggingPoint: CGPoint = .zero
    @State var isDragging: Bool = false
    
    var body: some View {
        
        shape()
            .foregroundColor(Color.blue)
            .gesture(DragGesture()
                .onChanged { result in
                    self.draggingPoint = result.location
                    self.isDragging = true
            }
            .onEnded { result in
                withAnimation(.spring()) {
                    self.isDragging = false
                }
            })
        
    }
    
    func shape() -> some View {
        func path(in rect: CGRect) -> Path {
            return LiquidSwipeView(draggingPoint: draggingPoint, isDragging: isDragging).path(in: rect)
        }
        
        return GeometryReader { geometry -> AnyView in
            let rect = geometry.frame(in: CoordinateSpace.local)
            return AnyView(SimilarShape(path: path(in: rect)))
        }
    }
    
    
}
