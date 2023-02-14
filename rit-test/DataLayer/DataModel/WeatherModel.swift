import Foundation

struct WeatherModel: Codable {
    let current: CurrentWeatherData
}

struct CurrentWeatherData: Codable {
    let temp_c: Double
}
