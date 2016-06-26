//
//  LoginViewController.swift
//  TFG
//
//  Created by Johannes Berger on 06.04.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit
import Parse
import Onboard

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    ///Activity indicator that get displayed during the login process
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    
    ///Sets delegates and initializes hideKeyboardWhenTappedAround
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        usernameField.delegate = self
        passwordField.delegate = self
    }
    
    /**
    When User just signed up go directly into the app
    Show onboarding if user is new
    */
    override func viewDidAppear(animated: Bool) {
        //Dismiss Login view if sign up successful
        if (PFUser.currentUser() != nil) {
            CloudLink.syncAllDataToRealm()
            dismissKeyboard()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        //show onboarding
        if let pref = realm.objects(Preference).first{
            if pref.firstStart {
                let onboardingVC = setupOnboarding()
                self.presentViewController(onboardingVC, animated: true, completion: nil)
            }
        }else{
            print("Error: preferences missing")
        }
    }
    
    /** Method that ensures cursor is jumping to next text field when the enter key was tapped
        Parameter textField: the current textfield the cursor is in
        Returns: always true
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameField{
            passwordField.becomeFirstResponder()
        }else if textField == passwordField{
            validateAndLogIn()
        }
        return true
    }
    
    /// Invoked when the Login button was pressed or the return key was hit on the last text field
    @IBAction func loginButtonPressed(sender: AnyObject) {
        validateAndLogIn()
    }
    
    ///Starts validation process and if successful starts login process
    func validateAndLogIn(){
        if validateTextFieldValues(){
            let username = self.usernameField.text!
            let password = self.passwordField.text!
            login(username, password: password)
        }
    }
    
  
    
    /**
     Checks if data in the textfields is correct. If not it shows an alert
     - returns: true if all textfields contain valid data, else false
     */
    func validateTextFieldValues() -> Bool{
        let username = self.usernameField.text!
        let password = self.passwordField.text!
        
        var title = ""
        var message = ""
        
        //Check online connectivity
        if !CloudLink.isConnected(){
            title = NSLocalizedString("No connection", comment: "")
            message = NSLocalizedString("You need an internet connection to be able to log in", comment: "")
            // Validate the text fields
        } else if username.characters.count < 4 {
            title = NSLocalizedString("Invalid", comment: "")
            message = NSLocalizedString("Username must be greater than 4 characters", comment: "")
        } else if password.characters.count < 6 {
            title = NSLocalizedString("Invalid", comment: "")
            message = NSLocalizedString("Password must be greater than 6 characters", comment: "")
        } else {
            return true
        }
        showAlert(title, message: message)
        return false
    }
    
    
    /**
     Starts Login process
     - parameters:
       - username: Username as String
       - password: Password as String
     */
    func login(username: String, password: String){
        // Run a spinner to show a task in progress
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        // Send a request to login
        PFUser.logInWithUsernameInBackground(username, password: password, block: { (user, error) -> Void in
            
            // Stop the spinner
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            
            if ((user) != nil) {
                //User logged in successfully!
                self.dismissKeyboard()
                CloudLink.syncAllDataToRealm()
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                self.showAlert("Error", message: "\(error!.userInfo["error"] as! String)")
            }
        })

    }
    
    //MARK: Onboarding
    
    /**
     Creates a page-view-controller-like interface that shows the onboarding process
        - returns: OnboardingViewController
     */
    func setupOnboarding() -> OnboardingViewController {
        
        // Create tutorial pages
        let firstPage = OnboardingContentViewController(title: NSLocalizedString("Wellcome", comment: "wellcomming message at onboarding title"), body: NSLocalizedString("This short tutorial will guide you through the most important aspects of this app. Swipe left to continue", comment: "wellcomming message at onboarding"), image: UIImage(named: "Logo_tranparent"), buttonText: nil) {}
        
        let secondPage = OnboardingContentViewController(title: nil, body: NSLocalizedString("Choose a topic and start to learn", comment: "Tutorial page two text"), image: UIImage(named: "HomeScreen"), buttonText: nil) {}
        
        let thirdPage = OnboardingContentViewController(title: nil, body: NSLocalizedString("Multiple choice questions might have more than one correct answer. Single choice questions have only one correct answer.", comment: "Tutorial page three text"), image: UIImage(named: "questionTypes"), buttonText: nil) {}
        thirdPage.underTitlePadding = 0
        thirdPage.underIconPadding = 5
        
        let fourthPage = OnboardingContentViewController(title: nil, body: NSLocalizedString("Beautiful statistics show you your progress", comment: "Tutorial page four text"), image: UIImage(named: "statistics"), buttonText: "Let's start!") { () -> Void in
            self.completeOnboarding()
        }
        let startButton = UIButton()
        startButton.setTitle(NSLocalizedString("Let's start!", comment: "Text on start button in tutorial"), forState: .Normal)
        startButton.setBackgroundImage(UIImage(named: "ButtonBackgroundStroke"), forState: .Normal)
        startButton.addTarget(self, action: #selector(LoginViewController.completeOnboarding), forControlEvents: .TouchUpInside)
        
        fourthPage.actionButton = startButton
        
        
        
        // Image background
        let onboardingVC = OnboardingViewController(backgroundImage: UIImage(named: "Logo_big"), contents: [firstPage, secondPage, thirdPage, fourthPage])
        onboardingVC.shouldBlurBackground = true
        onboardingVC.shouldFadeTransitions = true
        
        onboardingVC.allowSkipping = true
        onboardingVC.skipHandler = { self.completeOnboarding() }
        let skipButton = UIButton()
        skipButton.setTitle(NSLocalizedString("Skip", comment: "Text on Skip button"), forState: .Normal)
        skipButton.addTarget(self, action: #selector(LoginViewController.completeOnboarding), forControlEvents: .TouchUpInside)
        onboardingVC.skipButton = skipButton
        
        return onboardingVC
    }
    
    ///safe that user has done the onboarding and go back to login view
    func completeOnboarding() {
        if let pref = realm.objects(Preference).first{
            realm.beginWrite()
            pref.firstStart = false
            realm.add(pref)
            try! realm.commitWrite()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    //MARK: Alertview
    
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
    
    @IBAction func unwindToLogInScreen(segue:UIStoryboardSegue) {
    }
    
    
}


