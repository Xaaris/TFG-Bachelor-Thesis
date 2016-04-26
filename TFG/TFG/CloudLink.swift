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
                        Util.setGlobalAverageOf(currentTopic, newValue: newValue)
                    }
                }else{
                    print("Error: \(error!.userInfo["error"])")
                }
            }
        }else{
            print("Error: current topic was nil!")
        }
    }
    
        
        
        
}
