//
//  QuizResultsViewController.swift
//  TFG
//
//  Created by Johannes Berger on 06.03.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit
import RealmSwift

class QuizResultsViewController: UITableViewController, QuizResultsCellDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (Util().getCurrentTopic()?.questions.count)! + 1
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCellWithIdentifier("QuizResultsTableViewCell", forIndexPath: indexPath) as! QuizResultsTableViewCell
            // Configure the cell...
            cell.delegate = self
            cell.titleLabel.text = "You did okay"
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("QuizResultQuestionCell", forIndexPath: indexPath)
            // Configure the cell...
            let question = Util().getCurrentTopic()?.questions[indexPath.row - 1]
            cell.textLabel?.text = question?.questionText
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        //TODO: add own heights
        if(indexPath.row == 0)
        {
            return 300
        }
        else
        {
            return 55.0
        }
    }
    
    func goBackToRootVC() {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("Home") as! UITabBarController
        vc.selectedIndex = 1
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    
}













