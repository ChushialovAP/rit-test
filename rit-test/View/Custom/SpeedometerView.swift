import UIKit

public class SpeedometerView: UIView {
    
    public var value: Double = 0 {
        didSet {
            let possiblyNegativeValue = units == nil ? value * Km().factorToGetFromMetersPerSecond : value * units!.factorToGetFromMetersPerSecond
            value = min(max(possiblyNegativeValue, minValue), maxValue)
            
            strokeSpeedometer()
        }
    }
    
    public var minValue: Double = 0
    public var maxValue: Double = Km().maxValue
    
    @IBInspectable public var numOfDivisions: Int = 12
    @IBInspectable public var numOfSubdivisions: Int = 10
    
    @IBInspectable public var ringThickness: Double = 15
    @IBInspectable public var lineThickness: Double = 3
    
    @IBInspectable public var subdivisionsColor: UIColor = Constants.Colors.subdivisionsColor
    @IBInspectable public var divisioncColor: UIColor = Constants.Colors.divisionsColor
    
    @IBInspectable public var divisionsRadius: Double = 1.25
    @IBInspectable public var subdivisionsRadius: Double = 0.75
    @IBInspectable public var divisionsPadding: Double = 12
    
    @IBInspectable public var linePadding: Double = 12
    
    public var units: SpeedometerUnitsProtocol? {
        didSet {
            maxValue = units?.maxValue ?? Km().maxValue
        }
    }
    
    var startAngle: Double = .pi * 3/4
    var endAngle: Double = .pi / 4 + .pi * 2
    
    var divisionUnitAngle: Double = 0
    var divisionUnitValue: Double = 0
    
