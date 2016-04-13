//
//  RMShapedImageView.swift
//  RMShapedImageView
//
//  Created by Ruben Martinez Jr. on 2/13/16.
//  Copyright © 2016 Robot Media. All rights reserved.
//

import UIKit
import CoreGraphics

public class RMShapedImageView: UIImageView {
    //public
    public var shapedPixelTolerance: CGFloat = 0
    public var shapedTransparentMaxAlpha: CGFloat = 0
    
    //private
    var _previousPoint: CGPoint?
    var _previousPointInsideResult: Bool?
    
    //public
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override public func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let superResult = super.pointInside(point, withEvent: event)
        if !superResult {
            return false
        }
        if !isShapeSupported() {
            return superResult
        }
        if self.image == nil {
            return false
        }
        if let previousPoint = _previousPoint {
            if CGPointEqualToPoint(point, previousPoint) {
                return _previousPointInsideResult!
            }
        }
        
        //calculate & cache new data
        _previousPoint = point
        let imagePoint = self.imagePointFromViewPoint(point)
        
        let result = self.isAlphaVisibleAtImagePoint(imagePoint)
        _previousPointInsideResult = result
        
        return result
    }
    
    override public var image: UIImage? {
        didSet {
            self.resetPointInsideCache()
        }
    }
    
    public func isShapeSupported() -> Bool {
        if self.image == nil {
            return true
        }
        
        switch self.contentMode {
        case UIViewContentMode.ScaleToFill:
            return true
        case UIViewContentMode.TopLeft:
            return true
        default:
            return false
        }
    }
    
    
    //private
    func imagePointFromViewPoint(viewPoint: CGPoint) -> CGPoint {
        var imagePoint = viewPoint
        
        if self.contentMode == UIViewContentMode.ScaleToFill {
            let imageSize = self.image!.size
            let boundsSize = self.bounds.size
            imagePoint.x *= (boundsSize.width != 0)  ? (imageSize.width / boundsSize.width)   : 1
            imagePoint.y *= (boundsSize.height != 0) ? (imageSize.height / boundsSize.height) : 1
        }
        
        return imagePoint
    }
    
    func isAlphaVisibleAtImagePoint(point: CGPoint) -> Bool {
        let imageRect = CGRect(x: 0, y: 0, width: self.image!.size.width, height: self.image!.size.height)
        let pointRectWidth = self.shapedPixelTolerance * 2 + 1
        let pointRect = CGRect(x: point.x - self.shapedPixelTolerance, y: point.y - self.shapedPixelTolerance, width: pointRectWidth, height: pointRectWidth)
        let queryRect = CGRectIntersection(imageRect, pointRect)
        
        //point not in image
        if CGRectIsNull(queryRect) {
            return false
        }
        
        let querySize = queryRect.size
        let bytesPerPixel = 4
        let bitsPerComponent = 8
        let pixelCount = Int(querySize.width * querySize.height);
        let data = malloc(bytesPerPixel * pixelCount)
        let context = CGBitmapContextCreate(data, Int(querySize.width), Int(querySize.height), bitsPerComponent, bytesPerPixel * Int(querySize.width), nil, CGImageAlphaInfo.Only.rawValue)
        
        if context == nil {
            return false
        }
        
        CGContextSetBlendMode(context, CGBlendMode.Copy)
        CGContextTranslateCTM(context, -queryRect.origin.x, queryRect.origin.y-self.image!.size.height)
        CGContextDrawImage(context, CGRect(x: 0, y: 0, width: self.image!.size.width, height: self.image!.size.height), self.image!.CGImage)
        
        let dataType = UnsafePointer<UInt8>(data)
        for i in 0 ..< pixelCount {
            let alphaChar = CGFloat(dataType[i])
            let alpha = alphaChar / 255.0;
            if alpha > self.shapedTransparentMaxAlpha {
                return true;
            }
        }
        
        return false
    }
    
    func resetPointInsideCache() {
        _previousPoint = nil;
        _previousPointInsideResult = nil;
    }
}