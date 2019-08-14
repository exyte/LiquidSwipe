//
//  Array+VectorArithmetic.swift
//  SwiftUI+PathAnimations
//
//  Created by Alfredo Delli Bovi on 6/30/19.
//  Copyright © 2019 Alfredo Delli Bovi. All rights reserved.
//

import Foundation
import SwiftUI

extension Array: AdditiveArithmetic & VectorArithmetic where Element: VectorArithmetic  {
    public static func -= (lhs: inout Self, rhs: Self) {
        let range = (lhs.startIndex..<lhs.endIndex)
            .clamped(to: rhs.startIndex..<rhs.endIndex)

        for index in range {
            lhs[index] -= rhs[index]
        }
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        var lhs = lhs
        lhs -= rhs
        return lhs
    }

    public static func += (lhs: inout Self, rhs: Self) {
        let range = (lhs.startIndex..<lhs.endIndex)
            .clamped(to: rhs.startIndex..<rhs.endIndex)
        for index in range {
            lhs[index] += rhs[index]
        }
    }

    public static func + (lhs: Self, rhs: Self) -> Self {
        var lhs = lhs
        lhs += rhs
        return lhs
    }

    mutating public func scale(by rhs: Double) {
        for index in startIndex..<endIndex {
            self[index].scale(by: rhs)
        }
    }

    public var magnitudeSquared: Double {
        reduce(into: 0.0) { (result, new) in
            result += new.magnitudeSquared
        }
    }

    public static var zero: Self { .init() }
}


extension Path {
    var elements: [Path.Element] {
        var elements: [Path.Element] = []
        forEach { elements.append($0) }
        return elements
    }

    init(elements: [Path.Element]) {
        self.init()
        for element in elements {
            switch element {
            case let .move(to: point):
                self.move(to: point)
            case let .line(to: point):
                self.addLine(to: point)
            case let .quadCurve(to: point, control: control):
                self.addQuadCurve(to: point, control: control)
            case let .curve(to: point, control1: control1, control2: control2):
                self.addCurve(to: point, control1: control1, control2: control2)
            case .closeSubpath:
                self.closeSubpath()
            @unknown default:
                fatalError("Unsupported Path.Element: \(element)")
            }
        }
    }
}
