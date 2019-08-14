import Foundation
import SwiftUI

class PathPointCalculator {
    let elements: [Path.Element], length: Length, numberOfPoints: Int
    init(path: Path, numberOfPoints: Int) {
        self.elements = path.elements
        self.length = path.length
        self.numberOfPoints = numberOfPoints
    }

    var walkedLength: CGFloat = 0
    var firstPointInSubpath: CGPoint?
    var currentPoint: CGPoint?
    var currentIndex = 0

    func makePoints() -> [CGPoint] {
        (0..<numberOfPoints)
            .map { Length($0)/Length(numberOfPoints) }
            .map(makePoint)
    }

    private func makePoint(atPercent percent: Length) -> CGPoint {
        let percentLength = length * percent

        for (index, element) in elements.enumerated().dropFirst(currentIndex) {
            currentIndex = index

            switch(element) {
            case let .move(to: point0):
                currentPoint = point0

                if firstPointInSubpath == nil {
                    firstPointInSubpath = point0
                }
            case let .line(to: point1):
                let point0 = currentPoint!
                let totalSegmentLength = linearLength(point0: point0, point1: point1)

                if walkedLength + totalSegmentLength >= percentLength {
                    let partialSegmentLength = percentLength - walkedLength
                    let segmentPercent = partialSegmentLength / totalSegmentLength
                    return linearPoint(atPercent: segmentPercent, point0: point0, point1: point1)
                }

                walkedLength += totalSegmentLength
                currentPoint = point1
            case let .quadCurve(to: point1, control: control1):
                let point0 = currentPoint!
                let totalSegmentLength = quadCurveLength(point0: point0, control1: control1, point1: point1)

                if walkedLength + totalSegmentLength >= percentLength {
                    let partialSegmentLength = percentLength - walkedLength
                    let segmentPercent = partialSegmentLength / totalSegmentLength
                    return quadCurvePoint(atPercent: segmentPercent, point0: point0, control1: control1, point1: point1)
                }

                walkedLength += totalSegmentLength
                currentPoint = point1
            case let .curve(to: point1, control1: control1, control2: control2):
                let point0 = currentPoint!
                let length = cubicCurveLength(point0: point0, control1: control1, control2: control2, point1: point1)

                if walkedLength + length >= percentLength {
                    let partialSegmentLength = percentLength - walkedLength
                    let segmentPercent = partialSegmentLength / length
                    return cubicCurvePoint(atPercent: segmentPercent, point0: point0, control1: control1, control2: control2, point1: point1)
                }

                walkedLength += length
                currentPoint = point1
            case .closeSubpath:
                guard let point0 = currentPoint else { break }
                if let point1 = firstPointInSubpath {
                    let length = linearLength(point0: point0, point1: point1)

                    if walkedLength + length >= percentLength {
                        let partialSegmentLength = percentLength - walkedLength
                        let segmentPercent = partialSegmentLength / length
                        return linearPoint(atPercent: segmentPercent, point0: point0, point1: point1)
                    }

                    walkedLength += length
                    currentPoint = point1
                }
                firstPointInSubpath = nil
            @unknown default:
                fatalError()
            }

        }

        fatalError()
    }

}

fileprivate extension Path {

    var length: CGFloat {
        var pathLength: CGFloat = 0.0
        var current = CGPoint.zero
        var origin = CGPoint.zero

        forEach { element in
            pathLength += element.distance(to: current, startPoint: origin)

            if case .move = element {
                origin = element.point
            }

            if element != .closeSubpath {
                current = element.point
            }
        }
        return pathLength
    }
}

