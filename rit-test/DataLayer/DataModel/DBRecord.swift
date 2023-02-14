import Foundation

struct DBRecord {
    var isHUDEnabled: Int
    var distanceCovered: Double
    
    init(isHUDEnabled: Bool, distanceCovered: Double) {
        self.isHUDEnabled = isHUDEnabled ? 1 : 0
        self.distanceCovered = distanceCovered
    }
}


