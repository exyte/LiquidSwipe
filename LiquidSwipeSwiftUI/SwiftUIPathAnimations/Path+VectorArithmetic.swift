//
//  Path+VectorArithmetic.swift
//  SwiftUI+PathAnimations
//
//  Created by Alfredo Delli Bovi on 6/30/19.
//  Copyright © 2019 Alfredo Delli Bovi. All rights reserved.
//

import Foundation
import SwiftUI

extension Path.Element: VectorArithmetic {
    public static func -= (lhs: inout Self, rhs: Self) {
        switch (lhs, rhs) {
        case let (.move(to: lhsPoint), .move(to: rhsPoint)):
            lhs = .move(to: lhsPoint - rhsPoint)
        case let (.line(to: lhsPoint), .line(to: rhsPoint)):
            lhs = .line(to: lhsPoint - rhsPoint)
        case let (.quadCurve(to: lhsPoint, control: lhsControl), .quadCurve(to: rhsPoint, control: rhsControl)):
            lhs = .quadCurve(to: lhsPoint - rhsPoint, control: lhsControl - rhsControl)
        case let (.curve(to: lhsPoint, control1: lhsControl1, control2: lhsControl2),
                  .curve(to: rhsPoint, control1: rhsControl1, control2: rhsControl2)):
            lhs = .curve(to: lhsPoint - rhsPoint, control1: lhsControl1 - rhsControl1, control2: lhsControl2 - rhsControl2)
        case (.closeSubpath, .closeSubpath):
            lhs = .closeSubpath
        default:
            fatalError("VectorAirthmetic is not support for path having different types of elements.")
        }
    }

    public static func += (lhs: inout Self, rhs: Self) {
        switch (lhs, rhs) {
        case let (.move(to: lhsPoint), .move(to: rhsPoint)):
            lhs = .move(to: lhsPoint + rhsPoint)
        case let (.line(to: lhsPoint), .line(to: rhsPoint)):
            lhs = .line(to: lhsPoint + rhsPoint)
        case let (.quadCurve(to: lhsPoint, control: lhsControl), .quadCurve(to: rhsPoint, control: rhsControl)):
            lhs = .quadCurve(to: lhsPoint + rhsPoint, control: lhsControl + rhsControl)
        case let (.curve(to: lhsPoint, control1: lhsControl1, control2: lhsControl2),
                  .curve(to: rhsPoint, control1: rhsControl1, control2: rhsControl2)):
            lhs = .curve(to: lhsPoint + rhsPoint, control1: lhsControl1 + rhsControl1, control2: lhsControl2 + rhsControl2)
        case (.closeSubpath, .closeSubpath):
            lhs = .closeSubpath
        default:
            fatalError("VectorAirthmetic is not support for path having different types of elements.")
        }
    }

    mutating public func scale(by rhs: Double) {
        switch self {
        case let .move(to: lhsPoint):
            self = .move(to: lhsPoint.scaled(by: rhs))
        case let .line(to: lhsPoint):
            self = .line(to: lhsPoint.scaled(by: rhs))
        case let .quadCurve(to: lhsPoint, control: lhsControl):
            self = .quadCurve(to: lhsPoint.scaled(by: rhs), control: lhsControl.scaled(by: rhs))
        case let .curve(to: lhsPoint, control1: lhsControl1, control2: lhsControl2):
            self = .curve(to: lhsPoint.scaled(by: rhs), control1: lhsControl1.scaled(by: rhs), control2: lhsControl2.scaled(by: rhs))
        case .closeSubpath:
            self = .closeSubpath
        default:
            fatalError("VectorAirthmetic is not support for path having different types of elements.")
        }
    }

    public var magnitudeSquared: Double {
        switch self {
        case let .move(to: lhsPoint):
            return lhsPoint.animatableData.magnitudeSquared
        case let .line(to: lhsPoint):
            return lhsPoint.animatableData.magnitudeSquared
        case let .quadCurve(to: lhsPoint, control: lhsControl):
            return [lhsPoint.animatableData, lhsControl.animatableData].magnitudeSquared
        case let .curve(to: lhsPoint, control1: lhsControl1, control2: lhsControl2):
            return [lhsPoint.animatableData, lhsControl1.animatableData, lhsControl2.animatableData].magnitudeSquared
        case .closeSubpath:
            return 0
        default:
            fatalError("VectorAirthmetic is not support for path having different types of elements.")
        }
    }

    public static var zero: Self { .move(to: .zero) }

}

extension CGPoint {

    func scaled(by rhs: Double) -> CGPoint {
        var point = self
        point.animatableData.scale(by: rhs)
        return point
    }
    
    static func -(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }

    static func +(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }

    static func * (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x * right, y: left.y * right)
    }

}
