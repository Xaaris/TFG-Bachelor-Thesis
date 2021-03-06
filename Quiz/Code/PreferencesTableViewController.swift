//
//  PreferencesTableViewController.swift
//  TFG
//
//  Created by Johannes Berger on 23.05.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit
import Parse

///Class that displays the preferences scene
class PreferencesTableViewController: UITableViewController {
    
    @IBOutlet var prefTableView: UITableView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var feedbackSwitch: UISwitch!
    @IBOutlet weak var lockSwitch: UISwitch!
    @IBOutlet weak var secondsSlider: UISlider!
    @IBOutlet weak var lockSecondsValueStack: UIStackView!
    
    ///Activity indicator that get displayed during the logout process
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var pref: Preference!
    
    ///Loads preferences for easy access and prepares the view
    override func viewDidLoad() {
        super.viewDidLoad()
        pref = Util.getPreferences()!
        prepareView()
    }

    ///Prepares the view according to the current preferences
    func prepareView(){
        userNameLabel.text = Util.getCurrentUserName()
        feedbackSwitch.on = pref.feedback
        lockSwitch.on = pref.showLockButton
        secondsSlider.enabled = pref.showLockButton
        //Enable/Disable all the values under the slider
        for label in lockSecondsValueStack.arrangedSubviews{
            let tmpLabel = label as! UILabel
            tmpLabel.enabled = pref.showLockButton
        }
        secondsSlider.value = Float(pref.lockSeconds)
        prefTableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    ///Returns the number of rows per section. Here used to hide rows when the are not needed
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if pref.feedback{
                return 3
            }else{
                return 1
            }
        case 2:
            return 2
        default:
            return 1
        }
    }
 
    ///Returns the footers for each section. Here used to hide a footer when its not needed
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 1:
            if pref.feedback{
                return NSLocalizedString("Seconds before a question automatically locks", comment: "Footer that gets displayed under the slider for the lock seconds")
            }else{
                return nil
            }
        default:
            return nil
        }
    }

    /**
     Toggle immediate feedback switch and save result locally and to cloud (async)
     - parameter sender: user interaction
     */
    @IBAction func feedbackSwitchtoggled(sender: AnyObject) {
        realm.beginWrite()
        pref.feedback = !pref.feedback
        realm.add(pref)
        try! realm.commitWrite()
        prepareView()
        CloudLink.syncPreferencesToCloud()
    }
    
    @IBAction func lockSwitchToggled(sender: AnyObject) {
        realm.beginWrite()
        pref.showLockButton = !pref.showLockButton
        realm.add(pref)
        try! realm.commitWrite()
        prepareView()
        CloudLink.syncPreferencesToCloud()
    }
    
    /**
     Fires when slider was moved. Fixes slider to whole integer position and only saves
     the value if it differs from the old one.
     - parameter sender: user interaction
     */
    @IBAction func secondsSliderMoved(sender: AnyObject) {
        let oldValue = pref.lockSeconds
        let newValue = Int(lroundf(secondsSlider.value))
        //Fix slider to integer position
        sender.setValue(Float(lroundf(secondsSlider.value)), animated: true)
        if oldValue != newValue{
            realm.beginWrite()
            pref.lockSeconds = Int(secondsSlider.value)
            realm.add(pref)
            try! realm.commitWrite()
            CloudLink.syncPreferencesToCloud()
        }
    }
    
    /**
     Brings up an alertview asking the user if he/she wants to log out
     - parameter sender: user interaction
     */
    @IBAction func LogOutButtonPressed(sender: AnyObject) {
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
