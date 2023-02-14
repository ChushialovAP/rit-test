import Foundation
import CoreLocation

protocol MainPresenterProtocol: AnyObject {
    
    var view: MainViewable? { get set }
    
    func loadData(currentLocation location: CLLocationCoordinate2D?) -> Bool
    
    func saveUserDefaultBrightness(_ value: Double)
    
    func getUserDefaultBrightness() -> Double
    
    func handleUserMovement(_ location: CLLocation)
    
    func resetData()
    
    func saveUserDataBeforeExit(_ isHUDEnabled: Bool)
    
    func readAndSetDataFromDB()
}

final class MainPresenter: MainPresenterProtocol {
    
    weak var view: MainViewable?
    
    private var db = SqliteDatabaseService()
    
    var locations = [CLLocation]()
    var currentDistanceCovered: Double = 0 {
        didSet {
            self.view?.updateDistance(currentDistanceCovered)
        }
    }
    
    var averageSpeed: Double = 0 {
        didSet {
            self.view?.updateAverageSpeed(averageSpeed)
        }
    }
    
    private var locationsShouldBeRemovedWhenAppend = false
    private var timer: Timer? = nil
    
    let defaults = UserDefaults.standard
    
    init (view: MainViewable) {
        self.view = view
        
        timer = Timer.scheduledTimer(timeInterval: 600, target: self, selector: #selector(delayLocationsRemoval), userInfo: nil, repeats: false)
    }
    
    @objc
    private func delayLocationsRemoval() {
        locationsShouldBeRemovedWhenAppend = true
    }
    
    func loadData(currentLocation location: CLLocationCoordinate2D?) -> Bool {
        guard let location = location else {
            print("error to get location")
            return false
        }
        
        let lat = location.latitude
        let lon = location.longitude
        
        let apiKey: String = "35615c982056405892c141823231302"
        
        NetworkService.fetchData(urlString: "http://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(lat),\(lon)&aqi=no") { [weak self] data in
            switch data {
                
            case .success(let result):
                
                guard let self = self else {
                    print("error")
                    return
                }
                
                print(result)
                self.view?.updateWeather(result.current.temp_c)
            case .failure(let error):
                print(error)
            }
        }
        return true
    }
    
    func readAndSetDataFromDB() {
        do {
            try db.openDB()
        } catch {
            print("error while creating connection with database")
        }

        if let entity = db.read() {
            print(entity)
            self.view?.updateDistance(entity.distanceCovered)
            self.view?.enableHUD(entity.isHUDEnabled != 0)
        }
        
        db.closeDB()
    }
    
    func saveUserDataBeforeExit(_ isHUDEnabled: Bool) {
        do {
            try db.openDB()
        } catch {
            print("error while creating connection with database")
        }
        
        let entryToSave = DBRecord(isHUDEnabled: isHUDEnabled,
                                   distanceCovered: self.currentDistanceCovered)
        db.insert(entryToSave)
        
        db.closeDB()
    }
    
    func resetData() {
        self.locations = []
        self.currentDistanceCovered = 0
        
        if let timer = timer {
            timer.invalidate()
        }
        self.averageSpeed = 0
    }
    
    func handleUserMovement(_ location: CLLocation) {
        locations.append(location)
        
        if locationsShouldBeRemovedWhenAppend && locations.count > 2 {
            locations.remove(at: 0)
        }
        
        let lastTwoPoints = locations.suffix(2).map { location in
            location.coordinate
        }
        
        guard lastTwoPoints.count == 2 else {
            return
        }
        currentDistanceCovered = currentDistanceCovered + computeDistance(from: lastTwoPoints)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.averageSpeed = 0
            for location in self.locations {
                self.averageSpeed = self.averageSpeed + max(location.speed, 0)
            }
            self.averageSpeed = self.averageSpeed / Double(self.locations.count)
            self.view?.updateAverageSpeed(self.averageSpeed)
        }
    }
    
    func saveUserDefaultBrightness(_ value: Double) { defaults.set(value, forKey: "currentBrightness") }
    
    func getUserDefaultBrightness() -> Double { defaults.double(forKey: "currentBrightness") }
    
    private func computeDistance(from points: [CLLocationCoordinate2D]) -> Double {
        guard let first = points.first else { return 0.0 }
        let prevPoint = first
        let point = points.last!
        
        let newCount = CLLocation(latitude: prevPoint.latitude, longitude: prevPoint.longitude).distance(
            from: CLLocation(latitude: point.latitude, longitude: point.longitude))
        return newCount
    }
}
