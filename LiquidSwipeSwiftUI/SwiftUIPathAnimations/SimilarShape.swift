import Foundation
import SwiftUI


/// `SimilarShape` can be used when animating similars `Path`, that means a path that
/// contains same types and number of `Path.Element`. I.e.: Animating different `Rect` or `Path(roundedRect:cornerRadius:)` with different cornerRadius etc..
public struct SimilarShape: Shape, Animatable {
    var path: Path

    public init(path: Path) {
        self.path = path
    }

    public func path(in rect: CGRect) -> Path {
        return path
    }

    public var animatableData: AnimatableDataShape {
        get {
            AnimatableDataShape(path: path)
        }
        set {
            path = newValue.makePath()
        }
    }
}


