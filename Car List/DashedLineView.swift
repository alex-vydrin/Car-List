//
//  DashedLineView.swift
//  Car List
//
//  Created by Alex on 14.09.16.
//  Copyright © 2016 Alex Vydrin. All rights reserved.
//

import UIKit

class DashedLineView: UIView {

    var lineLength: CGFloat = 10
    var lineWidth: CGFloat = 20
    var lineSpace: CGFloat = 10
    var posX: CGFloat = 0
    var posY: CGFloat = 0
    let lineColor = UIColor.whiteColor()
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        checkLineOrientation(rect)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(context, lineColor.CGColor)
        CGContextSetLineWidth(context, lineWidth)
        
        let lines = [CGPointMake(0, 0), CGPointMake(posX, posY)]
        let pattern: [CGFloat] = [lineLength, lineSpace]
        
        CGContextSetLineDash(context, 2, pattern, 2);
        CGContextAddLines(context, lines, 2)
        CGContextStrokePath(context)
    }
    
    // Horizontal or vertical line position
    func checkLineOrientation(rect: CGRect) {
        if rect.width > rect.height {
            lineWidth = rect.height
            posX = rect.width
            posY = 0
        } else {
            lineWidth = rect.width
            posX = 0
            posY = rect.height
        }
    }

}
