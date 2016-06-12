//
//  DeleteStatisticsTableViewController.swift
//  TFG
//
//  Created by Johannes Berger on 27.05.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit

///Class that displays the table view in which you can delete statistics
class DeleteStatisticsTableViewController: UITableViewController {
    
    var topics = realm.objects(Topic)
    
    ///load topics for easier access
    override func viewDidLoad() {
        super.viewDidLoad()
        topics = realm.objects(Topic)
    }
    
    // MARK: - Table view data source
    
    ///The view is split into 2 sections
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    ///Returns the number of rows per section.
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return Util.getNumberOfTopics()
        default:
            return 1
        }
    }
    
    ///Initializes the cells
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        //delete all cell
        if indexPath.section == 0{
            cell = tableView.dequeueReusableCellWithIdentifier("deleteAllCell", forIndexPath: indexPath)
            cell.textLabel?.text = NSLocalizedString("Delete all statistics", comment: "Delete all stats button in tableView")
        }else{
            cell = tableView.dequeueReusableCellWithIdentifier("topicNameCell", forIndexPath: indexPath)
            cell.textLabel?.text = topics[indexPath.row].title
        }
        return cell
    }
    
    ///Returns the headers for each section.
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            if Util.getNumberOfTopics() > 0{
                return NSLocalizedString("Delete statistics of a certain topic", comment: "Header that gets displayed above the the section to delete individual topicstats")
            }else{
                return nil
            }
        default:
            return nil
        }
    }
    
    ///Returns the footers for each section.
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 1:
            if Util.getNumberOfTopics() > 0{
                return NSLocalizedString("This will delete all the statistics of a topic that are associated with your account", comment: "Footer that gets displayed under the the section to delete individual topicstats")
            }else{
                return nil
            }
        default:
            return nil
        }
    }
    
    /**
     Brings up an alertview asking the user if he/she wants to delete the statistics
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let title = NSLocalizedString("Delete Statistics?", comment: "")
        var message = ""
        let delete = NSLocalizedString("Delete", comment: "")
        let cancel = NSLocalizedString("Cancel", comment: "")
        var deleteAction = UIAlertAction()
        
        //Delete all statistics
        if indexPath.section == 0{
            message = NSLocalizedString("Are you sure you want to delete all statistics? This cannot be undone!", comment: "")
            deleteAction = UIAlertAction(title: delete, style: .Destructive) { (action) in
                Util.deleteAllStatistics()
            }
        //Delete only of one topic
        }else{
            message = NSLocalizedString("Are you sure you want to delete all statistics of \(topics[indexPath.row].title)? This cannot be undone!", comment: "")
            deleteAction = UIAlertAction(title: delete, style: .Destructive) { (action) in
                Util.deleteStatisticsof(self.topics[indexPath.row])
            }
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(deleteAction)
        alertController.addAction(UIAlertAction(title: cancel, style: .Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
        tableView.reloadData()
    }
    
}



