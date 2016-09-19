//
//  NewCarTableViewController.swift
//  Car List
//
//  Created by Alex on 14.09.16.
//  Copyright © 2016 Alex Vydrin. All rights reserved.
//

import UIKit
import ImagePicker
import CoreData
import ImageSlideshow

class NewCarTableViewController: UITableViewController {
    
    var context = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    let engine = [NSLocalizedString("CHOOSE", comment: "Choose value in pickerview"), "1.4", "1.5","1.6", "1.8", "2.0"]
    let transmission = [NSLocalizedString("CHOOSE", comment: "Choose value in pickerview"), NSLocalizedString("MANUAL", comment: "Manual car transmission"), NSLocalizedString("AUTO", comment: "Auto car transmission"), NSLocalizedString("TIPTRONIC", comment: "Tiptronic car transmission"), NSLocalizedString("ROBOTIC", comment: "Robotic car transmission")]
    let condition = [NSLocalizedString("CHOOSE", comment: "Choose value in pickerview"), NSLocalizedString("GOOD", comment: "Good"), NSLocalizedString("NORMAL", comment: "Normal"), NSLocalizedString("REPAIR", comment: "Needs repairs"), NSLocalizedString("PARTS", comment: "For parts")]
    var carInfo = [String:String]()
    let pickerView = UIPickerView()
    var slideshow: ImageSlideshow?
    var slideshowTransitioningDelegate: ZoomAnimatedTransitioningDelegate?
    private var images = [UIImage]() {
        didSet {
            fillScrollView ()
        }
    }
    
    @IBOutlet var carPriceTextField: UITextField! {
        didSet {
            carPriceTextField.delegate = self
        }
    }
    
    @IBOutlet var carModelTexField: UITextField! {
        didSet {
            carModelTexField.delegate = self
        }
    }
    
    @IBOutlet var carDescriptionTextView: UITextView! {
        didSet {
            carDescriptionTextView.delegate = self
        }
    }

    @IBOutlet var photoScrollView: UIScrollView!
    @IBOutlet var engineTextField: UITextField!
    @IBOutlet var transmissionTextField: UITextField!
    @IBOutlet var conditionTextField: UITextField!
    @IBOutlet var rightButtonScroll: UIButton!
    @IBOutlet var leftButtonScroll: UIButton!
    @IBOutlet var addCarButton: UIBarButtonItem!
    
