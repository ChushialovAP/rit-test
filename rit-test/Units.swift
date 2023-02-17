public protocol SpeedometerUnitsProtocol {
    var text: String {get set}
    var textPerHour: String {get set}
    var factorToGetFromMetersPerSecond: Double {get set}
    var factorToGetFromMeters: Double {get set}
    var maxValue: Double {get set}
    var enumCase: UnitsEnum {get set}
}

struct Km: SpeedometerUnitsProtocol {
    var text: String = "km"
    var textPerHour: String = "km/h"
    var factorToGetFromMetersPerSecond: Double = 3.6
    var factorToGetFromMeters: Double = 0.001
    var maxValue: Double = 240
    var enumCase: UnitsEnum = .Km
}

struct Mi: SpeedometerUnitsProtocol {
    var text: String = "mi"
    var textPerHour: String = "mph"
    var factorToGetFromMetersPerSecond: Double = 2.23694
    var factorToGetFromMeters: Double = 0.000621371
    var maxValue: Double = 160
    var enumCase: UnitsEnum = .Mi
}
