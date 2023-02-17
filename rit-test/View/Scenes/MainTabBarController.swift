import UIKit

class MainTabBarController: UITabBarController, SettingsDelegate, MainControllerDelegate {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let settingsVC = viewControllers?.last as? SettingsViewController {
            settingsVC.delegate = self
        }
        
        if let mainVC = viewControllers?.first as? MainViewController {
            mainVC.delegate = self
        }
    }

    func didChangeUnits(to units: SpeedometerUnitsProtocol) {
        if let mainVC = viewControllers?.first as? MainViewController {
            mainVC.units = units
        }
    }
    
    func setSwitchStateOn(_ value: Int) {
        if let settingsVC = viewControllers?.last as? SettingsViewController {
            settingsVC.shouldSwitch = value == 1 ? true : false
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
