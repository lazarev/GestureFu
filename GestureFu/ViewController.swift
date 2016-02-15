//
//  ViewController.swift
//  GestureFu
//
//  Created by Андрей Лазарев on 13/02/16.
//  Copyright © 2016 APPGRANULA. All rights reserved.
//

import UIKit
import Chameleon

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var viewDraw : ShapeView?
    @IBOutlet var viewCanvas : UIView?
    @IBOutlet var viewConnectors : UIView?
    @IBOutlet var viewAnimation : ShapeView?
    
    var currentPath : UIBezierPath?
    var startPoint : CGPoint?
    var endPoint : CGPoint?

    var standardPaths : [UIBezierPath!] {
        let square = UIBezierPath();
        square.moveToPoint(CGPoint(x: 0, y: 0))
        square.addLineToPoint(CGPoint(x: 100, y: 0))
        square.addLineToPoint(CGPoint(x: 100, y: 100))
        square.addLineToPoint(CGPoint(x: 0, y: 100))
        square.addLineToPoint(CGPoint(x: 0, y: 0))
        square.closePath()

        let triangle = UIBezierPath();
        triangle.moveToPoint(CGPoint(x: 50, y: 0))
        triangle.addLineToPoint(CGPoint(x: 100, y: 100))
        triangle.addLineToPoint(CGPoint(x: 50, y: 100))
        triangle.addLineToPoint(CGPoint(x: 0, y: 100))
        triangle.addLineToPoint(CGPoint(x: 50, y: 0))
        triangle.closePath()
        
        let circle = UIBezierPath()
        circle.addArcWithCenter(CGPoint(x: 50, y: 50), radius: 50, startAngle: 0, endAngle: 4*CGFloat(M_PI_2), clockwise: true)
        circle.closePath()

        return [square, circle, triangle]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewDraw?.shapeLayer.path        = self.currentPath?.CGPath
        self.viewDraw?.shapeLayer.strokeColor = UIColor.flatRedColor().colorWithAlphaComponent(0.5).CGColor
        self.viewDraw?.shapeLayer.fillColor   = UIColor.clearColor().CGColor
        self.viewDraw?.shapeLayer.lineWidth   = 4;
    }
    
    @IBAction func handlePan (recognizer: UIPanGestureRecognizer) -> Void {
        switch recognizer.state {
        case .Began:
            self.startPath(recognizer.locationInView(self.view))
        case .Changed:
            self.moveToPoint(recognizer.locationInView(self.view))
        case .Ended:
            self.endPath(recognizer.locationInView(self.view))
        case .Cancelled:
            self.cancelPath()
        default:
            return;
        }
    }
    
    func startPath(point: CGPoint) {
        self.startPoint = point
        self.currentPath = UIBezierPath()
        self.currentPath!.moveToPoint(point)
    }
    
    func moveToPoint(point: CGPoint) {
        self.currentPath!.addLineToPoint(point)
        self.viewDraw?.shapeLayer.path = self.currentPath?.CGPath
    }
    
    func endPath(point: CGPoint) {
        if let path = self.standardPathForGesturePath(self.currentPath!) {
            let view = ShapeView()
            view.shapeLayer.path        = path.CGPath
            view.shapeLayer.strokeColor = UIColor.randomFlatColor().CGColor
            view.shapeLayer.fillColor   = UIColor.clearColor().CGColor
            view.shapeLayer.lineWidth   = 6;
            self.viewCanvas!.addSubview(view)
        } else {
            let start = self.startPoint!
            let end = point
            
            var startView : ShapeView?
            var endView : ShapeView?
            
            for subView in (self.viewCanvas?.subviews)! {
                if let layerView = subView as? ShapeView {
                    if startView == nil {
                        if CGPathContainsPoint(layerView.shapeLayer.path, nil, start, false) {
                            startView = layerView
                        }
                    }
                    if endView == nil {
                        if  CGPathContainsPoint(layerView.shapeLayer.path, nil, end, false) {
                            endView = layerView
                        }
                    }
                }
            }
            
            if startView != nil && endView != nil {
                self.addConnector(startView, to: endView)
            }
        }
        
        self.currentPath = nil
        self.viewDraw?.shapeLayer.path = nil
    }
    
    func addConnector(from: ShapeView!, to: ShapeView!) {
        let path = UIBezierPath()
        
        let startFrame = CGPathGetBoundingBox(from.shapeLayer.path)
        let startPoint = CGPoint(x:CGRectGetMidX(startFrame), y:CGRectGetMidY(startFrame))
        
        let endFrame = CGPathGetBoundingBox(to.shapeLayer.path)
        let endPoint = CGPoint(x:CGRectGetMidX(endFrame), y:CGRectGetMidY(endFrame))
        
        path.moveToPoint(startPoint)
        path.addLineToPoint(endPoint)
        
        let view  = ConnectorView()
        view.from = from
        view.to   = to
        view.shapeLayer.path        = path.CGPath
        view.shapeLayer.strokeColor = UIColor.randomFlatColor().CGColor
        view.shapeLayer.fillColor   = UIColor.clearColor().CGColor
        view.shapeLayer.lineWidth   = 2;
        self.viewConnectors!.addSubview(view)
    }
    
    func cancelPath() {
        self.currentPath = nil
        self.viewDraw?.shapeLayer.path = nil
    }
    
    func standardPathForGesturePath(path: UIBezierPath!) -> UIBezierPath? {

        var bestStandard : UIBezierPath? = nil
        var bestScore = 0.0
        
        for standard in self.standardPaths {
            let score = standard.compreForms(path)
            if (bestScore < score) {
                bestScore    = score
                bestStandard = standard
            }
        }

        if (bestScore < 0.80) {
            return nil
        }

        bestStandard!.alignToPath(path);
        return bestStandard!
    }
    
    @IBAction func handleTap (recognizer: UITapGestureRecognizer) -> Void {
        let point = recognizer.locationInView(self.view)
        for subView in (self.viewConnectors?.subviews)! {
            if let layerView = subView as? ConnectorView {
                let shapeLayer = layerView.shapeLayer
                let path       = shapeLayer.path
                let testPath   = CGPathCreateCopyByStrokingPath(path, nil, 35.0, UIBezierPath().lineCapStyle, UIBezierPath().lineJoinStyle, UIBezierPath().miterLimit)
                let tapTarget = UIBezierPath(CGPath: testPath!)
                if(tapTarget.containsPoint(point)) {
                    self.onTapConnector(layerView)
                }
            }
        }
    }
    
    func onTapConnector(connector: ConnectorView) {
        let fromPath = connector.from?.shapeLayer.path!;
        let toPath   = connector.to?.shapeLayer.path!;

        self.viewAnimation?.shapeLayer.removeAllAnimations()
        self.viewAnimation?.shapeLayer.lineWidth   = 2;
        self.viewAnimation?.shapeLayer.strokeColor = UIColor.randomFlatColor().CGColor
        self.viewAnimation?.shapeLayer.fillColor   = UIColor.clearColor().CGColor
        self.viewAnimation?.shapeLayer.lineWidth   = 6;

        let animation         = CABasicAnimation(keyPath: "path")
        animation.duration    = 1
        animation.fromValue   = fromPath
        animation.toValue     = toPath
        animation.repeatCount = 1
        
        self.viewAnimation?.shapeLayer.addAnimation(animation, forKey: "path")
    }
}

