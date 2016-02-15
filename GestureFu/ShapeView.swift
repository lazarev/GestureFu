//
//  ShapeView.swift
//  GestureFu
//
//  Created by Андрей Лазарев on 13/02/16.
//  Copyright © 2016 APPGRANULA. All rights reserved.
//

import UIKit
import QuartzCore

class ShapeView : UIView {
    static override func layerClass() -> AnyClass {
        return CAShapeLayer.self
    }
    
    var shapeLayer : CAShapeLayer {
        return self.layer as! CAShapeLayer
    }
    
//    override func didMoveToWindow() {
//        let layer = self.layer as! CAShapeLayer
//        
//        layer.strokeColor = UIColor.redColor().CGColor
//        layer.lineWidth = 4
//        layer.fillColor = UIColor.clearColor().CGColor
//
//        let square = UIBezierPath();
//        square.moveToPoint(CGPoint(x: 200, y: 200))
//        square.addLineToPoint(CGPoint(x: 300, y: 200))
//        square.addLineToPoint(CGPoint(x: 300, y: 300))
//        square.addLineToPoint(CGPoint(x: 200, y: 300))
//        square.addLineToPoint(CGPoint(x: 200, y: 200))
//        
//        let center = CGPoint(x: 60, y: 60)
//        
//        let circle = UIBezierPath()
//        circle.addArcWithCenter(center, radius: 50, startAngle: 2*CGFloat(M_PI_2), endAngle: 6*CGFloat(M_PI_2), clockwise: true)
//
//        let animation = CABasicAnimation(keyPath: "path")
//        animation.duration    = 5
//        animation.fromValue   = circle.CGPath
//        animation.toValue     = square.CGPath
//        animation.repeatCount = 10
//        
//        self.layer.addAnimation(animation, forKey: "path")
//    }
}