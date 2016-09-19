//
//  MainTableViewController.swift
//  Car List
//
//  Created by Alex on 14.09.16.
//  Copyright © 2016 Alex Vydrin. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class MainTableViewController: UITableViewController {
   
    var managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    var fetchedResultsController: NSFetchedResultsController? {
        didSet {
            do {
                if let frc = fetchedResultsController {
                    frc.delegate = self
                    try frc.performFetch()
                }
                tableView.reloadData()
            } catch let error {
                print("NSFetchedResultsController.performFetch() failed: \(error)")
            }
        }
    }
    let weatherHeader = WeatherView.instanceFromNib()
    let locationManager = CLLocationManager()
    var carToShow: Car?
    var currentLocation: CLLocation? {
        didSet {
            loadWeather()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addButton = UIButton.initAddButton(navigationController!.navigationBar.barTintColor!)
        addButton.addTarget(self, action: #selector (MainTableViewController.addCarPressed), forControlEvents: .TouchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        setupLCManager()
        loadWeather()
    }
    
    func loadWeather() {
        let weather = WeatherManager().getCurrentWeather(currentLocation) { (result) in
            self.weatherHeader.updateWeather(result)
            self.tableView.reloadData()
        }
        weatherHeader.updateWeather(weather)
    }
    
    func addCarPressed () {
        performSegueWithIdentifier(Constants.SegueToAddCar, sender: nil)
    }
    
    func setupLCManager () {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillAppear(animated: Bool) {
        updateUI()
    }
    
    private func updateUI() {
        let request = NSFetchRequest(entityName: "Car")
        request.sortDescriptors = [NSSortDescriptor(
            key: "model",
            ascending: true,
            selector: nil
            )]
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: managedObjectContext!,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
    
    private struct Constants {
        static let HeighForWeatherHeader: CGFloat = 220
        static let HeighForCarRow: CGFloat = 75
        static let CarCellIdentifier = "carCell"
        static let WeatherCellIdentifier = "weatherCell"
        static let SegueToAddCar = "mainToAddCarSegue"
        static let SegueToCarInfo = "mainToCarInfoSegue"
    }
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections where sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 1
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return carCell(indexPath)
    }
    
    private func carCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CarCellIdentifier) as! CarCell
        if let car = fetchedResultsController?.objectAtIndexPath(indexPath) as? Car {
            cell.nameLabel.text = car.model ?? ""
            cell.priceLabel.text = car.price ?? ""
            let image = Images.getImagesFor(car, inManagedObjectContext: managedObjectContext!)?.first ?? UIImage(named: "no car")
            cell.carPhotoView.image = image
        }
        cell.carPhotoView.contentMode = .ScaleAspectFill
        cell.carPhotoView.layer.masksToBounds = true
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Constants.HeighForCarRow
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.HeighForWeatherHeader
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return weatherHeader
    }
    

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            managedObjectContext?.performBlock{
                self.managedObjectContext!.deleteObject(self.fetchedResultsController?.objectAtIndexPath(indexPath) as! NSManagedObject)
                do {
                    try self.managedObjectContext!.save()
                } catch let error {
                    print ("Core Data Error: \(error)")
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let car = fetchedResultsController?.objectAtIndexPath(indexPath) as? Car {
            carToShow = car
        }
        performSegueWithIdentifier(Constants.SegueToCarInfo, sender: nil)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let infoVC = segue.destinationViewController as? CarInfoTableViewController {
            infoVC.car = carToShow
        }
    }
}

extension MainTableViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if currentLocation == nil {
            currentLocation = locations.last
        }
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - NSFetchedResults delegate
extension MainTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert: tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete: tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default: break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }

}

class CarCell: UITableViewCell {
    @IBOutlet var carPhotoView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
}