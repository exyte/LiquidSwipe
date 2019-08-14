//
//  LiquidSwipeView.swift
//  LiquidSwipeSwiftUI
//
//  Created by Mark Goldin on 12/08/2019.
//  Copyright © 2019 Exyte. All rights reserved.
//

import SwiftUI

struct LiquidSwipeView: Shape {
    
    var draggingPoint: CGPoint
    var isDragging: Bool
    
    init(draggingPoint: CGPoint, isDragging: Bool) {
        self.draggingPoint = draggingPoint
        self.isDragging = isDragging
    }
    
    func path(in rect: CGRect) -> Path {
  
        let intervals = Array(stride(from: Length(0.0), to: rect.size.height, by: 50))
        var points = intervals
            .map { (16, $0) }
            .map(CGPoint.init)
        
        points.append(CGPoint(x: 16, y: rect.size.height))
        points.append(CGPoint(x: 0, y: rect.size.height))
        
        if let foundIndex = findIndex(for: draggingPoint, from: points) {
            points[foundIndex] = draggingPoint
        }
        
        return interpolateWithCatmullRom(points)
    }
    
    func findIndex(for draggingPoint: CGPoint, from points: [CGPoint]) -> Int? {

        if !isDragging {
            return nil
        }
        
        for (index, point) in points.enumerated() {
            if point.y > draggingPoint.y {
                return index
            }
        }
        
        return nil
    }
    
    fileprivate func interpolateWithCatmullRom(_ points: [CGPoint]) -> Path {
        var path = Path()
        
        path.move(to: CGPoint.zero)
        
        for index in points.startIndex..<points.endIndex {
            let point = points[index]
            path.addLine(to: point)
        }
        path.closeSubpath()

        
        return path
    }
    
}
