//
//  CloudLink.swift
//  TFG
//
//  Created by Johannes Berger on 07.04.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit
import Parse

///Functions to facilitate the up and downloading of data from and to the Parse server
struct CloudLink {
    
    /**
     Takes a local statistic and saves it asynchronisly to the server
     - parameters stat: statistic to save
     */
    static func syncStatisticToCloud(stat: Statistic){
        
        let cloudStat = PFObject(className: "Statistic")
        
        cloudStat["userID"] = PFUser.currentUser()?.objectId
        cloudStat["topic"] = stat.topic?.title
        cloudStat["score"] = stat.score
        cloudStat["startTime"] = stat.startTime
        cloudStat["endTime"] = stat.endTime
        
        cloudStat.saveEventually()
        print("Saving Statistic to cloud")
    }
    
    /**
     Downloads all (max 100) statistics with the current user ID from the server 
     and saves them locally in Realm
     */
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
    
    /**
     Checks if there already is a prefernce file by the current user on the server. If so it overrides that file. 
     If not it creates a new one.
     */
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
    
    /**
     Downloads the preference file of the current user and saves it to Realm.
     */
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
                        print("Error: Preferences count is 0")
                    }
                }else{
                    print("Error: Preferences is nil")
                }
            }else{
                print("Error: \(error!.userInfo["error"])")
            }
        }
    }
    
    /**
     Updates the global average locally and on the server side
     - parameter topic: the topic for which to update the value
     - parameter latestValue: the new value that is added to the GA
     */
    static func updateGlobalAverage(topic: Topic, latestValue: Double) {
            let query = PFQuery(className: "Topic")
            query.whereKey("title", equalTo: topic.title)
            query.findObjectsInBackgroundWithBlock { (objects, error) in
                if error == nil {
                    if let topicArr = objects{
                        var newValue = -1.0
                        if topicArr.count == 1{
                            let topic = topicArr.first!
                            newValue = (topic["globalAverage"] as! Double) * 0.99 + latestValue * 0.01
                            topic["globalAverage"] = newValue
                            topic.saveEventually()
                            print("Saving new global average to cloud")
                        }else{
                            print("Error: topicArr.count for topic \(topic.title) was \(topicArr.count)")
                        }
                        Util.setGlobalAverageOf(topic, newValue: newValue)
                    }
                }else{
                    print("Error: \(error!.userInfo["error"])")
                }
            }
    }
    
    //TODO: fix this
    static func syncGlobalAverageToRealm() {
        let query = PFQuery(className: "Topic")
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if error == nil {
                if let topicArr = objects{
                    for topic in topicArr{
                        if let localTopic = Util.getTopicWithTitle(topic["title"] as! String){
                        Util.setGlobalAverageOf(localTopic, newValue: topic["globalAverage"] as! Double)
                        }else{
                            print("Error: Topic with title: \(topic["title"] as! String) does not exist")
                        }
                    }
                }
            }else{
                print("Error: \(error!.userInfo["error"])")
            }
        }
    }
    
    ///Syncs all questions and all answers from the server to Realm (max 1000)
    static func syncQuestionsAndAnswersToRealm(){
        
        //get questions
        let questionQuery = PFQuery(className: "Question")
        questionQuery.limit = 1000
        questionQuery.findObjectsInBackgroundWithBlock { (objectsQ, error) in
            if error == nil {
                if let questionArr = objectsQ{
                    if questionArr.count > 0{
                        
                        //get answers
                        let answerQuery = PFQuery(className: "Answer")
                        answerQuery.limit = 1000
                        answerQuery.findObjectsInBackgroundWithBlock { (objectsA, error) in
                            if error == nil {
                                if let answerArr = objectsA{
                                    for question in questionArr{
                                        //Build new question
                                        let localQuestion = Question()
                                        localQuestion.topic = Util.getTopicWithTitle(question["topic"] as! String)!
                                        localQuestion.type = question["type"] as! String
                                        localQuestion.questionText = question["questionText"] as! String
                                        localQuestion.hint = question["hint"] as! String
                                        localQuestion.feedback = question["feedback"] as! String
                                        localQuestion.difficulty = question["difficulty"] as! Int
                                        
                                        //Append associated answers
                                        if answerArr.count > 0{
                                            for answer in answerArr{
                                                if answer["questionID"] as! String == question.objectId!{
                                                    let localAnswer = Answer()
                                                    localAnswer.associatedQuestion = localQuestion
                                                    localAnswer.answerText = answer["answerText"] as! String
                                                    localAnswer.isCorrect = answer["isCorrect"] as! Bool
                                                    
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
    
    /**
     Syncs topics with questions and answers, preferences and statistics from the server to Realm. 
     Starts with topics and only syncs the rest of the data once they are finished because much of 
     the data depends on the topics.
     */
    static func syncAllDataToRealm(){
        let topicQuery = PFQuery(className: "Topic")
        topicQuery.findObjectsInBackgroundWithBlock { (objects, error) in
            if error == nil {
                if let topicsArr = objects{
                    if topicsArr.count < 1{
                        print("Error: No topics available")
                    }else{
                        //Delete all old topics
                        Util.deleteAllTopics()
                        //Save new topics
                        for topic in topicsArr{
                            let localTopic = Topic()
                            localTopic.title = topic["title"] as! String
                            localTopic.author = topic["author"] as! String
                            localTopic.date = topic["date"] as! String
                            localTopic.globalAverage = topic["globalAverage"] as! Double
                            let newColor = MyColor()
                            newColor.red = topic["colorR"] as! Int
                            newColor.green = topic["colorG"] as! Int
                            newColor.blue = topic["colorB"] as! Int
                            localTopic.color = newColor
                            
                            realm.beginWrite()
                            realm.add(localTopic)
                            try! realm.commitWrite()
                        }
                        //Save rest of the data
                        CloudLink.syncQuestionsAndAnswersToRealm()
                        CloudLink.syncPreferencesToRealm()
                        CloudLink.syncStatisticsToRealm()
                    }
                }
            }
        }
    }
    
    /**
    Checks online connectivity
     - returns: Boolean that indicates wether the device is connected to the internet or not
    */
    static func isConnected() -> Bool {
        let status = Reach().connectionStatus()
        switch status{
        case .Unknown, .Offline:
            return false
        default:
            return true
        }
    }
    
            
}
