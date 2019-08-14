import Foundation
import SwiftUI


/// `InterpolatedShape` will animate different shapes with different elements or number of elements.
/// The original path will be interpolate, as a result an approximate and slighlty different path will be create during the animation. If your path has the same type of `Path.Element` but different points use `SimilarShape` instead.
public struct InterpolatedShape: Shape, Animatable {
    var path: Path

    public init(path: Path) {
        self.path = path
    }

    public func path(in rect: CGRect) -> Path {
        return path
    }

    public var animatableData: AnimatableDataShape {
        get {
            AnimatableDataShape(interpolatingPath: path)
        }
        set {
            path = newValue.makePath()
        }
    }
}
