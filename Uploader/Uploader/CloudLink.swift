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
    

    
    
    
   
    
    
    
}
