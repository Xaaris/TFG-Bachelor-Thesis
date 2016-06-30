//
//  MainViewController.swift
//  Uploader
//
//  Created by Johannes Berger on 02.05.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit
import Parse

class MainViewController: UIViewController {
    
    //Labels to show the loading and deletion process
    @IBOutlet weak var dataLoadedLabel: UILabel!
    @IBOutlet weak var dataDeletedLabel: UILabel!
    
    //Counter labels
    @IBOutlet weak var topicsCounterLabel: UILabel!
    @IBOutlet weak var questionsCounterLabel: UILabel!
    @IBOutlet weak var answersCounterLabel: UILabel!
    
    //Upload button
    @IBOutlet weak var uploadButton: UIButton!
    
    //Completion flags
    var answersDeleted = false
    var questionsDeleted = false
    var topicsDeleted = false
    
    //Counters for number of topics, questions and answers
    var topicCounter = 0
    var questionCounter = 0
    var answerCounter = 0
    
    // Files that should be uploaded to the cloud. Every file needs to be put in a tuple 
    // here in the format ("filename","file extension")
    let topicsToLoad = [("Sample2","csv"),("Sample3","csv"),("Sample4","csv")]
//    let topicsToLoad = [("JavaIntro","xml")] //load xml file
    
    
    ///Starts deletion and data loading process when app starts
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        deleteAllTopics()
        extractCSVDataAndSaveToRealm()
    }
    
    /// Loods all the above specified files into Realm
    func extractCSVDataAndSaveToRealm() {
        let importer = Importer()
        for file in topicsToLoad{
            importer.loadAndSave(file.0, ext: file.1)
        }
        dataLoadedLabel.enabled = true
        uploadButton.enabled = true
    }
    
    ///Starts The upload process, invoked by the user
    @IBAction func startUpload(sender: AnyObject) {
        uploadButton.enabled = false
        saveAllTopicsToCloud()
    }
    
    ///Deletes all old data both locally and in the cloud
    func deleteAllTopics(){
        //delete locally
        Util.deleteAllTopics()
        var deletedTopicsCounter = 0
        var deletedQuestionsCounter = 0
        var deletedAnswersCounter = 0
        //Delete answers in the cloud
        let answerQuery = PFQuery(className: "Answer")
        answerQuery.limit = 1000
        answerQuery.findObjectsInBackgroundWithBlock { (objects, error) in
            if error == nil {
                if let answers = objects{
                    for answer in answers{
                        answer.deleteInBackground()
                        deletedAnswersCounter += 1
                    }
                    print("Deleted Answers: \(deletedAnswersCounter)")
                    self.answersDeleted = true
                    if self.answersDeleted && self.questionsDeleted && self.topicsDeleted{
                        self.dataDeletedLabel.enabled = true
                    }
                }
            }
        }
        //Delete questions in the cloud
        let questionQuery = PFQuery(className: "Question")
        questionQuery.limit = 1000
        questionQuery.findObjectsInBackgroundWithBlock { (objects, error) in
            if error == nil {
                if let questions = objects{
                    for question in questions{
                        question.deleteInBackground()
                        deletedQuestionsCounter += 1
                    }
                    print("Deleted Questions: \(deletedQuestionsCounter)")
                    self.questionsDeleted = true
                    if self.answersDeleted && self.questionsDeleted && self.topicsDeleted{
                        self.dataDeletedLabel.enabled = true
                    }
                }
            }
        }
        //Delete topics in the cloud
        let topicQuery = PFQuery(className: "Topic")
        topicQuery.findObjectsInBackgroundWithBlock { (objects, error) in
            if error == nil {
                if let topics = objects{
                    for topic in topics{
                        topic.deleteInBackground()
                        deletedTopicsCounter += 1
                    }
                    print("Deleted Topics: \(deletedTopicsCounter)")
                    self.topicsDeleted = true
                    if self.answersDeleted && self.questionsDeleted && self.topicsDeleted{
                        self.dataDeletedLabel.enabled = true
                    }
                }
            }
        }
        
    }
    
    
    ///Uploads all topics from Realm to the cloud
    func saveAllTopicsToCloud(){
        let topics = realm.objects(Topic.self)
        let numberOfTopics = topics.count
        var numberOfQuestions = 0
        var numberOfAnswers = 0
        for topic in topics{
            numberOfQuestions += topic.questions.count
            for question in topic.questions{
                numberOfAnswers += question.answers.count
            }
        }
        for topic in topics{
            let query = PFQuery(className: "Topic")
            query.whereKey("title", equalTo: topic.title)
            query.findObjectsInBackgroundWithBlock { (objects, error) in
                if error == nil {
                    if let topicsArr = objects{
                        if topicsArr.count == 0{
                            let cloudTopic = PFObject(className: "Topic")
                            cloudTopic["title"] = topic.title
                            cloudTopic["author"] = topic.author
                            cloudTopic["date"] = topic.date
                            cloudTopic["colorR"] = topic.color!.red
                            cloudTopic["colorG"] = topic.color!.green
                            cloudTopic["colorB"] = topic.color!.blue
                            cloudTopic["globalAverage"] = 0.5
                            cloudTopic.saveInBackgroundWithBlock({ (success, error) in
                                if error == nil {
                                    self.topicCounter += 1
                                    self.topicsCounterLabel.text = "Topics: \(self.topicCounter)/\(numberOfTopics)"
                                    let topicID = cloudTopic.objectId
                                    for question in topic.questions{
                                        let cloudQuestion = PFObject(className: "Question")
                                        cloudQuestion["topicID"] = topicID
                                        cloudQuestion["topic"] = question.topic!.title
                                        cloudQuestion["type"] = question.type
                                        cloudQuestion["questionText"] = question.questionText
                                        cloudQuestion["hint"] = question.hint
                                        cloudQuestion["feedback"] = question.feedback
                                        cloudQuestion["picURL"] = question.picURL
                                        cloudQuestion.saveInBackgroundWithBlock({ (success, error) in
                                            if error == nil {
                                                self.questionCounter += 1
                                                self.questionsCounterLabel.text = "Questions: \(self.questionCounter)/\(numberOfQuestions)"
                                                let questionID = cloudQuestion.objectId
                                                for answer in question.answers{
                                                    let cloudAnswer = PFObject(className: "Answer")
                                                    cloudAnswer["questionID"] = questionID
                                                    cloudAnswer["answerText"] = answer.answerText
                                                    cloudAnswer["isCorrect"] = answer.isCorrect
                                                    cloudAnswer.saveInBackgroundWithBlock({ (success, error) in
                                                        if error == nil {
                                                            self.answerCounter += 1
                                                            self.answersCounterLabel.text = "Answers: \(self.answerCounter)/\(numberOfAnswers)"
                                                            if self.answerCounter == numberOfAnswers {
                                                                self.uploadCompleted()
                                                            }
                                                        }
                                                    })
                                                    
                                                }
                                            }
                                        })
                                        
                                        
                                    }
                                }
                            })
                            
                            print("Successfully uploaded topics")
                        }else{
                            print("Error: There are already topics on the server")
                        }
                    }else{
                        print("Error: topicsArr is nil")
                    }
                }else{
                    print("Error: \(error!.userInfo["error"])")
                }
            }
        }
    }
    
    /**
     Shows an overlay alert to notify the user that the upload is complete with an "OK" button to dimiss it
     */
    func uploadCompleted(){
        let alertController = UIAlertController(title: "Upload complete", message: "The upload process has completed. You can now exit the app.", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}
