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

        let triangle = UIBezierPath();
        triangle.moveToPoint(CGPoint(x: 50, y: 0))
        triangle.addLineToPoint(CGPoint(x: 100, y: 100))
        triangle.addLineToPoint(CGPoint(x: 0, y: 100))
        triangle.addLineToPoint(CGPoint(x: 50, y: 0))
        
        let circle = UIBezierPath()
        circle.addArcWithCenter(CGPoint(x: 50, y: 50), radius: 50, startAngle: 0, endAngle: 4*CGFloat(M_PI_2), clockwise: true)

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
    
    func endPath(endPoint: CGPoint) {
        let view = ShapeView()
        var path = self.standardPathForGesturePath(self.currentPath!)
        
        if path == nil {
            path = UIBezierPath()
            path?.moveToPoint(self.startPoint!)
            path?.addLineToPoint(endPoint)
        }

        view.shapeLayer.path        = path!.CGPath
        view.shapeLayer.strokeColor = UIColor.randomFlatColor().CGColor
        view.shapeLayer.fillColor   = UIColor.clearColor().CGColor
        view.shapeLayer.lineWidth   = 2;
        self.viewCanvas!.addSubview(view)
        
        self.currentPath = nil
        self.viewDraw?.shapeLayer.path = nil
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
                bestScore = score
                bestStandard = standard
            }
        }

        if (bestScore < 0.85) {
            return nil
        }

        bestStandard!.alignToPath(path);
        return bestStandard!
    }
    
}

extension UIBezierPath {
    func alignToPath(path: UIBezierPath!) -> Void {
        let frame = CGPathGetBoundingBox(path.CGPath)
//        let ratio = min(frame.size.width/self.bounds.size.width,
//            frame.height/self.bounds.size.height)
        
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
