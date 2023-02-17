import UIKit
import ColorCompatibility

public struct Constants {
    
    struct Fonts {
        static let minMaxValueFont: UIFont = UIFont(name: "HelveticaNeueCyr-Medium", size: 12) ?? UIFont.systemFont(ofSize: 12)
        static let unitOfMeasurmentFont: UIFont = UIFont(name: "Helvetica Neue Condensed Bold", size: 16) ?? UIFont.systemFont(ofSize: 16)
        static let valueFont: UIFont = UIFont(name: "Helvetica Neue Condensed Bold", size: 140) ?? UIFont.systemFont(ofSize: 140)
    }
    
    struct Colors {
        static let subdivisionsColor: UIColor = UIColor(white: 0.5, alpha: 0.5)
        static let divisionsColor: UIColor = UIColor(white: 0.5, alpha: 1)
        static let ringBackgroundColor: UIColor = UIColor(white: 0.9, alpha: 1)
        static let ringStrokeColor: UIColor = UIColor(red: 76.0 / 255,
                                                      green: 217.0 / 255,
                                                      blue: 100.0 / 255,
                                                      alpha: 1)
        static let unitOfMeasurmentTextColor: UIColor = ColorCompatibility.label
        static let valueTextColor: UIColor = ColorCompatibility.label
    }
    
    struct ColorPalette {
        let grayColor: UIColor
        let labelColor: UIColor
        let ringStrokeColor: UIColor
        let backgroundColor: UIColor


        static let light: ColorPalette = .init(
            grayColor: UIColor(red: 0.24, green: 0.24, blue: 0.26, alpha: 0.3),
            labelColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1),
            ringStrokeColor: UIColor(red: 0.2, green: 0.78, blue: 0.35, alpha: 1),
            backgroundColor: UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        )

        static let dark: ColorPalette = .init(
            grayColor: UIColor(red: 0.92, green: 0.92, blue: 0.96, alpha: 0.3),
            labelColor: UIColor(red: 1, green: 1, blue: 1, alpha: 1),
            ringStrokeColor: UIColor(red: 0.19, green: 0.82, blue: 0.35, alpha: 1),
            backgroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        )
    }

}
