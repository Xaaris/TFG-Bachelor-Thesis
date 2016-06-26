//
//  FirstViewController.swift
//  TFG
//
//  Created by Johannes Berger on 14.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit
import Parse

class MainViewController: UIViewController {
    
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Main View")

    }
    
    override func viewDidAppear(animated: Bool) {
        
        // initialize Preferences
        if realm.objects(Preference.self).isEmpty{
            createDefaultPreferences()
        }
        //Show Login view
        if (PFUser.currentUser() == nil) {
            let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("Login")
            self.presentViewController(loginVC!, animated: true, completion: nil)
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        //displaying current topic
        if let currentTopic = Util.getCurrentTopic(){
            topicLabel.text = currentTopic.title
        }else{
            topicLabel.text = NSLocalizedString("No topic selected", comment: "Message when no topic has been selected")
        }
        //displaying current user name
        if let pUserName = Util.getCurrentUserName() {
            self.userNameLabel.text = pUserName
        }
    }
    
    /**
     This method starts the quiz part of the app. It is invoked by the press of the center "Start" button on the main screen, hence the parameter sender.
     */
    @IBAction func startButtonPressed(sender: AnyObject) {
        
        if Util.getCurrentTopic() != nil{
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("PageController") as! PresentQuestionPageViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            //if no topic is selected show alert message
            let title = NSLocalizedString("No topic selected", comment: "Message when no topic has been selected")
            let message = NSLocalizedString("Please choose a topic first", comment: "Message when no topic has been selected (Message body)")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    ///Creates a Preferences object with default values
    func createDefaultPreferences(){
        realm.beginWrite()
        let pref = Preference()
        pref.feedback = false
        pref.lockSeconds = 2
        pref.firstStart = true
        realm.add(pref)
        try! realm.commitWrite()
    }
    
}

