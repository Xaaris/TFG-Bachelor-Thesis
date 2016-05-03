//
//  CloudLink.swift
//  TFG
//
//  Created by Johannes Berger on 07.04.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit
import Parse

struct CloudLink {
    
    static func syncStatisticToCloud(stat: Statistic){
        
        let cloudStat = PFObject(className: "Statistic")
        
        cloudStat["userID"] = PFUser.currentUser()?.objectId
        cloudStat["topic"] = stat.topic?.title
        cloudStat["date"] = stat.date
        cloudStat["score"] = stat.score
        cloudStat["startTime"] = stat.startTime
        cloudStat["endTime"] = stat.endTime
        
        cloudStat.saveEventually()
        print("Saving Statistic to cloud")
    }
    
    static func syncStatisticsToRealm(){
        let query = PFQuery(className: "Statistic")
        query.whereKey("userID", equalTo: (PFUser.currentUser()?.objectId)!)
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if error == nil {
                if let stats = objects{
                    for cloudStat in stats{
                        if let topic = Util.getTopicWithTitle(cloudStat["topic"] as! String){
                            realm.beginWrite()
                            let localStat = Statistic()
                            localStat.topic = topic
                            localStat.date = cloudStat["date"] as! NSDate
                            localStat.score = cloudStat["score"] as! Double
                            localStat.startTime = cloudStat["startTime"] as! NSDate
                            localStat.endTime = cloudStat["endTime"] as! NSDate
                            realm.add(localStat)
                            try! realm.commitWrite()
                        }else{
                            print("Error: Topic does not exist")
                        }
                    }
                    print("Successfully downloaded Statistics")
                }
            }else{
                print("Error: \(error!.userInfo["error"])")
            }
        }
        
    }
    
    static func syncPreferencesToCloud(){
        let query = PFQuery(className: "Preferences")
        query.whereKey("userID", equalTo: (PFUser.currentUser()?.objectId)!)
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if error == nil {
                if let preferenceArr = objects{
                    var cloudPref = PFObject(className: "Preferences")
                    if preferenceArr.count > 0{
                        cloudPref = preferenceArr.first!
                    }
                    cloudPref["userID"] = PFUser.currentUser()?.objectId
                    cloudPref["immediateFeedback"] = Util.getPreferences()!.immediateFeedback
                    cloudPref["lockSeconds"] = Util.getPreferences()!.lockSeconds
                    cloudPref.saveEventually()
                    print("Saving preferences to cloud")
                }
            }else{
                print("Error: \(error!.userInfo["error"])")
            }
        }
    }
    
    static func syncPreferencesToRealm(){
        let query = PFQuery(className: "Preferences")
        query.whereKey("userID", equalTo: (PFUser.currentUser()?.objectId)!)
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if error == nil {
                if let preferenceArr = objects{
                    if preferenceArr.count > 0{
                        let cloudPref = preferenceArr.first!
                        realm.beginWrite()
                        let localPref = Util.getPreferences()!
                        localPref.immediateFeedback = cloudPref["immediateFeedback"] as! Bool
                        localPref.lockSeconds = cloudPref["lockSeconds"] as! Int
                        realm.add(localPref)
                        try! realm.commitWrite()
                        print("Successfully downloaded Preferences")
                    }else{
                        print("Error: Preferences count is off")
                    }
                }else{
                    print("Error: Preferences is nil")
                }
            }else{
                print("Error: \(error!.userInfo["error"])")
            }
        }
    }
    
    static func updateGlobalAverage(latestValue: Double) {
        if let currentTopic = Util.getCurrentTopic(){
            let query = PFQuery(className: "GlobalAverage")
            query.whereKey("topic", equalTo: currentTopic.title)
            query.findObjectsInBackgroundWithBlock { (objects, error) in
                if error == nil {
                    if let globalAverageArr = objects{
                        var newGlobalAverage = PFObject(className: "GlobalAverage")
                        var newValue = -1.0
                        if globalAverageArr.count == 0{
                            newGlobalAverage["topic"] = currentTopic.title
                            newValue = 0.5 * 0.99 + latestValue * 0.01
                            newGlobalAverage["currentAverage"] = newValue
                        }else if globalAverageArr.count == 1{
                            newGlobalAverage = globalAverageArr.first!
                            newValue = (newGlobalAverage["currentAverage"] as! Double) * 0.99 + latestValue * 0.01
                            newGlobalAverage["currentAverage"] = newValue
                        }else{
                            print("Error: globalAverageArr.count for topic \(currentTopic.title) was \(globalAverageArr.count)")
                        }
                        newGlobalAverage["lastUpdated"] = NSDate()
                        newGlobalAverage.saveEventually()
                        print("Saving new global average to cloud")
                        Util.setGlobalAverageOf(currentTopic, date: NSDate(), newValue: newValue)
                    }
                }else{
                    print("Error: \(error!.userInfo["error"])")
                }
            }
        }else{
            print("Error: current topic was nil!")
        }
    }
    
    static func syncGlobalAverageToRealm() {
        let query = PFQuery(className: "GlobalAverage")
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if error == nil {
                if let globalAverageArr = objects{
                    for ga in globalAverageArr{
                        let topicStr = ga["topic"] as! String
                        if let topic = Util.getTopicWithTitle(topicStr){
                            let date = ga["lastUpdated"] as! NSDate
                            let score = ga["currentAverage"] as! Double
                            Util.setGlobalAverageOf(topic, date: date, newValue: score)
                        }
                    }
                }
            }else{
                print("Error: \(error!.userInfo["error"])")
            }
        }
    }
    
    static func syncTopicsToRealm(){
        let topicQuery = PFQuery(className: "Topic")
        do{
            let topicsArr = try topicQuery.findObjects()
            
            if topicsArr.count < 1{
                print("Error: No topics available")
            }else{
                Util.deleteAllTopics()
                for topic in topicsArr{
                    let localTopic = Topic()
                    localTopic.title = topic["title"] as! String
                    localTopic.author = topic["author"] as! String
                    localTopic.date = topic["date"] as! String
                    let newColor = MyColor()
                    newColor.red = topic["colorR"] as! Int
                    newColor.green = topic["colorG"] as! Int
                    newColor.blue = topic["colorB"] as! Int
                    localTopic.color = newColor
                    
                    realm.beginWrite()
                    realm.add(localTopic)
                    try! realm.commitWrite()
                }
            }
            
        }catch _ {
            print("Error: could not retrieve data from cloud")
        }
        
        
        
    }
    
    static func syncQuestionsAndAnswersToRealm(){
        
        let questionQuery = PFQuery(className: "Question")
        questionQuery.findObjectsInBackgroundWithBlock { (objectsQ, error) in
            if error == nil {
                if let questionArr = objectsQ{
                    if questionArr.count > 0{
                        
                        let answerQuery = PFQuery(className: "Answer")
                        answerQuery.findObjectsInBackgroundWithBlock { (objectsA, error) in
                            if error == nil {
                                if let answerArr = objectsA{
                                    print(questionArr)
                                    print(answerArr)
                                    for question in questionArr{
                                        let localQuestion = Question()
                                        localQuestion.topic = Util.getTopicWithTitle(question["topic"] as! String)!
                                        localQuestion.type = question["type"] as! String
                                        localQuestion.questionText = question["questionText"] as! String
                                        localQuestion.hint = question["hint"] as! String
                                        localQuestion.feedback = question["feedback"] as! String
                                        localQuestion.difficulty = question["difficulty"] as! Int
                                        
                                        if answerArr.count > 0{
                                            for answer in answerArr{
                                                if answer["questionID"] as! String == question.objectId!{
                                                    let localAnswer = Answer()
                                                    localAnswer.associatedQuestion = localQuestion
                                                    localAnswer.answerText = answer["answerText"] as! String
                                                    localAnswer.isCorrect = answer["isCorrect"] as! Bool
                                                    
                                                    //localQuestion.answers.append(localAnswer)
                                                    
                                                    realm.beginWrite()
                                                    realm.add(localAnswer)
                                                    try! realm.commitWrite()
                                                }
                                            }
                                        }else{
                                            print("Error: No answers available")
                                        }
                                        
                                        realm.beginWrite()
                                        realm.add(localQuestion)
                                        try! realm.commitWrite()
                                    }
                                }
                            }else{
                                print("Error: No questions available")
                            }
                        }
                    }
                }
            }
        }
    }
    
    static func syncAllDataToRealm(){
        let topicQuery = PFQuery(className: "Topic")
        topicQuery.findObjectsInBackgroundWithBlock { (objects, error) in
            if error == nil {
                if let topicsArr = objects{
                    if topicsArr.count < 1{
                        print("Error: No topics available")
                    }else{
                        Util.deleteAllTopics()
                        for topic in topicsArr{
                            let localTopic = Topic()
                            localTopic.title = topic["title"] as! String
                            localTopic.author = topic["author"] as! String
                            localTopic.date = topic["date"] as! String
                            let newColor = MyColor()
                            newColor.red = topic["colorR"] as! Int
                            newColor.green = topic["colorG"] as! Int
                            newColor.blue = topic["colorB"] as! Int
                            localTopic.color = newColor
                            
                            realm.beginWrite()
                            realm.add(localTopic)
                            try! realm.commitWrite()
                        }
                    
                        CloudLink.syncQuestionsAndAnswersToRealm()
                        CloudLink.syncPreferencesToRealm()
                        CloudLink.syncStatisticsToRealm()
                        CloudLink.syncGlobalAverageToRealm()
                    }
                }
            }
        }
    }
    
            
}
