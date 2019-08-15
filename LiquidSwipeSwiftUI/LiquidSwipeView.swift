//
//  LiquidSwipeView.swift
//  LiquidSwipeSwiftUI
//
//  Created by Mark Goldin on 12/08/2019.
//  Copyright © 2019 Exyte. All rights reserved.
//

import SwiftUI

let pad: CGFloat = 16.0
let circleRadius: CGFloat = 25.0

enum WaveAlignment {
    case left
    case right
}

struct WaveView: Shape {
    
    var draggingPoint: CGPoint
    var isDragging: Bool
    var reloadTriggered = false
    let alignment: WaveAlignment
    
    init(draggingPoint: CGPoint, isDragging: Bool, reloadTriggered: Bool, alignment: WaveAlignment) {
        self.draggingPoint = draggingPoint
        self.isDragging = isDragging
        self.reloadTriggered = reloadTriggered
        self.alignment = alignment
    }
    
    func path(in rect: CGRect) -> Path {
        
        let screenCornerX = alignment == .left ? 0 : UIScreen.main.bounds.size.width
        let screenCornerPadX = alignment == .left ? pad : UIScreen.main.bounds.size.width - pad
        
        var points = [
            CGPoint(x: screenCornerX, y: 0),
            CGPoint(x: screenCornerPadX, y: 0),
            CGPoint(x: screenCornerPadX, y: rect.size.height / 2),
            CGPoint(x: screenCornerPadX, y: rect.size.height),
            CGPoint(x: screenCornerX, y: rect.size.height)
        ]
        
        if let foundIndex = findIndex(for: draggingPoint, from: points) {
            points[foundIndex] = draggingPoint
        }
        
        var wave = wavePath(points)
        
        //add circle
        wave.move(to: draggingPoint)
        wave.addEllipse(in: circleRect())
        
        return wave
    }
    
    func circleRect() -> CGRect {
        let rect = CGRect(x: draggingPoint.x - circleRadius,
                          y: draggingPoint.y - circleRadius,
                          width: circleRadius * 2.0,
                          height: circleRadius * 2.0)
        
        return rect
    }
    
    func findIndex(for draggingPoint: CGPoint, from points: [CGPoint]) -> Int? {

        if !isDragging {
            return nil
        }
        
//        for (index, point) in points.enumerated() {
//            if point.y > draggingPoint.y {
//                return index
//            }
//        }
        
        return 2
    }
    
    fileprivate func wavePath(_ points: [CGPoint]) -> Path {
        var path = Path()
        
        let point1 = points[0]
        let point2 = points[1]
        let point3 = points[2]
        let point4 = points[3]
        let point5 = points[4]

        path.move(to: point1)

        path.addLine(to: point2)
        
        var control2X = point3.x * 2
        if alignment == .right {
            control2X = UIScreen.main.bounds.size.width - (UIScreen.main.bounds.size.width - point3.x) * 2
        }
        let control2 = CGPoint(x: control2X, y: point3.y)
        path.addCurve(to: point4, control1: point2, control2: control2)
        path.addLine(to: point5)

        path.closeSubpath()

        return path
    }
    
}
