//
//  SignUpViewController.swift
//  TFG
//
//  Created by Johannes Berger on 07.04.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController, UITextFieldDelegate  {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    ///Sets delegates and initializes hideKeyboardWhenTappedAround
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    /** Method that ensures cursor is jumping to next text field when the enter key was tapped
     Parameter textField: the current textfield the cursor is in
     Returns: always true
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameField{
            emailField.becomeFirstResponder()
        }else if textField == emailField{
            passwordField.becomeFirstResponder()
        }else if textField == passwordField{
            validateAndSignUp()
        }
        return true
    }
    
    /// Invoked when the Signup button was pressed or the return key was hit on the last text field
    @IBAction func signUpButtonPressed(sender: AnyObject) {
       validateAndSignUp()
    }
    
    ///Starts validation process and if successful starts Signup process
    func validateAndSignUp(){
        if validateTextFieldValues(){
            let username = self.usernameField.text!
            let password = self.passwordField.text!
            let email = self.emailField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            signUp(username, email: email ,password: password)
        }
    }
    
    /**
     Checks if data in the textfields is correct. If not it shows an alert
     - returns: true if all textfields contain valid data, else false
     */
    func validateTextFieldValues() -> Bool{
        let username = self.usernameField.text!
        let password = self.passwordField.text!
        let email = self.emailField.text!
        let finalEmail = email.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let trimedPassword = password.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        var title = ""
        var message = ""
        
        //Check online connectivity
        if !Util.isConnected(){
            title = NSLocalizedString("No connection", comment: "")
            message = NSLocalizedString("You need an internet connection to be able to log in", comment: "")
            // Validate the text fields
        } else if username.characters.count < 4 {
            title = NSLocalizedString("Invalid", comment: "")
            message = NSLocalizedString("Username must be greater than 4 characters", comment: "")
        } else if password.characters.count < 6 {
            title = NSLocalizedString("Invalid", comment: "")
            message = NSLocalizedString("Password must be greater than 6 characters", comment: "")
        } else if password != trimedPassword {
            title = NSLocalizedString("Invalid", comment: "")
            message = NSLocalizedString("Password can not contain whitespace characters", comment: "")
        } else if finalEmail.characters.count < 5 {
            title = NSLocalizedString("Invalid", comment: "")
            message = NSLocalizedString("Please enter a valid email address", comment: "")
        } else {
            return true
        }
        showAlert(title, message: message)
        return false
    }
    
    /**
     Starts Signup process. If successful it will also log the user in
     - parameters:
        - username: Username as String
        - email: Email as String
        - password: Password as String
     */
    func signUp(username:String, email:String, password:String){
        // Run a spinner to show a task in progress
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        let newUser = PFUser()
        newUser.username = username
        newUser.password = password
        newUser.email = email
        
        // Sign up the user asynchronously
        newUser.signUpInBackgroundWithBlock({ (succeed, error) -> Void in
            
            // Stop the spinner
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            
            if ((error) != nil) {
                self.showAlert("Error", message: "\(error!.userInfo["error"] as! String)")
                
            } else {
                
                let title = NSLocalizedString("Success", comment: "")
                let message = NSLocalizedString("You are signed up!", comment: "")
                let response = NSLocalizedString("Great!", comment: "this is the okay button")
                let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                let dismissVCAction = UIAlertAction(title: response, style: .Default) { (action) in
                    self.goBackToLogin()
                }
                alertController.addAction(dismissVCAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        })

    }
    
    ///dismisses the view controller when the little "X" is tapped
    func goBackToLogin(){
        self.dismissViewControllerAnimated(true, completion: nil)
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
