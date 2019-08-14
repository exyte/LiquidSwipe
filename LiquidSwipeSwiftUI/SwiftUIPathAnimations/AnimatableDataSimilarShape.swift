//
//  AnimatablePath.swift
//  SwiftUI+PathAnimations
//
//  Created by Alfredo Delli Bovi on 6/30/19.
//  Copyright © 2019 Alfredo Delli Bovi. All rights reserved.
//

import Foundation
import SwiftUI

public struct AnimatableDataShape: VectorArithmetic {
    var elements: [Path.Element]

    init(path: Path) {
        self.elements = path.elements
    }

    init(interpolatingPath path: Path) {
        self.elements = []
        let pointCalculator = PathPointCalculator(path: path, numberOfPoints: 1000)

        for point in pointCalculator.makePoints() {
            if elements.isEmpty {
                elements.append(.move(to: point))
            } else {
                elements.append(.line(to: point))
            }

        }
    }

    private init() {
        self.elements = []
    }

    public static func -= (lhs: inout Self, rhs: Self) {
        lhs.elements -= rhs.elements
    }

    public static func += (lhs: inout Self, rhs: Self) {
        lhs.elements += rhs.elements
    }

    mutating public func scale(by rhs: Double) {
        elements.scale(by: rhs)
    }

    public var magnitudeSquared: Double {
        elements.magnitudeSquared
    }

    public static var zero: Self { .init() }

    func makePath() -> Path {
        Path(elements: elements)
    }
}

extension VectorArithmetic {

    public static func - (lhs: Self, rhs: Self) -> Self {
        var lhs = lhs
        lhs -= rhs
        return lhs
    }

    public static func + (lhs: Self, rhs: Self) -> Self {
        var lhs = lhs
        lhs += rhs
        return lhs
    }
}


