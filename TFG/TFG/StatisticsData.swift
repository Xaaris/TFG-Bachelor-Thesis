//
//  StatisticsData.swift
//  TFG
//
//  Created by Johannes Berger on 25.03.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import Foundation
import RealmSwift

class Statistic: Object{
    dynamic var topic: Topic? // to-one relationships must be optional
    dynamic var date = NSDate()
    dynamic var numberOfQuestions: Int {
        if topic != nil {
            return topic!.questions.count
        }else{
            return 0
        }
    }
    dynamic var score = 0.0
    dynamic var percentageScore: Double {
        if numberOfQuestions != 0 {
            return (score / Double(numberOfQuestions)) * 100
        }else{
            return 0
        }
    }
    dynamic var startTime = NSDate()
    dynamic var endTime = NSDate()
    
    dynamic var timeTaken: Double {
        return endTime.timeIntervalSinceDate(startTime)
    }
    
}

class GlobalAverage: Object {
    dynamic var topic: Topic? // to-one relationships must be optional
    dynamic var lastUpdated = NSDate()
    dynamic var currentAverage = 0.5
}