fileprivate extension Path.Element {

    var point: CGPoint {
        switch self {
        case .move(to: let point),
             .line(to: let point),
             .quadCurve(to: let point, control: _),
             .curve(to: let point, control1: _, control2: _):
            return point
        case .closeSubpath:
            return .zero
        @unknown default:
            fatalError()
        }
    }

    func distance(to origin: CGPoint, startPoint: CGPoint) -> CGFloat {
        switch self {
        case .move:
            return 0
        case let .line(to: point):
            return linearLength(point0: origin, point1: point)
        case let .quadCurve(to: point, control: control):
            return quadCurveLength(point0: origin, control1: control, point1: point)
        case let .curve(to: point, control1: control1, control2: control2):
            return cubicCurveLength(point0: origin, control1: control1, control2: control2, point1: point)
        case .closeSubpath:
            return linearLength(point0: origin, point1: startPoint)
        @unknown default:
            fatalError()
        }
    }
}

func linearLength(point0: CGPoint, point1: CGPoint) -> CGFloat {
    hypot(point0.x-point1.x, point0.y-point1.y)
}

func linearPoint(atPercent percent: CGFloat, point0: CGPoint, point1: CGPoint) -> CGPoint {
    .init(
        x: linearValue(atPercent: percent, point0: point0.x, point1: point1.x),
        y: linearValue(atPercent: percent, point0: point0.y, point1: point1.y))
}

func linearValue(atPercent percent: CGFloat, point0: CGFloat, point1: CGFloat) -> CGFloat {
    (1-percent) * point0 + percent * point1
}

func quadCurveLength(point0: CGPoint, control1: CGPoint, point1: CGPoint) -> CGFloat {
    var approximateLength: CGFloat = 0
    let steps: CGFloat = 10

    for i in 0..<Int(steps) {
        let percent0 = CGFloat(i) / steps
        let percent1 = CGFloat(i+1) / steps

        let point0 = quadCurvePoint(atPercent: percent0, point0: point0, control1: control1, point1: point1)
        let point1 = quadCurvePoint(atPercent: percent1, point0: point0, control1: control1, point1: point1)
        approximateLength += linearLength(point0: point0, point1: point1)
    }
    return approximateLength
}

func quadCurvePoint(atPercent percent: CGFloat, point0: CGPoint, control1: CGPoint, point1: CGPoint) -> CGPoint {
    .init(
        x: quadCurveValue(atPercent: percent, point0: point0.x, control1: control1.x, point1: point1.x),
        y: quadCurveValue(atPercent: percent, point0: point0.y, control1: control1.y, point1: point1.y))
}

func quadCurveValue(atPercent percent: CGFloat, point0: CGFloat, control1: CGFloat, point1: CGFloat) -> CGFloat {
    pow(1-percent, 2) * point0 + 2 * (1-percent) * percent * control1 + pow(percent, 2) * point1
}

func cubicCurveLength(point0: CGPoint, control1: CGPoint, control2: CGPoint, point1: CGPoint) -> CGFloat {
    var approximateLength: CGFloat = 0
    let steps: CGFloat = 10

    for i in 0..<Int(steps) {
        let percent0 = CGFloat(i) / steps
        let percent1 = CGFloat(i+1) / steps

        let point0 = cubicCurvePoint(atPercent: percent0, point0: point0, control1: control1, control2: control2, point1: point1)
        let point1 = cubicCurvePoint(atPercent: percent1, point0: point0, control1: control1, control2: control2, point1: point1)
        approximateLength += linearLength(point0: point0, point1: point1)
    }

    return approximateLength

}

func cubicCurvePoint(atPercent percent: CGFloat, point0: CGPoint, control1: CGPoint, control2: CGPoint, point1: CGPoint) -> CGPoint {
    .init(
        x: cubicCurveValue(atPercent: percent, point0: point0.x, control1: control1.x, control2: control2.x, point1: point1.x),
        y: cubicCurveValue(atPercent: percent, point0: point0.y, control1: control1.y, control2: control2.y, point1: point1.y))
}

func cubicCurveValue(atPercent percent: CGFloat, point0: CGFloat, control1: CGFloat, control2: CGFloat, point1: CGFloat) -> CGFloat {
    pow(1-percent, 3) * point0 + 3 * pow(1-percent, 2) * percent * control1 + 3 * (1-percent) * pow(percent, 2) * control2 + pow(percent, 3) * point1
}
