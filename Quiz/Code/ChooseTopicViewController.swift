//
//  ChooseTopicViewController.swift
//  TFG
//
//  Created by Johannes Berger on 21.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit
import RealmSwift

///View Controller for the topic choosing scene (tableView based)
class ChooseTopicViewController: UITableViewController {
    
    // MARK: - Table view data source
    
    ///Number of rows are the number of topics present
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Util.getNumberOfTopics()
    }
    
    ///Initializes the cells
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TopicCell", forIndexPath: indexPath)
        // Configure the cell...
        let topics = realm.objects(Topic)
        let currentCell = topics[indexPath.row]
        cell.accessoryType = currentCell.isSelected ? .Checkmark : .None
        cell.textLabel?.text = currentCell.title
        cell.detailTextLabel?.text = currentCell.author + " " + currentCell.date
        cell.accessibilityLabel = currentCell.title
        return cell
    }
    
    ///saves selection of topic to Realm
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        realm.beginWrite()
        //Uncheck all
        let topics = realm.objects(Topic)
        for topic in topics{
            topic.isSelected = false
        }
        //Check just the one selected
        let currentCell = tableView.cellForRowAtIndexPath(indexPath)
        let topicOfCurrentCell = currentCell?.textLabel?.text
        let currentCellData = realm.objectForPrimaryKey(Topic.self, key: topicOfCurrentCell!)!
        currentCellData.isSelected = true
        realm.add(topics)
        try! realm.commitWrite()
        tableView.reloadData()
    }
    
    
    // Override to support editing the table view.
    /* //Disabled because it can cause inconsistency issues
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let title = self.tableView!.cellForRowAtIndexPath(indexPath)!.textLabel!.text!
            let topic = Util.getTopicWithTitle(title)!
            Util.deleteTopic(topic)
            //delete row
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    */
    
    //Disabled because topics are in the cloud now
//    @IBAction func addTopicButtonPressed(sender: AnyObject) {
//        loadExampleData()
//    }
    
    ///Method that loads example data. Only used for development
//    func loadExampleData() {
//        let importer = ImportAndSaveHelper()
//        importer.loadAndSave("Sample1")
//        importer.loadAndSave("Sample2")
//        tableView.reloadData()
//    }
    
}













