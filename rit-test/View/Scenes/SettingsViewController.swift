import UIKit

protocol SettingsDelegate: AnyObject {
    func didChangeUnits(to units: SpeedometerUnitsProtocol)
}

class SettingsViewController: UIViewController {

    @IBOutlet weak var unitsSwitch: UISwitch!
    
    weak var delegate: SettingsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func switchDidChange(_ sender: UISwitch) {
        if sender.isOn {
            delegate?.didChangeUnits(to: Mi())
        } else {
            delegate?.didChangeUnits(to: Km())
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
