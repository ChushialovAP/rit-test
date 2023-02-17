import UIKit

public class DigitalSpeedometerView: UIView {
    
    public var value: Double = 0 {
        didSet {
            let possiblyNegativeValue = units == nil ? value * Km().factorToGetFromMetersPerSecond : value * units!.factorToGetFromMetersPerSecond
            value = min(max(possiblyNegativeValue, minValue), maxValue)
            
            valueLabel.text = String(format: "%.0f", value)
        }
    }
    
    public var minValue: Double = 0
    public var maxValue: Double = Km().maxValue
    
    @IBInspectable public var valueFont: UIFont = Constants.Fonts.valueFont
    
    @IBInspectable public var valueTextColor: UIColor = UIColor.clear
    
    @IBInspectable public var unitOfMeasurementFont: UIFont = Constants.Fonts.unitOfMeasurmentFont
    
    @IBInspectable public var unitOfMeasurementTextColor: UIColor = UIColor.clear
    
    public var units: SpeedometerUnitsProtocol? {
        didSet {
            unitOfMeasurementLabel.text = units!.textPerHour
        }
    }
    
    lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var unitOfMeasurementLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override open func draw(_ rect: CGRect) {
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        // value Label
        if valueLabel.superview == nil {
            addSubview(valueLabel)
        }
        valueLabel.text = String(format: "%.0f", value)
        valueLabel.font = valueFont
        valueLabel.minimumScaleFactor = 10 / valueFont.pointSize
        valueLabel.textColor = valueTextColor
        
        valueLabel.frame = CGRect(x: center.x * 1 / 3, y: 0, width: (self.frame.width * 2 / 3) , height: (self.frame.height) * 3 / 5)
        
        // units label
        if unitOfMeasurementLabel.superview == nil {
            addSubview(unitOfMeasurementLabel)
        }
        unitOfMeasurementLabel.text = units!.text + "/h"
        unitOfMeasurementLabel.font = unitOfMeasurementFont
        unitOfMeasurementLabel.minimumScaleFactor = 10/unitOfMeasurementFont.pointSize
        unitOfMeasurementLabel.textColor = unitOfMeasurementTextColor
        unitOfMeasurementLabel.frame = CGRect(x: valueLabel.frame.origin.x,
                                              y: valueLabel.frame.maxY - 10,
                                              width: valueLabel.frame.width,
                                              height: 20)
    }
    
    func apply(theme: Theme) {
        valueTextColor = theme.labelColor
        unitOfMeasurementTextColor = theme.labelColor
        self.backgroundColor = theme.backgroundColor
    }
}

