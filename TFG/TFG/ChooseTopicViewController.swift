//
//  ChooseTopicViewController.swift
//  TFG
//
//  Created by Johannes Berger on 21.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit
import RealmSwift

class ChooseTopicViewController: UITableViewController {
    
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
        return realm.objects(Topic).count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TopicCell", forIndexPath: indexPath)
        // Configure the cell...
        let topics = realm.objects(Topic)
        let currentCell = topics[indexPath.row]
        cell.accessoryType = currentCell.isSelected ? .Checkmark : .None
        cell.textLabel?.text = currentCell.title
        cell.detailTextLabel?.text = currentCell.author + " " + currentCell.date
        return cell
    }
    
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
    
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let predicate = NSPredicate(format: "title = %@ ", self.tableView!.cellForRowAtIndexPath(indexPath)!.textLabel!.text!)
            let result = realm.objects(Topic).filter(predicate).first
            try! realm.write {
                realm.delete(result!)
            }
            //delete questions without associated topics
            let questions = realm.objects(Question.self)
            for question in questions{
                if question.topic == nil{
                    try! realm.write {
                        realm.delete(question)
                    }
                }
            }
            //delete answers without associated questions
            let answers = realm.objects(Answer.self)
            for answer in answers{
                if answer.associatedQuestion == nil{
                    try! realm.write {
                        realm.delete(answer)
                    }
                }
            }
            //delete tags without associated questions
            let tags = realm.objects(Tag.self)
            for tag in tags{
                if tag.associatedQuestions.isEmpty {
                    try! realm.write {
                        realm.delete(tag)
                    }
                }
            }
            //delete row
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    
    // MARK: - Navigation
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func addTopicButtonPressed(sender: AnyObject) {
        loadExampleData()
    }
    
    func loadExampleData() {
        let importer = ImportAndSaveHelper()
        importer.loadAndSave("Sample1")
        importer.loadAndSave("Sample2")
        tableView.reloadData()
    }
    
}













