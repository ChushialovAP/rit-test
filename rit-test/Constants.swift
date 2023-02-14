import UIKit
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
        static let unitOfMeasurmentTextColor: UIColor = UIColor(white: 0.3, alpha: 1)
        static let valueTextColor: UIColor = UIColor(white: 0.1, alpha: 1)
    }
}
