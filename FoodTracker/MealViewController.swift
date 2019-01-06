//
//  MealViewController.swift
//  FoodTracker
//
//  Created by Mark Meretzky on 1/6/19.
//  Copyright © 2019 New York University School of Professional Studies. All rights reserved.
//

import UIKit;
import os.log;

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    
    /*
     This value is either passed by `MealTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new meal.
    */
    var meal: Meal?;

    @IBOutlet weak var nameTextField: UITextField!;
    @IBOutlet weak var photoImageView: UIImageView!;
    @IBOutlet weak var ratingControl: RatingControl!;
    @IBOutlet weak var saveButton: UIBarButtonItem!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Handle the text field’s user input through delegate callbacks.
        nameTextField.delegate = self;

        // Set up views if editing an existing Meal.
        if let meal: Meal = meal {
            navigationItem.title = meal.name;
            nameTextField.text   = meal.name;
            photoImageView.image = meal.photo;
            ratingControl.rating = meal.rating;
        }
        
        // Enable the Save button only if the text field has a valid Meal name.
        updateSaveButtonState();
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false;
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder();
        return true;
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState();
        navigationItem.title = textField.text;
    }
    
    //MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage: UIImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)");
        }
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage;
        
        // Dismiss the picker.
        dismiss(animated: true);
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil);
    }
    
    //MARK: Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddMealMode: Bool = presentingViewController is UINavigationController;
        
        if isPresentingInAddMealMode {
            dismiss(animated: true);
        }
        else if let owningNavigationController: UINavigationController = navigationController {
            owningNavigationController.popViewController(animated: true);
        }
        else {
            fatalError("The MealViewController is not inside a navigation controller.");
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender);
        
        // Configure the destination view controller only when the save button is pressed.

        guard let button: UIBarButtonItem = sender as? UIBarButtonItem,
            button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug);
            return;
        }
        
        let name: String = nameTextField.text ?? "";
        let photo: UIImage? = photoImageView.image;
        let rating: Int = ratingControl.rating;
        
        // Set the meal to be passed to MealTableViewController after the unwind segue.
        meal = Meal(name: name, photo: photo, rating: rating);
    }
    
    //MARK: Actions

    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        // Hide the keyboard.
        nameTextField.resignFirstResponder();
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController: UIImagePickerController = UIImagePickerController();
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary;
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self;
        
        present(imagePickerController, animated: true);
    }
    
    //MARK: Private Methods
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is nil or empty.
        let text: String = nameTextField.text ?? "";
        saveButton.isEnabled = !text.isEmpty;
    }
}
