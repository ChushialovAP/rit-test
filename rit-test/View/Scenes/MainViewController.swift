import UIKit
import CoreLocation

protocol MainViewable: AnyObject {
    
    func updateWeather(_ value: Double)
    
    func updateDistance(_ value: Double)
    
    func updateAverageSpeed(_ value: Double)
    
    func enableHUD(_ shouldEnable: Bool)
}

class MainViewController: UIViewController, CLLocationManagerDelegate, MainViewable {
    
    @IBOutlet weak var speedometerView: SpeedometerView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var digitalSpeedometerView: DigitalSpeedometerView!
    @IBOutlet weak var distanceCoveredLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    
    var presenter: MainPresenterProtocol!
    
    let manager = CLLocationManager()
    
    var isHUDEnabled: Bool = false
    
    var timer: Timer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSpeedometer()
        setupDigitalSpeedometer()
        setupCLLocationManager()
        
        presenter = MainPresenter(view: self)
        
        self.presenter.readAndSetDataFromDB()
        
        NotificationCenter.default.addObserver(self, selector: #selector(saveUserDataBeforeExit), name:  UIApplication.willTerminateNotification, object: nil)
    }

    
    @IBAction func didTouchedHUDButton(_ sender: Any) {
        changeHUDStatus(isHUDEnabled)
    }
    
    @IBAction func didTouchResetButton(_ sender: Any) {
        self.presenter.resetData()
    }
    
    @objc
    private func saveUserDataBeforeExit() {
        UIScreen.main.brightness = CGFloat(self.getCurrentBrightness())
        self.presenter.saveUserDataBeforeExit(isHUDEnabled)
    }
    
    func enableHUD(_ shouldEnable: Bool) {
        print(shouldEnable)
        changeHUDStatus(shouldEnable)
    }
    
    func updateWeather(_ value: Double) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = String(value)
        }
    }
    
    func updateDistance(_ value: Double) {
        let distanceInCurrentUnits = value * (speedometerView.units?.factorToGetFromMeters ?? Km().factorToGetFromMeters)
        DispatchQueue.main.async {
            self.distanceCoveredLabel.text = String(format: "%.2f" , distanceInCurrentUnits) + self.speedometerView.units!.text
        }
    }
    
    func updateAverageSpeed(_ value: Double) {
        let speedInCurrentUnits = value * (speedometerView.units?.factorToGetFromMetersPerSecond ?? Km().factorToGetFromMeters)
        DispatchQueue.main.async {
            self.averageSpeedLabel.text = String(format: "%.2f", max(0, speedInCurrentUnits)) + self.speedometerView.units!.text + "/h"
        }
    }
    
    private func changeHUDStatus(_ isHUDEnabled: Bool) {
        self.isHUDEnabled = !isHUDEnabled
        let shouldRotateScale: CGFloat = isHUDEnabled ? -1 : 1
        
        if Int(shouldRotateScale) == -1 {
            self.saveCurrentBrightness()
            DispatchQueue.main.async {
                UIScreen.main.brightness = CGFloat(1.0)
            }
        } else {
            DispatchQueue.main.async {
                UIScreen.main.brightness = CGFloat(self.getCurrentBrightness())
            }
        }
        
        self.speedometerView.transform = CGAffineTransform(scaleX: 1, y: shouldRotateScale);
        self.digitalSpeedometerView.transform = CGAffineTransform(scaleX: 1, y: shouldRotateScale)
        
    }
    
    private func saveCurrentBrightness() {
        let currentBrightness = UIScreen.main.brightness
        self.presenter.saveUserDefaultBrightness(currentBrightness)
    }
    
    private func getCurrentBrightness() -> Double {
        self.presenter.getUserDefaultBrightness()
    }
    
    private func setupWheatherLabel(currentLocation location: CLLocationCoordinate2D?) -> Bool {
        return presenter.loadData(currentLocation: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        
        speedometerView.value = location.speed // m/s
        digitalSpeedometerView.value = location.speed // m/s
        
        self.presenter.handleUserMovement(location)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let authorizationStatus: CLAuthorizationStatus
        if #available(iOS 14, *) {
            authorizationStatus = manager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        if authorizationStatus == .authorizedAlways ||
            authorizationStatus == .authorizedWhenInUse {
            DispatchQueue.global(qos: .userInitiated).async {
                var successToLoad = false
                
                while (!successToLoad) {
                    let currentLocation = manager.location
                    
                    successToLoad = self.setupWheatherLabel(currentLocation: currentLocation?.coordinate)
                }
            }
        }
    }
    
    private func setupSpeedometer() {
        self.speedometerView.units = Km()
        speedometerView.value = 0
    }
    
    private func setupDigitalSpeedometer() {
        self.digitalSpeedometerView.units = Km()
        digitalSpeedometerView.value = 0
    }
    
    private func setupCLLocationManager() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
}
