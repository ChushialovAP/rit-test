import UIKit

protocol Themeable: AnyObject {
    func apply(theme: Theme)
}

extension Themeable where Self: UITraitEnvironment {
    var themeProvider: ThemeProvider {
        return LegacyThemeProvider.shared
    }
}
