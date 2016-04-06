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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        //Show Login view
        if (PFUser.currentUser() == nil) {
            let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("Login")
            self.presentViewController(loginVC!, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if let currentTopic = realm.objects(Topic).filter("isSelected == true").first{
            topicLabel.text = currentTopic.title
        }else{
            topicLabel.text = "No topic selected"
        }
        if let pUserName = PFUser.currentUser()?["username"] as? String {
            self.userNameLabel.text = pUserName
        }
    }
    
    @IBAction func startButtonPressed(sender: AnyObject) {
        if Util().getCurrentTopic() != nil{
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("PageController") as! PresentQuestionPageViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let alertController = UIAlertController(title: "No Topic Selected", message:
                "Please choose a topic first", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
}

