//
//  SecondViewController.swift
//  TFG
//
//  Created by Johannes Berger on 14.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit
import Parse

class PreferencesViewController: UIViewController {
    
    
    @IBOutlet weak var immediateFeedbackSwitch: UISwitch!
    @IBOutlet weak var secondsBeforeLockLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    @IBOutlet weak var lockSecondsSlider: UISlider!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var pref: Preference!
    
    ///Prepare the view with the current preference settings
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Preferences View")
        pref = Util.getPreferences()!
        immediateFeedbackSwitch.on = pref.immediateFeedback
        enableLockSecondsSlider(pref.immediateFeedback)
        lockSecondsSlider.value = Float(pref.lockSeconds)
        secondsLabel.text = String(pref.lockSeconds)
    }
    
    /**
    Toggle immediate feedback switch and save result locally and to cloud (async)
     - parameter sender: user interaction
    */
    @IBAction func immediateFeedbackSwitchPressed(sender: AnyObject) {
        realm.beginWrite()
        pref.immediateFeedback = !pref.immediateFeedback
        realm.add(pref)
        try! realm.commitWrite()
        enableLockSecondsSlider(pref.immediateFeedback)
        CloudLink.syncPreferencesToCloud()
    }
    
    /**
     Fires when slider was moved. Fixes slider to whole integer position and only saves
     the value if it differs from the old one.
     - parameter sender: user interaction
     */
    @IBAction func lockSecondsSliderValueDidChange(sender: AnyObject) {
        let oldValue = pref.lockSeconds
        let newValue = Int(lroundf(lockSecondsSlider.value))
        //Fix slider to integer position
        sender.setValue(Float(lroundf(lockSecondsSlider.value)), animated: true)
        if oldValue != newValue{
            secondsLabel.text = String(Int(lockSecondsSlider.value))
            realm.beginWrite()
            pref.lockSeconds = Int(lockSecondsSlider.value)
            realm.add(pref)
            try! realm.commitWrite()
            CloudLink.syncPreferencesToCloud()
        }
    }
    
    /**
     Enables/disables the slider and its labels
     - parameter enable: Bool to determine if it should be enabled or disabled
     */
    func enableLockSecondsSlider(enable: Bool){
        secondsBeforeLockLabel.enabled = enable
        secondsLabel.enabled = enable
        lockSecondsSlider.enabled = enable
    }
    
    /**
     Brings up an alertview asking the user if he/she wants to delete the statistics
     - parameter sender: user interaction
     */
    @IBAction func deleteStatisticsButtonPressed(sender: AnyObject) {
        
        let title = NSLocalizedString("Delete Statistics?", comment: "")
        let message = NSLocalizedString("Are you sure you want to delete all statistics? This cannot be undone!", comment: "")
        let delete = NSLocalizedString("Delete", comment: "")
        let cancel = NSLocalizedString("Cancel", comment: "")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let deleteAction = UIAlertAction(title: delete, style: .Destructive) { (action) in
            Util.deleteAllStatistics()
        }
        alertController.addAction(deleteAction)
        alertController.addAction(UIAlertAction(title: cancel, style: .Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    

    /**
     Brings up an alertview asking the user if he/she wants to log out
     - parameter sender: user interaction
     */
    @IBAction func logOutButtonPressed(sender: AnyObject) {
        
        let title = NSLocalizedString("Log Out?", comment: "")
        let message = NSLocalizedString("Are you sure you want to log out?", comment: "")
        let logOut = NSLocalizedString("Log Out", comment: "")
        let cancel = NSLocalizedString("Cancel", comment: "")
        
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        let deleteAction = UIAlertAction(title: logOut, style: .Destructive) { (action) in
            self.logOut()
        }
        alertController.addAction(deleteAction)
        alertController.addAction(UIAlertAction(title: cancel, style: .Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    ///Logs the current user out provided that there is a internet connection
    func logOut(){
        //Check online connectivity
        if !CloudLink.isConnected(){
            showAlert(NSLocalizedString("No connection", comment: ""), message: NSLocalizedString("You need an internet connection to be able to safely log out", comment: ""))
        }else{
            
            // Run a spinner to show a task in progress
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            // Send a request to log out a user
            PFUser.logOutInBackgroundWithBlock { (error) in
                if error == nil{
                    Util.deleteUserData()
                    // Stop the spinner
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    //show home view
                    let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("Home") as! UITabBarController
                    homeVC.selectedIndex = 0 // Home View
                    self.presentViewController(homeVC, animated: true, completion: nil)
                }else{
                    print("Error: \(error!.userInfo["error"])")
                }
            }
        }
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

