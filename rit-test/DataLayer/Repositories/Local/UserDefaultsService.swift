import Foundation

class UserDefaultsService {
    let defaults = UserDefaults.standard
    
    func saveUserDefaultBrightness(_ value: Double) { defaults.set(value, forKey: "currentBrightness") }
    
    func getUserDefaultBrightness() -> Double { defaults.double(forKey: "currentBrightness") }
}
