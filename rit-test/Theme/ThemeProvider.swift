import Foundation
import UIKit

protocol ThemeProvider: AnyObject {
    var theme: Theme { get }
    func register<Observer: Themeable>(observer: Observer)
    func toggleTheme()
}

class LegacyThemeProvider: ThemeProvider {
    static let shared = LegacyThemeProvider()
    var theme: Theme {
        didSet {
            UserDefaults.standard.set(theme == .dark, forKey: "isDark")
            notifyObservers()
        }
    }
    private var observers: NSHashTable<AnyObject> = NSHashTable.weakObjects()

    private init() {
        self.theme = UserDefaults.standard.bool(forKey: "isDark") ? .dark : .light
    }

    func toggleTheme() {
        theme = theme == .light ? .dark : .light
    }

    func register<Observer: Themeable>(observer: Observer) {
        observer.apply(theme: theme)
        self.observers.add(observer)
    }

    private func notifyObservers() {
        DispatchQueue.main.async {
            self.observers.allObjects
                .compactMap({ $0 as? Themeable })
                .forEach({ $0.apply(theme: self.theme) })
        }
    }
}
