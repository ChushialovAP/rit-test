import UIKit

extension CGContext {
    
    func drawDot(center: CGPoint, radius: Double, fillColor: UIColor) {
        beginPath()
        addArc(center: center,
               radius: CGFloat(radius),
               startAngle: 0,
               endAngle: .pi * 2,
               clockwise: false)
        setFillColor(fillColor.cgColor)
        fillPath()
    }
}