    lazy var progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.contentsScale = UIScreen.main.scale
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = CAShapeLayerLineCap.butt
        layer.lineJoin = CAShapeLayerLineJoin.bevel
        layer.strokeEnd = 0
        return layer
    }()
    
    lazy var minValueLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var maxValueLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override open func draw(_ rect: CGRect) {
        
        // prepare
        divisionUnitAngle  = numOfDivisions != 0 ? (endAngle - startAngle)/Double(numOfDivisions) : 0
        divisionUnitValue  = numOfDivisions != 0 ? (maxValue - minValue)/Double(numOfDivisions) : 0
        
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let ringRadius = Double(min(bounds.width, bounds.height)) / 2 - ringThickness / 2
        let dotRadius = ringRadius - ringThickness / 2 - divisionsPadding - divisionsRadius / 2
        let lineLength = dotRadius - linePadding
        
        
        // ring background
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(CGFloat(ringThickness))
        context?.beginPath()
        context?.addArc(center: center, radius: CGFloat(ringRadius), startAngle: 0, endAngle: .pi * 2, clockwise: false)
        context?.setStrokeColor(Constants.Colors.ringBackgroundColor.withAlphaComponent(0.3).cgColor)
        context?.strokePath()
        
        // ring progress background
        context?.setLineWidth(CGFloat(ringThickness))
        context?.beginPath()
        context?.addArc(center: center, radius: CGFloat(ringRadius), startAngle: startAngle, endAngle: endAngle, clockwise: false)
        context?.setStrokeColor(Constants.Colors.ringBackgroundColor.cgColor)
        context?.strokePath()
        
        // central line
        context?.setLineWidth(CGFloat(lineThickness))
        context?.beginPath()
        context?.move(to: center)
        let lineEndAngle = angleFromValue(value + minValue)
        context?.addLine(to: CGPoint(
            x: lineLength * cos(lineEndAngle) + Double(center.x),
            y: lineLength * sin(lineEndAngle) + Double(center.y)
        ))
        context?.setStrokeColor(Constants.Colors.ringBackgroundColor.cgColor)
        context?.strokePath()
        
        if numOfDivisions != 0 {
            for i in 0...numOfDivisions {
                if numOfSubdivisions != 0 && i != numOfDivisions {
                    for j in 0...numOfSubdivisions {
                        
                        //subvidivisions
                        let value = Double(i) * divisionUnitValue + Double(j) * divisionUnitValue / Double(numOfSubdivisions) + minValue
                        let angle = angleFromValue(value)
                        let point = CGPoint(x: dotRadius * cos(angle) + Double(center.x),
                                            y: dotRadius * sin(angle) + Double(center.y))
                        context?.drawDot(center: point,
                                         radius: subdivisionsRadius,
                                         fillColor: subdivisionsColor)
                    }
                }
                
                // divisions
                let value = Double(i) * divisionUnitValue + minValue
                let angle = angleFromValue(value)
                let point = CGPoint(x: dotRadius * cos(angle) + Double(center.x),
                                    y: dotRadius * sin(angle) + Double(center.y))
                context?.drawDot(center: point,
                                 radius: divisionsRadius,
                                 fillColor: divisioncColor)
            }
        }
        
        //  progress layer
        if progressLayer.superlayer == nil {
            layer.addSublayer(progressLayer)
        }
        progressLayer.frame = CGRect(x: center.x - CGFloat(ringRadius) - CGFloat(ringThickness) / 2,
                                     y: center.y - CGFloat(ringRadius) - CGFloat(ringThickness) / 2,
                                     width: (CGFloat(ringRadius) + CGFloat(ringThickness) / 2) * 2,
                                     height: (CGFloat(ringRadius) + CGFloat(ringThickness) / 2) * 2)
        progressLayer.bounds = progressLayer.frame
        let smoothedPath = UIBezierPath(arcCenter: progressLayer.position,
                                        radius: CGFloat(ringRadius),
                                        startAngle: CGFloat(startAngle),
                                        endAngle: CGFloat(endAngle),
                                        clockwise: true)
        progressLayer.path = smoothedPath.cgPath
        progressLayer.lineWidth = CGFloat(ringThickness)
        
        // Min Value Label
        if minValueLabel.superview == nil {
            addSubview(minValueLabel)
        }
        minValueLabel.text = String(format: "%.0f", minValue)
        minValueLabel.font = Constants.Fonts.minMaxValueFont
        minValueLabel.minimumScaleFactor = 10 / Constants.Fonts.minMaxValueFont.pointSize
        minValueLabel.textColor = .black
        let minDotCenter = CGPoint(x: CGFloat(dotRadius * cos(startAngle)) + center.x,
                                   y: CGFloat(dotRadius * sin(startAngle)) + center.y)
        minValueLabel.frame = CGRect(x: minDotCenter.x + 8 - 40, y: minDotCenter.y + 30, width: 40, height: 20)
        
        // Max Value Label
        if maxValueLabel.superview == nil {
            addSubview(maxValueLabel)
        }
        maxValueLabel.text = String(format: "%.0f", maxValue)
        maxValueLabel.font = Constants.Fonts.minMaxValueFont
        maxValueLabel.minimumScaleFactor = 10 / Constants.Fonts.minMaxValueFont.pointSize
        maxValueLabel.textColor = .black
        let maxDotCenter = CGPoint(x: CGFloat(dotRadius * cos(endAngle)) + center.x,
                                   y: CGFloat(dotRadius * sin(endAngle)) + center.y)
        maxValueLabel.frame = CGRect(x: maxDotCenter.x - 8, y: maxDotCenter.y + 30, width: 40, height: 20)
    }
    
    public func strokeSpeedometer() {
        setNeedsDisplay()
        let progress = maxValue != 0 ? (value - minValue) / (maxValue - minValue) : 0
        progressLayer.strokeEnd = CGFloat(progress)
        
        let ringColor = Constants.Colors.ringStrokeColor

        progressLayer.strokeColor = ringColor.cgColor
    }
}

extension SpeedometerView {
    func angleFromValue(_ value: Double) -> Double {
        let level = divisionUnitValue != 0 ? (value - minValue) / divisionUnitValue : 0
        let angle = level * divisionUnitAngle + startAngle
        return angle
    }
}
