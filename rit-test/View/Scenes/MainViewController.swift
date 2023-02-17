import UIKit
import CoreLocation

protocol MainViewable: AnyObject {
    
    func updateWeather(_ value: Double)
    
    func updateDistance(_ value: Double)
    
    func updateAverageSpeed(_ value: Double)
    
    func updateUnits(_ value: SpeedometerUnitsProtocol)
    
    func updateHUDStatus(_ value: Bool)
}

protocol MainControllerDelegate: AnyObject {
    func setSwitchStateOn(_ value: Int)
}

class MainViewController: UIViewController, CLLocationManagerDelegate, MainViewable {
    
    @IBOutlet weak var distanceTextLabel: UILabel!
    @IBOutlet weak var avgSpeedTextLabel: UILabel!
    @IBOutlet weak var temperatureTextLabel: UILabel!
    @IBOutlet weak var speedometerView: SpeedometerView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var digitalSpeedometerView: DigitalSpeedometerView!
    @IBOutlet weak var distanceCoveredLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    
    weak var delegate: MainControllerDelegate?
    
    var presenter: MainPresenterProtocol!
    
    let manager = CLLocationManager()
    
    var isHUDEnabled: Bool = false {
        didSet {
            if (themeProvider.theme == .light && isHUDEnabled == true)
                || (themeProvider.theme == .dark && isHUDEnabled == false) {
                themeProvider.toggleTheme()
            }
            self.changeHUDStatus(isHUDEnabled)
        }
    }
    
    var timer: Timer? = nil
    
    var units: SpeedometerUnitsProtocol = Km() {
        didSet {
            self.speedometerView.units = units
            self.digitalSpeedometerView.units = units
            self.presenter.saveUserData(isHUDEnabled, units.enumCase.rawValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSpeedometer()
        setupDigitalSpeedometer()
        setupCLLocationManager()
        
        presenter = MainPresenter(view: self)
        
        themeProvider.register(observer: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onResignActiveNotification), name:  UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidBecomeActiveNotification), name:  UIApplication.didBecomeActiveNotification, object: nil)
    }

    
    @IBAction func didTouchedHUDButton(_ sender: Any) {
        self.isHUDEnabled = !isHUDEnabled
        print(isHUDEnabled)
        self.presenter.saveUserData(self.isHUDEnabled, self.units.enumCase.rawValue)
    }
    
    @IBAction func didTouchResetButton(_ sender: Any) {
        self.presenter.resetData()
    }
    
    @objc private func onResignActiveNotification() {
        UIScreen.main.brightness = CGFloat(self.getCurrentBrightness())
        self.presenter.setupOnAppWillResignActive()
        manager.stopUpdatingLocation()
    }
    
    @objc private func onDidBecomeActiveNotification() {
        self.presenter.setupOnAppIsActive()
        manager.startUpdatingLocation()
    }
    
    func updateHUDStatus(_ value: Bool) {
        self.isHUDEnabled = value
    }
    
    func updateWeather(_ value: Double) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = String(value)
        }
    }
    
    func updateUnits(_ value: SpeedometerUnitsProtocol) {
        self.units = value
        
        self.delegate?.setSwitchStateOn(units.enumCase.rawValue)
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
            self.averageSpeedLabel.text = String(format: "%.2f", max(0, speedInCurrentUnits)) + self.speedometerView.units!.textPerHour
        }
    }
    
    private func changeHUDStatus(_ isHUDEnabled: Bool) {
        let shouldRotateScale: CGFloat = isHUDEnabled ? -1 : 1

        if Int(shouldRotateScale) == -1 {
            self.saveCurrentBrightness()
            DispatchQueue.main.async {
                UIScreen.main.brightness = CGFloat(1.0)
                UIApplication.shared.isIdleTimerDisabled = true
            }
        } else {
            DispatchQueue.main.async {
                UIScreen.main.brightness = CGFloat(self.getCurrentBrightness())
                UIApplication.shared.isIdleTimerDisabled = false
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
        self.speedometerView.units = units
        speedometerView.value = 0
    }
    
    private func setupDigitalSpeedometer() {
        self.digitalSpeedometerView.units = units
        digitalSpeedometerView.value = 0
    }
    
    private func setupCLLocationManager() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
    }
}

extension MainViewController: Themeable {
    func apply(theme: Theme) {
        self.view.backgroundColor = theme.backgroundColor
        distanceCoveredLabel.textColor = theme.labelColor
        temperatureLabel.textColor = theme.labelColor
        averageSpeedLabel.textColor = theme.labelColor
        avgSpeedTextLabel.textColor = theme.labelColor
        distanceTextLabel.textColor = theme.labelColor
        temperatureTextLabel.textColor = theme.labelColor
        
        speedometerView.apply(theme: theme)
        digitalSpeedometerView.apply(theme: theme)
    }
}