    private struct Constants {
        static let spaceBetweenImages: CGFloat = 5
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPicker()
        fillScrollView()
        setupButtons()
        slideshow = ImageSlideshow(frame: view.frame)
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(NewCarTableViewController.showSelected))
        slideshow!.addGestureRecognizer(recognizer)
        carDescriptionTextView.text = NSLocalizedString("START_TYPING", comment: "Begin typing")
    }
    
    @IBAction func addCarPressed(sender: UIBarButtonItem) {
        guard fieldsAreFilled() else {
            let alert = UIAlertController(title: NSLocalizedString("OOPS", comment: "Something went wrong"), message: NSLocalizedString("FIIL_FIELDS", comment: "Please, fill all fields"), preferredStyle: .Alert)
            let action = UIAlertAction(title: NSLocalizedString("OK", comment: "Ok"), style: .Default, handler: nil)
            alert.addAction(action)
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        createRecord()
        navigationController?.popViewControllerAnimated(true)
    }
    
    private func createRecord() {
        carInfo["model"] = carModelTexField.text
        carInfo["price"] = carPriceTextField.text! + "$"
        carInfo["engine"] = engineTextField.text
        carInfo["transmission"] = transmissionTextField.text
        carInfo["condition"] = conditionTextField.text
        carInfo["description"] = carDescriptionTextView.text.hasPrefix(NSLocalizedString("START_TYPING", comment: "Begin typing")) ? "" : carDescriptionTextView.text // Checks if there is a description.
        Car.createRecordFrom(carInfo, images: images, inManagedObjectContext: context!)
    }
    
    @objc private func addImages () {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    private func fillScrollView () {
        let width = self.view.frame.width/4
        let height = photoScrollView.frame.height
        
        photoScrollView.subviews.forEach{ $0.removeFromSuperview() }
        
        if !images.isEmpty {
            for (index, image) in images.enumerate() {
                let imageView = UIImageView(frame: CGRect(x: CGFloat(index) * (width + Constants.spaceBetweenImages), y: 0, width: width, height: height))
                imageView.contentMode = .ScaleAspectFill
                imageView.layer.masksToBounds = true
                imageView.image = image
                photoScrollView.addSubview(imageView)
            }
        }
        
        let frame = CGRect(x: CGFloat(images.count) * (width + Constants.spaceBetweenImages), y: 0, width: width, height: height)
        let button = UIButton(frame: frame)
        let addButton = UIButton.initAddButton(navigationController!.navigationBar.barTintColor!)
        addButton.center = CGPoint(x: button.bounds.width/2, y: button.bounds.height/2)
        addButton.addTarget(self, action: #selector (NewCarTableViewController.addImages), forControlEvents: .TouchUpInside)
        button.addSubview(addButton)
        button.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        button.addTarget(self, action: #selector (NewCarTableViewController.addImages), forControlEvents: .TouchUpInside)
        photoScrollView.addSubview(button)
        let contentWidth = CGFloat(images.count+1) * (width + Constants.spaceBetweenImages)
        photoScrollView.contentSize = CGSizeMake(contentWidth, photoScrollView.frame.height)
    }
    
    @IBAction func scrollImages(sender: UIButton) {
        let x = photoScrollView.contentSize.width - photoScrollView.frame.width
        // If there is something to scroll - move to the right or left end of scroll view.
        if x > 0 {
            switch sender.tag {
            case 0:
                photoScrollView.setContentOffset(CGPointMake(0, 0), animated: true)
            case 1:
                photoScrollView.setContentOffset(CGPointMake(x, 0), animated: true)
            default:
                break
            }
        }
    }
    
    func showSelected() {
        let fullScreenVC = FullScreenSlideshowViewController()
        fullScreenVC.pageSelected = {(page: Int) in
            self.slideshow!.setScrollViewPage(page, animated: false)
        }
        
        fullScreenVC.initialImageIndex = slideshow!.scrollViewPage
        fullScreenVC.inputs = slideshow!.images
        slideshowTransitioningDelegate = ZoomAnimatedTransitioningDelegate(slideshowView: slideshow!, slideshowController: fullScreenVC)
        fullScreenVC.transitioningDelegate = slideshowTransitioningDelegate
        navigationController?.viewControllers.count
        if let presented = (UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController!.presentedViewController {
            presented.presentViewController(fullScreenVC, animated: true, completion: nil)
        }
    }
    
    private func setupButtons() {
        rightButtonScroll.alpha = 0.6
        leftButtonScroll.alpha = 0.6
        addCarButton.setTitleTextAttributes([ NSFontAttributeName: UIFont.systemFontOfSize(30, weight: UIFontWeightMedium)], forState: .Normal)
    }
    
    private func setupPicker() {
        pickerView.delegate = self
        pickerView.backgroundColor = .whiteColor()

        let toolBar = UIToolbar()
        toolBar.barStyle = .Black
        toolBar.tintColor = .whiteColor()
        toolBar.backgroundColor = UIColor(red: 122/255, green: 184/255, blue: 2228/255, alpha: 1)
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: NSLocalizedString("OK", comment: "Ok"), style: .Plain, target: self, action: #selector(NewCarTableViewController.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        engineTextField.inputView = pickerView
        engineTextField.tag = 0
        engineTextField.delegate = self
        engineTextField.inputAccessoryView = toolBar
        
        transmissionTextField.inputView = pickerView
        transmissionTextField.tag = 1
        transmissionTextField.delegate = self
        transmissionTextField.inputAccessoryView = toolBar
        
        conditionTextField.inputView = pickerView
        conditionTextField.tag = 2
        conditionTextField.delegate = self
        conditionTextField.inputAccessoryView = toolBar
    }
    
    @objc private func donePicker () {
        if engineTextField.isFirstResponder() {
            engineTextField.resignFirstResponder()
        } else if transmissionTextField.isFirstResponder() {
            transmissionTextField.resignFirstResponder()
        } else {
            conditionTextField.resignFirstResponder()
        }
    }
    
    private func fieldsAreFilled () -> Bool {
        return carModelTexField.text != NSLocalizedString("CHOOSE", comment: "Choose value in pickerview") &&
        transmissionTextField.text != NSLocalizedString("CHOOSE", comment: "Choose value in pickerview") &&
        conditionTextField.text != NSLocalizedString("CHOOSE", comment: "Choose value in pickerview") &&
        carPriceTextField.text != "" &&
        carModelTexField.text != ""
    }
    
    private enum TextField: Int {
        case Engine = 0,
        Transmission,
        Condition
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.first != nil {
            dismissKeyboard()
        }
        super.touchesBegan(touches, withEvent:event)
        
    }
    
    func dismissKeyboard() {
        resignFirstResponder()
        self.view.endEditing(true)
    }

}

extension NewCarTableViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if carDescriptionTextView.text.hasPrefix(NSLocalizedString("START_TYPING", comment: "Begin typing")) {
            carDescriptionTextView.text = ""
        }
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if carDescriptionTextView.text == "" {
            carDescriptionTextView.text = NSLocalizedString("START_TYPING", comment: "Begin typing")
        }
    }
}

extension NewCarTableViewController: ImagePickerDelegate {
    func wrapperDidPress(images: [UIImage]) {
        guard images.count > 0 else {return}
        let inputs = images.map{ ImageSource(image: $0) }
        slideshow!.setImageInputs(inputs)
        showSelected()
    }
    func doneButtonDidPress(images: [UIImage]) {
        self.images.appendContentsOf(images)
        dismissViewControllerAnimated(true, completion: nil)
    }
    func cancelButtonDidPress() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension NewCarTableViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
   
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if engineTextField.isFirstResponder() {
            return engine.count
        } else if transmissionTextField.isFirstResponder() {
            return transmission.count
        } else {
            return condition.count
        }
        
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if engineTextField.isFirstResponder() {
            return engine[row]
        } else if transmissionTextField.isFirstResponder() {
            return transmission[row]
        } else {
            return condition[row]
        }

    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if engineTextField.isFirstResponder() {
            engineTextField.text = engine[row]
        } else if transmissionTextField.isFirstResponder() {
            transmissionTextField.text = transmission[row]
        } else {
            conditionTextField.text = condition[row]
        }
    }
}


extension NewCarTableViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        pickerView.reloadAllComponents()
        switch textField.tag {
        case TextField.Engine.rawValue:
            let row = engine.indexOf(engineTextField.text ?? "") ?? 0
            pickerView.selectRow(row, inComponent: 0, animated: true)
        case TextField.Transmission.rawValue:
            let row = transmission.indexOf(transmissionTextField.text ?? "") ?? 0
            pickerView.selectRow(row, inComponent: 0, animated: true)
        case TextField.Condition.rawValue:
            let row = condition.indexOf(conditionTextField.text ?? "") ?? 0
            pickerView.selectRow(row, inComponent: 0, animated: true)
        default:
            break
        }   
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}


