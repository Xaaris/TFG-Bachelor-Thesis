//
//  Util.swift
//  TFG
//
//  Created by Johannes Berger on 26.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import Foundation
import UIKit

struct Util {
    
    static let myGreenColor: UIColor = UIColor(red: 33/255, green: 127/255, blue: 0/255, alpha: 1)
    static let myRedColor: UIColor = UIColor(red: 127/255, green: 0/255, blue: 0/255, alpha: 1)
    static let myLightRedColor: UIColor = UIColor(red: 127/255, green: 0/255, blue: 0/255, alpha: 0.6)
    static let myLightYellowColor: UIColor = UIColor(red: 255/255, green: 236/255, blue: 28/255, alpha: 0.6)
    static let myLightGreenColor: UIColor = UIColor(red: 33/255, green: 127/255, blue: 0/255, alpha: 0.6)
    
    
    static func getCurrentTopic() -> Topic? {
        let topics = realm.objects(Topic.self)
        for topic in topics{
            if topic.isSelected {
                return topic
            }
        }
        return nil
    }
    
    static func getTopicWithTitle(title: String) -> Topic? {
        let topics = realm.objects(Topic.self)
        for topic in topics{
            if topic.title == title {
                return topic
            }
        }
        return nil
    }

    
    static func getPreferences() -> Preference? {
        return realm.objects(Preference.self).first
    }
    
    static func getLatestStatistic() -> Statistic? {
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

    static func getNLatestStatistics(numberOfStats: Int, topic: Topic) -> [Statistic] {
        let predicate = NSPredicate(format: "topic.title = %@ ", topic.title)
        let stats = realm.objects(Statistic).filter(predicate).sorted("date", ascending: false)
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
    
    static func deleteAllStatistics(){
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
    
    static func deleteAllData(){
        //TODO: add topics
        deleteAllStatistics()
        deletePreferences()
    }
    
    
    
    
    
    
}
