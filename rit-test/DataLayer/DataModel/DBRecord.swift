import Foundation

struct DBRecord {
    var isHUDEnabled: Int?
    var unitsChosen: Int?
    var distanceCovered: Double
    
    init(isHUDEnabled: Bool?, unitsChosen: Int?, distanceCovered: Double) {
        self.isHUDEnabled = isHUDEnabled != nil ? (isHUDEnabled! ? 1 : 0) : nil
        self.unitsChosen = unitsChosen
        self.distanceCovered = distanceCovered
    }
}


