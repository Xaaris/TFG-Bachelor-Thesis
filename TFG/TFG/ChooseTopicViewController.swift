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
    
    var lastSelectedIndexPath:NSIndexPath? = nil
    var lastSelectedTopic:String? = nil
    
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
        cell.accessoryType = (lastSelectedIndexPath?.row == indexPath.row) ? .Checkmark : .None
        let result = realm.objects(Topic)
        cell.textLabel?.text = result[indexPath.row].title
        if cell.textLabel?.text == lastSelectedTopic{
            cell.accessoryType = .Checkmark
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row != lastSelectedIndexPath?.row {
            if let lastSelectedIndexPath = lastSelectedIndexPath {
                let oldCell = tableView.cellForRowAtIndexPath(lastSelectedIndexPath)
                oldCell?.accessoryType = .None
            }
            let newCell = tableView.cellForRowAtIndexPath(indexPath)
            newCell?.accessoryType = .Checkmark
            lastSelectedIndexPath = indexPath
            lastSelectedTopic = tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text
            //Giving info of selected topic to mainVC
            let mainVC = self.navigationController!.viewControllers.first as! MainViewController
            mainVC.lastSelectedTopic = lastSelectedTopic
        }
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
        if let keyedRowsDic = loadDataFromFile("Sample1"){
            parseDataForValuesAndSaveToRealm(keyedRowsDic)
            
        }else{
            print("Could not load Data")
        }
        if let keyedRowsDic = loadDataFromFile("Sample2"){
            parseDataForValuesAndSaveToRealm(keyedRowsDic)
            
        }else{
            print("Could not load Data")
        }
        
    }
    
    func loadDataFromFile(fileName: String) -> [[String : String]]? {
        let csvURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(fileName, ofType: "csv")!)
        do{
            let text = try String(contentsOfURL: csvURL)
            let csvImporter = CSVImporter(String: text, separator: ";")
            if let keyedRows = csvImporter.keyedRows{
                return keyedRows
            }
        }catch{
            print(error)
        }
        return nil
    }
    
    func parseDataForValuesAndSaveToRealm(keyedRowsDic: [[String:String]]) {
        var title = ""
        var author = ""
        var date = ""
        var universalTags = Set<String>()
        let topic = Topic()
        for row in keyedRowsDic{
            //Info row
            if row["QuestionType"] == "Info"{
                title = row["Question"]!.isEmpty ? "No title" : row["Question"]!
                topic.title = title
                author = row["Hint"]!.isEmpty ? "No author" : row["Hint"]!
                date = row["Feedback"]!.isEmpty ? "No Date" : row["Feedback"]!
                for tag in row.values{
                    if !tag.isEmpty{
                        universalTags.insert(tag)
                    }
                }
                universalTags.remove(title)
                universalTags.remove(author)
                universalTags.remove(date)
                universalTags.remove("Info")
                //Normal row
            }else if !row["QuestionType"]!.isEmpty {
                if let type = row["QuestionType"], question = row["Question"], hint = row["Hint"], feedback = row["Feedback"], tmpDifficulty = row["Difficulty"], correctAnswers = row["CorrectAnswers"]?.componentsSeparatedByString(","){
                    if let difficulty = Int(tmpDifficulty){
                        var tmpAnswerDic = [String:String]()
                        var answers = [String: Bool]()
                        var tags = universalTags
                        //extracting answers and tags
                        for cell in row{
                            if cell.0.containsString("Answer") && !cell.0.containsString("C") && !cell.1.isEmpty{
                                tmpAnswerDic[cell.0.lowercaseString.stringByReplacingOccurrencesOfString("answer", withString: "")] = cell.1
                            }else if cell.0.containsString("Tag") && !cell.1.isEmpty{
                                tags.insert(cell.1)
                            }
                        }
                        //mapping answers with their value of truth
                        for answerKey in tmpAnswerDic.keys {
                            if correctAnswers.contains(answerKey){
                                answers[tmpAnswerDic[answerKey]!] = true
                            }else{
                                answers[tmpAnswerDic[answerKey]!] = false
                            }
                        }
                        
                        //Building a Question
                        let tmpQuestion = Question()
                        tmpQuestion.topic = topic
                        tmpQuestion.author = author
                        tmpQuestion.date = date
                        tmpQuestion.type = type
                        tmpQuestion.questionText = question
                        tmpQuestion.hint = hint
                        tmpQuestion.feedback = feedback
                        tmpQuestion.difficulty = difficulty
                        
                        //Creating the answers
                        for answer in answers {
                            let tmpAnswer = Answer()
                            tmpAnswer.answerText = answer.0
                            tmpAnswer.isCorrect = answer.1
                            tmpAnswer.associatedQuestion = tmpQuestion
                            tmpQuestion.answers.append(tmpAnswer)
                        }
                        
                        //Creating the tags
                        for tag in tags {
                            //See if tag already exists
                            if let tagExists = realm.objectForPrimaryKey(Tag.self, key: tag){
                                tmpQuestion.tags.append(tagExists)
                            }else{
                                let newTag = Tag()
                                newTag.tagText = tag
                                tmpQuestion.tags.append(newTag)
                            }
                        }
                        
                        saveToRealm(tmpQuestion)
                        
                    }else{
                        print("failed to assign difficulty, Int parsing failed")
                    }
                }else{
                    print("Unwrapping type, Question, Hint, Feedback or CorrectAnswers failed!")
                }
            }
        }
        //Save topic to realm
        realm.beginWrite()
        if realm.objectForPrimaryKey(Topic.self, key: title) == nil {
            realm.add(topic)
        }else{
            print("Topic already exists")
        }
        try! realm.commitWrite()
        self.tableView.reloadData()
    }
    
    func saveToRealm(question: Question){
        // Save object
        realm.beginWrite()
        //check if it already exists
        if realm.objectForPrimaryKey(Question.self, key: question.questionText) == nil {
            realm.add(question)
        }else{
            print("Question with questionText: \(question.questionText) already exists")
        }
        try! realm.commitWrite()
        
    }
    
}













