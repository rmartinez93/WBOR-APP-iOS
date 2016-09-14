//
//  RMShapedImageView.swift
//  RMShapedImageView
//
//  Created by Ruben Martinez Jr. on 2/13/16.
//  Copyright © 2016 Robot Media. All rights reserved.
//

import UIKit
import CoreGraphics

open class RMShapedImageView: UIImageView {
    //public
    open var shapedPixelTolerance: CGFloat = 0
    open var shapedTransparentMaxAlpha: CGFloat = 0
    
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
    
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let superResult = super.point(inside: point, with: event)
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
            if point.equalTo(previousPoint) {
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
    
    override open var image: UIImage? {
        didSet {
            self.resetPointInsideCache()
        }
    }
    
    open func isShapeSupported() -> Bool {
        if self.image == nil {
            return true
        }
        
        switch self.contentMode {
        case UIViewContentMode.scaleToFill:
            return true
        case UIViewContentMode.topLeft:
            return true
        default:
            return false
        }
    }
    
    
    //private
    func imagePointFromViewPoint(_ viewPoint: CGPoint) -> CGPoint {
        var imagePoint = viewPoint
        
        if self.contentMode == UIViewContentMode.scaleToFill {
            let imageSize = self.image!.size
            let boundsSize = self.bounds.size
            imagePoint.x *= (boundsSize.width != 0)  ? (imageSize.width / boundsSize.width)   : 1
            imagePoint.y *= (boundsSize.height != 0) ? (imageSize.height / boundsSize.height) : 1
        }
        
        return imagePoint
    }
    
    func isAlphaVisibleAtImagePoint(_ point: CGPoint) -> Bool {
        var pixel: [UInt8] = [0, 0, 0, 0];
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        let alphaInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue);
        let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: alphaInfo.rawValue);
        
        context?.translateBy(x: -point.x, y: -point.y);
        context?.draw(self.image!.cgImage!, in: CGRect(x: 0, y: 0, width: self.image!.size.width, height: self.image!.size.height))
        
        let floatAlpha = CGFloat(pixel[3]);
        return floatAlpha > 0.0;
    }
    
    func resetPointInsideCache() {
        _previousPoint = nil;
        _previousPointInsideResult = nil;
    }
}
