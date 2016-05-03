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

    @IBOutlet weak var dataLoadedLabel: UILabel!
    
    @IBOutlet weak var topicsCounterLabel: UILabel!
    @IBOutlet weak var questionsCounterLabel: UILabel!
    @IBOutlet weak var answersCounterLabel: UILabel!
    
    var topicCounter = 0
    var questionCounter = 0
    var answerCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        extractCSVDataAndSaveToRealm()
        saveAllTopicsToCloud()
    }

    func extractCSVDataAndSaveToRealm() {
        let importer = ImportAndSaveHelper()
        importer.loadAndSave("Sample1")
        importer.loadAndSave("Sample2")
        dataLoadedLabel.hidden = false
    }
    
    func saveAllTopicsToCloud(){
        let topics = realm.objects(Topic.self)
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
                                    self.topicsCounterLabel.text = "Topics: \(self.topicCounter)"
                                    let topicID = cloudTopic.objectId
                                    for question in topic.questions{
                                        let cloudQuestion = PFObject(className: "Question")
                                        cloudQuestion["topicID"] = topicID
                                        cloudQuestion["topic"] = question.topic!.title
                                        cloudQuestion["type"] = question.type
                                        cloudQuestion["questionText"] = question.questionText
                                        cloudQuestion["hint"] = question.hint
                                        cloudQuestion["feedback"] = question.feedback
                                        cloudQuestion["difficulty"] = question.difficulty
                                        cloudQuestion.saveInBackgroundWithBlock({ (success, error) in
                                            if error == nil {
                                                self.questionCounter += 1
                                                self.questionsCounterLabel.text = "Questions: \(self.questionCounter)"
                                                let questionID = cloudQuestion.objectId
                                                for answer in question.answers{
                                                    let cloudAnswer = PFObject(className: "Answer")
                                                    cloudAnswer["questionID"] = questionID
                                                    cloudAnswer["answerText"] = answer.answerText
                                                    cloudAnswer["isCorrect"] = answer.isCorrect
                                                    cloudAnswer.saveInBackgroundWithBlock({ (success, error) in
                                                        if error == nil {
                                                            self.answerCounter += 1
                                                            self.answersCounterLabel.text = "Answers: \(self.answerCounter)"
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
