//
//  AddButton.swift
//  Car List
//
//  Created by Alex on 17.09.16.
//  Copyright © 2016 Alex Vydrin. All rights reserved.
//

import UIKit

class AddButton: UIButton {
    
    init (color: UIColor) {
        super.init(frame: CGRectZero)
        
        let button = UIButton(type: .ContactAdd)
        button.layer.cornerRadius = button.bounds.width/2
        button.layer.masksToBounds = true
        button.tintColor = color
        button.backgroundColor = .whiteColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(type buttonType: UIButtonType) {
        self.init(type: buttonType)
        // assign your custom property
    }
    
    
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
