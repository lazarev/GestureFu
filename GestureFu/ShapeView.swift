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
}