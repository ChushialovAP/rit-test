import Foundation
import UIKit

struct Theme: Equatable {
    static let light = Theme(type: .light, colors: .light)
    static let dark = Theme(type: .dark, colors: .dark)

    enum `Type` {
        case light
        case dark
        @available(iOS 13.0, *)
        case adaptive
    }
    let type: Type

    let grayColor: UIColor
    let labelColor: UIColor
    let ringStrokeColor: UIColor
    let backgroundColor: UIColor

    init(type: Type, colors: Constants.ColorPalette) {
        self.type = type
        self.grayColor = colors.grayColor
        self.labelColor = colors.labelColor
        self.ringStrokeColor = colors.ringStrokeColor
        self.backgroundColor = colors.backgroundColor
    }

    public static func == (lhs: Theme, rhs: Theme) -> Bool {
        return lhs.type == rhs.type
    }
}
