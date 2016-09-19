//
//  BottomLinedTableViewCell.swift
//  Car List
//
//  Created by Alex on 15.09.16.
//  Copyright © 2016 Alex Vydrin. All rights reserved.
//

import UIKit
import CoreData

extension UITableViewCell {
    func addBottomLine (width: CGFloat) {
        let frame = CGRectMake(0, self.frame.maxY-1, width, 1)
        let view = UIView(frame: frame)
        view.backgroundColor = UIColor.whiteColor()
        self.addSubview(view)
    }
}

extension NSManagedObject {
    func saveDataBase() {
        do {
            try self.managedObjectContext!.save()
        } catch let error {
            print ("Core Data Error: \(error)")
        }
    }
}

extension UIButton {
    
    class func initAddButton (color: UIColor) -> UIButton {
        let button = UIButton(type: .ContactAdd)
        button.layer.cornerRadius = button.bounds.width/2
        button.layer.masksToBounds = true
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.whiteColor().CGColor
        button.tintColor = color
        button.backgroundColor = .whiteColor()
        return button
    }
    

}
