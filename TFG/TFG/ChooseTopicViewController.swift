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

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

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
           let questionArr = parseDataForValues(keyedRowsDic)
            saveToRealm(questionArr)
            
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
    
    func parseDataForValues(keyedRowsDic: [[String:String]]) -> [Question] {
        var questionArr = [Question]()
        var title = ""
        var author = ""
        var date = ""
        var universalTags = Set<String>()
        for row in keyedRowsDic{
            //Info row
            if row["QuestionType"] == "Info"{
                title = row["Question"]!.isEmpty ? "No title" : row["Question"]!
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
                        
                        let answerContainer = AnswerContainer()
                        let tagContainer = TagContainer()
                        
                        for answer in answers {
                            answerContainer.answers.append(Answer(text: answer.0,isCorrect: answer.1))
                        }
                        for tag in tags {
                            tagContainer.tags.append(Tag(tag: tag))
                        }
                        let tmpQuestion = Question()
                        tmpQuestion.title = title
                        tmpQuestion.author = author
                        tmpQuestion.date = date
                        tmpQuestion.type = type
                        tmpQuestion.questionText = question
                        tmpQuestion.hint = hint
                        tmpQuestion.feedback = feedback
                        tmpQuestion.difficulty = difficulty
                        tmpQuestion.answerContainer = answerContainer
                        tmpQuestion.tagContainer = tagContainer
                        
                        questionArr.append(tmpQuestion)
                        
                    }else{
                        print("failed to assign difficulty, Int parsing failed")
                    }
                    
                }else{
                    print("Unwrapping type, Question, Hint, Feedback or CorrectAnswers failed!")
                }
            }
        }
        return questionArr
    }
    
    func saveToRealm(questionArr: [Question]){
        
        //TODO: This should probably be moved
        // Inside your application(application:didFinishLaunchingWithOptions:)
        
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 1,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        
        
        // Realms are used to group data together
        let realm = try! Realm() // Create realm pointing to default file
        
        // Save objects
        realm.beginWrite()
        for question in questionArr{
            //check if it already exists
            if realm.objectForPrimaryKey(Question.self, key: question.questionText) == nil {
                realm.add(question)
            }
        }
        try! realm.commitWrite()
        
        print(realm.objects(Question).count)
    }

}













