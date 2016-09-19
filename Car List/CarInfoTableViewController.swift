//
//  CarInfoTableViewController.swift
//  Car List
//
//  Created by Alex on 17.09.16.
//  Copyright © 2016 Alex Vydrin. All rights reserved.
//

import UIKit

class CarInfoTableViewController: UITableViewController {
    var managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
 
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var engineLabel: UILabel!
    @IBOutlet weak var transmissionLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var descriptionLabel: UILabel!
     
    
    var images: [UIImage]!
    var car: Car? {
        didSet {
            images = Images.getImagesFor(car!, inManagedObjectContext: managedObjectContext!) ?? [UIImage(named: "no car")!]
            if images.isEmpty {images.append(UIImage(named: "no car")!)}
        }
    }
    
    private enum Row: Int {
        case Photo = 0,
        Model = 1,
        Description = 5
    }
    
    private struct Constants {
        static let PhotoRowHeight: CGFloat = 250
        static let ModelRowHeight: CGFloat = 50
        static let CarDetailsRowHeight: CGFloat = 30
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabels()
        setupScrollView ()
        navigationItem.title = car?.model
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    
    @IBAction func slideImage(sender: UIButton) {
        if sender.tag == 0 && pageControl.currentPage != 0 {
            pageControl.currentPage = pageControl.currentPage-1
            changePage()
        } else if sender.tag == 1 && pageControl.currentPage != images.count-1 {
            pageControl.currentPage = pageControl.currentPage+1
            changePage()
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
        case Row.Photo.rawValue:
            return Constants.PhotoRowHeight
        case Row.Model.rawValue:
            return Constants.ModelRowHeight
        case Row.Description.rawValue:
            return UITableViewAutomaticDimension
        default:
            return Constants.CarDetailsRowHeight
        }
    }
    
    func setupScrollView () {
        let width = UIScreen.mainScreen().bounds.width
        for (index, image) in images.enumerate() {
            let x = width * CGFloat(index)
            let imageView = UIImageView(frame: CGRect(x: x, y: 0, width: width, height: scrollView.frame.height))
            imageView.image = image
            imageView.contentMode = .ScaleAspectFill
            scrollView.addSubview(imageView)
        }
        scrollView.contentSize = CGSizeMake(width * CGFloat(images.count), scrollView.frame.size.height)

        pageControl.numberOfPages = images.count
        pageControl.currentPage = 0
        pageControl.addTarget(self, action: #selector(CarInfoTableViewController.changePage), forControlEvents: .ValueChanged)
    }
    
    func changePage() {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPointMake(x, 0), animated: true)
    }
    
    func setupLabels() {
        guard car != nil else {return}
        conditionLabel.text = car!.condition
        engineLabel.text = car!.engine
        transmissionLabel.text = car!.transmission
        priceLabel.text = car!.price
        modelLabel.text = car!.model
        descriptionLabel.text = car!.carDescription
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
}
