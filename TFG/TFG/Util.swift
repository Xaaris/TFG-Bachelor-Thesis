//
//  Util.swift
//  TFG
//
//  Created by Johannes Berger on 26.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import Foundation
import UIKit

class Util {
    
    let myGreenColor: UIColor
    let myRedColor: UIColor
    let myLightRedColor: UIColor
    let myLightYellowColor: UIColor
    let myLightGreenColor: UIColor
    
    init(){
        myGreenColor = UIColor(red: 33/255, green: 127/255, blue: 0/255, alpha: 1)
        myRedColor = UIColor(red: 127/255, green: 0/255, blue: 0/255, alpha: 1)
        myLightRedColor = UIColor(red: 127/255, green: 0/255, blue: 0/255, alpha: 0.6)
        myLightYellowColor = UIColor(red: 255/255, green: 236/255, blue: 28/255, alpha: 0.6)
        myLightGreenColor = UIColor(red: 33/255, green: 127/255, blue: 0/255, alpha: 0.6)
        
    }
    func getCurrentTopic() -> Topic? {
        let topics = realm.objects(Topic.self)
        for topic in topics{
            if topic.isSelected {
                return topic
            }
        }
        return nil
    }
    
    func getPreferences() -> Preference? {
        return realm.objects(Preference.self).first
    }
    
    func getLatestStatistic() -> Statistic? {
        let stats = realm.objects(Statistic)
        if !stats.isEmpty {
            var latestStat = stats[0]
            for stat in stats{
                if stat.date.compare(latestStat.date) == NSComparisonResult.OrderedDescending {
                    latestStat = stat
                }
            }
            return latestStat
        }else{
            return nil
        }
    }

    func getNLatestStatistics(numberOfStats: Int, topic: Topic) -> [Statistic] {
        let predicate = NSPredicate(format: "topic.title = %@ ", topic.title)
        let stats = realm.objects(Statistic).filter(predicate).sorted("date", ascending: false)
        let numberOfInstances = min(stats.count, numberOfStats)
        var retArray:[Statistic] = []
        for i in 0 ..< numberOfInstances{
            retArray.append(stats[i])
        }
        return retArray.reverse()
    }
    
    
    
    
    
    
    
}
