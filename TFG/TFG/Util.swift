//
//  Util.swift
//  TFG
//
//  Created by Johannes Berger on 26.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import Foundation
import UIKit
import Parse

///Utility class
struct Util {
    
    //Predefined colors
    static let myGreenColor: UIColor = UIColor(red: 33/255, green: 127/255, blue: 0/255, alpha: 1)
    static let myRedColor: UIColor = UIColor(red: 127/255, green: 0/255, blue: 0/255, alpha: 1)
    static let myLightRedColor: UIColor = UIColor(red: 127/255, green: 0/255, blue: 0/255, alpha: 0.6)
    static let myLightYellowColor: UIColor = UIColor(red: 255/255, green: 236/255, blue: 28/255, alpha: 0.6)
    static let myLightGreenColor: UIColor = UIColor(red: 33/255, green: 127/255, blue: 0/255, alpha: 0.6)
    
    /**
     Returns currently selected topic or nil if none is selected
     - returns: the selected topic or nil
     */
    static func getCurrentTopic() -> Topic? {
        let topics = realm.objects(Topic.self)
        for topic in topics{
            if topic.isSelected {
                return topic
            }
        }
        return nil
    }
    
    /**
     Returns the topic with the specified name or nil if no topic exists with taht name
     - parameter title: title of the topic to be found
     - returns: the topic or nil
     */
    static func getTopicWithTitle(title: String) -> Topic? {
        let topics = realm.objects(Topic.self)
        for topic in topics{
            if topic.title == title {
                return topic
            }
        }
        return nil
    }
    
    /**
     Returns the current user name or nil if no user is logged in
     - returns: the user name or nil
     */
    static func getCurrentUserName() -> String? {
        return PFUser.currentUser()?["username"] as? String
    }
    
    /**
     Returns the current users preferences or nil if they dont exist
     - returns: the preferences or nil
     */
    static func getPreferences() -> Preference? {
        return realm.objects(Preference.self).first
    }
    
    /**
     Returns the latest statistic (newest date) or nil if none exists
     - returns: a statistic or nil
     */
    static func getLatestStatistic() -> Statistic? {
        let stats = realm.objects(Statistic)
        if !stats.isEmpty {
            var latestStat = stats[0]
            for stat in stats{
                if stat.startTime.compare(latestStat.startTime) == NSComparisonResult.OrderedDescending {
                    latestStat = stat
                }
            }
            return latestStat
        }else{
            return nil
        }
    }
    
    static func getNLatestStatistics(numberOfStats: Int) -> [Statistic] {
        let stats = realm.objects(Statistic).sorted("startTime", ascending: false)
        let numberOfInstances = min(stats.count, numberOfStats)
        var retArray:[Statistic] = []
        for i in 0 ..< numberOfInstances{
            retArray.append(stats[i])
        }
        return retArray.reverse()
    }
    
    static func getNLatestStatisticsOfTopic(numberOfStats: Int, topic: Topic) -> [Statistic] {
        let predicate = NSPredicate(format: "topic.title = %@ ", topic.title)
        let stats = realm.objects(Statistic).filter(predicate).sorted("startTime", ascending: false)
        let numberOfInstances = min(stats.count, numberOfStats)
        var retArray:[Statistic] = []
        for i in 0 ..< numberOfInstances{
            retArray.append(stats[i])
        }
        return retArray.reverse()
    }
    
    static func getUnassignedColor() -> MyColor{
        let colors = realm.objects(MyColor)
        for color in colors {
            if color.isAssignedTo.isEmpty {
                return color
            }
        }
        // create random new color
        let newColor = MyColor()
        newColor.red = Int(arc4random_uniform(256))
        newColor.green = Int(arc4random_uniform(256))
        newColor.blue = Int(arc4random_uniform(256))
        realm.beginWrite()
        realm.add(newColor)
        try! realm.commitWrite()
        return newColor
    }
    
    static func deleteStatisticsLocally(){
        let allStatistics = realm.objects(Statistic)
        try! realm.write {
            realm.delete(allStatistics)
        }
    }
    
    static func deleteAllStatistics(){
        let query = PFQuery(className: "Statistic")
        query.whereKey("userID", equalTo: (PFUser.currentUser()?.objectId)!)
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if error == nil {
                if let statisticsArr = objects{
                    for stat in statisticsArr{
                        stat.deleteEventually()
                    }
                    print("Statistics successfully deleted")
                }else{
                    print("Error: Statistic is nil")
                }
            }else{
                print("Error: \(error!.userInfo["error"])")
            }
        }
        let allStatistics = realm.objects(Statistic)
        try! realm.write {
            realm.delete(allStatistics)
        }
    }
    
    static func deletePreferences(){
        let pref = realm.objects(Preference)
        try! realm.write {
            realm.delete(pref)
        }
    }
    
    static func deleteTopic(topic: Topic){
        try! realm.write {
            realm.delete(topic)
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
        //delete Statistics without associated topic
        let stats = realm.objects(Statistic.self)
        for stat in stats{
            if stat.topic == nil {
                try! realm.write {
                    realm.delete(stat)
                }
            }
        }
    }
    
    static func deleteAllTopics(){
        let topics = realm.objects(Topic.self)
        for topic in topics{
            deleteTopic(topic)
        }
    }
    
    static func deleteUserData(){
        //TODO: add topics?
        deleteStatisticsLocally()
        deletePreferences()
    }
    
    static func setGlobalAverageOf(topic: Topic, newValue: Double){
        realm.beginWrite()
        topic.globalAverage = newValue
        realm.add(topic)
        try! realm.commitWrite()
    }
    
    
    
    
}
