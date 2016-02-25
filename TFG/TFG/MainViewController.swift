//
//  FirstViewController.swift
//  TFG
//
//  Created by Johannes Berger on 14.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var topicLabel: UILabel!
    
    var lastSelectedTopic:String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Main View")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        if lastSelectedTopic != nil {
            topicLabel.text = lastSelectedTopic
        }else{
            topicLabel.text = "No topic selected"
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let chooseTopicVC = segue.destinationViewController as! ChooseTopicViewController
        chooseTopicVC.lastSelectedTopic = lastSelectedTopic
    }
    
    
}

