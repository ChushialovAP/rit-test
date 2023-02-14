import UIKit

class MainTabBarController: UITabBarController, SettingsDelegate {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let settingsVC = viewControllers?.last as? SettingsViewController {
            settingsVC.delegate = self
        }
    }

    func didChangeUnits(to units: SpeedometerUnitsProtocol) {
        if let mainVC = viewControllers?.first as? MainViewController {
            mainVC.speedometerView.units = units
            mainVC.digitalSpeedometerView.units = units
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