extension UIBezierPath {
    func alignToPath(path: UIBezierPath!) -> Void {
        let frame = CGPathGetBoundingBox(path.CGPath)
        
        let ratioX = frame.size.width/self.bounds.size.width;
        let ratioY = frame.height/self.bounds.size.height;
        
        let scale = CGAffineTransformMakeScale(ratioX, ratioY)
        self.applyTransform(scale)
        
        let selfFrame = CGPathGetBoundingBox(self.CGPath)
        let shift = CGAffineTransformMakeTranslation(frame.minX - selfFrame.minX, frame.minY - selfFrame.minY)
        self.applyTransform(shift)
    }
    
    func compreForms(path: UIBezierPath!) -> Double {
        let alignedPath = path.copy();
        alignedPath.closePath()
        alignedPath.alignToPath(self)
        
        let frame = CGPathGetBoundingBox(self.CGPath)
        var hit = 0
        let total = 1000
        for _ in 1...total {
            let x = frame.origin.x + CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * frame.size.width
            let y = frame.origin.y + CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * frame.size.height
            let point = CGPoint(x: x, y: y)
            if self.containsPoint(point) == alignedPath.containsPoint(point) {
                hit++;
            }
        }
        let score = Double(hit)/Double(total)
        print("Score: \(score)")
        return score
    }
}
