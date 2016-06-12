//
//  ForgotPasswordViewController.swift
//  TFG
//
//  Created by Johannes Berger on 07.04.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit
import Parse

///This class is not active as of now because Parse disabled this functionality in its API
class ForgotPasswordViewController: UIViewController, UITextFieldDelegate  {
    
    @IBOutlet weak var emailField: UITextField!
    
    ///Activity indicator that get displayed during the reset process
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    ///Sets delegates and initializes hideKeyboardWhenTappedAround
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        emailField.delegate = self
    }
    
    /** Method that ensures cursor is jumping to next text field when the enter key was tapped
     Parameter textField: the current textfield the cursor is in
     Returns: always true
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == emailField{
            validateAndReset()
        }
        return true
    }
    
    /// Invoked when the Reset button was pressed or the return key was hit on the last text field
    @IBAction func passwordResetButtonPressed(sender: AnyObject) {
        validateAndReset()
    }
    
    ///Starts validation process and if successful starts reset process
    func validateAndReset(){
        if validateTextFieldValues(){
            let email = self.emailField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            resetPassword(email)
        }
    }
    
    /**
     Checks if data in the textfields is correct. If not it shows an alert
     - returns: true if all textfields contain valid data, else false
     */
    func validateTextFieldValues() -> Bool{
        let email = self.emailField.text!
        let finalEmail = email.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        var title = ""
        var message = ""
        
        //Check online connectivity
        if !CloudLink.isConnected(){
            title = NSLocalizedString("No connection", comment: "")
            message = NSLocalizedString("You need an internet connection to be able to log in", comment: "")
        }else if finalEmail.characters.count < 5 {
            title = NSLocalizedString("Invalid", comment: "")
            message = NSLocalizedString("Please enter a valid email address", comment: "")
        } else {
            return true
        }
        showAlert(title, message: message)
        return false
    }
    
    /**
     Starts Reset process.
     - parameters:
        - email: Email as String
     */
    func resetPassword(email: String){
        // Run a spinner to show a task in progress
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        // Send a request to reset a password
        PFUser.requestPasswordResetForEmailInBackground(email, block: { (succeeded: Bool, error: NSError?) in
            
            // Stop the spinner
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            
            if error == nil {
                if succeeded { // SUCCESSFULLY SENT TO EMAIL
                    let title = NSLocalizedString("Password Reset", comment: "")
                    let message = NSLocalizedString("An email containing information on how to reset your password has been sent to: ", comment: "")
                    self.showAlert(title, message: message + email)
                }
                else { // SOME PROBLEM OCCURED
                    self.showAlert("Unknown Error", message: "An unknown error occured")
                }
            }
            else { //ERROR OCCURED, DISPLAY ERROR MESSAGE
                self.showAlert("Error", message: "\(error!.userInfo["error"] as! String)")
            }
        })
    }
    
    /**
     Shows an overlay alert with an "OK" button to dimiss it
     - parameters:
        - title: Title of the alert
        - message: body of the alert
     */
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}
