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
    
    @IBOutlet weak var dataDeletedLabel: UILabel!
    @IBOutlet weak var dataLoadedLabel: UILabel!
    
    @IBOutlet weak var topicsCounterLabel: UILabel!
    @IBOutlet weak var questionsCounterLabel: UILabel!
    @IBOutlet weak var answersCounterLabel: UILabel!
    
    @IBOutlet weak var uploadButton: UIButton!
    
    var answersDeleted = false
    var questionsDeleted = false
    var topicsDeleted = false
    
    var topicCounter = 0
    var questionCounter = 0
    var answerCounter = 0
    
    func extractCSVDataAndSaveToRealm() {
        let importer = Importer()
//        importer.loadAndSave("Sample1", ext: "csv")
        importer.loadAndSave("Sample2", ext: "csv")
        importer.loadAndSave("Sample3", ext: "csv")
        importer.loadAndSave("Sample4", ext: "csv")
//        importer.loadAndSave("JavaIntro", ext: "xml")
        dataLoadedLabel.hidden = false
    }
    
    @IBAction func startUpload(sender: AnyObject) {
        uploadButton.enabled = false
        saveAllTopicsToCloud()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        deleteAllTopics()
        extractCSVDataAndSaveToRealm()
    }
    
    func deleteAllTopics(){
        //delete locally
        Util.deleteAllTopics()
        var deletedTopicsCounter = 0
        var deletedQuestionsCounter = 0
        var deletedAnswersCounter = 0
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
                        self.dataDeletedLabel.hidden = false
                    }
                }
            }
        }
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
                        self.dataDeletedLabel.hidden = false
                    }
                }
            }
        }
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
                        self.dataDeletedLabel.hidden = false
                    }
                }
            }
        }

    }
    

    
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
    
}
