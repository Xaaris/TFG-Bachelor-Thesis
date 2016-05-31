//
//  StatisticsData.swift
//  TFG
//
//  Created by Johannes Berger on 25.03.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import Foundation
import RealmSwift

/**
 Class which is used to store the statistics locally in Realm. Some values are lazyly computed
 */
class Statistic: Object{
    dynamic var topic: Topic? // to-one relationships must be optional
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

/**
 Class which is used to store the topics locally in Realm.
 A topic has associated questions, answers and statistics.
 Some values are lazyly computed
 */
class Topic: Object{
    dynamic var title = ""
    dynamic var author = ""
    dynamic var date = ""
    dynamic var isSelected = false
    dynamic var color: MyColor? // to-one relationships must be optional
    dynamic var globalAverage = 0.5
    let questions = LinkingObjects(fromType: Question.self, property: "topic")
    let stats = LinkingObjects(fromType: Statistic.self, property: "topic")
    dynamic var timeStudied: Double { //Saved in seconds
        var totalTime = 0.0
        for stat in stats {
            totalTime += stat.timeTaken
        }
        return totalTime
    }
    
    override class func primaryKey() -> String {
        return "title"
    }
}

/**
 Class which is used to store the questions locally in Realm.
 A question has associated answers.
 Some values are lazyly computed
 */
class Question: Object {
    dynamic var topic: Topic? // to-one relationships must be optional
    dynamic var type = ""
    dynamic var questionText = ""
    dynamic var hint = ""
    dynamic var feedback = ""
    dynamic var isLocked = false
    dynamic var revealAnswers = false
    dynamic var answerScore: Double {
        var tmpScore: Double = 0.0
        if type == "SingleChoice" || type == "TrueFalse"{
            for answer in answers{
                if answer.isCorrect && answer.isSelected{
                    tmpScore += 1
                }
            }
            return tmpScore
        }else{
            for answer in answers{
                if (answer.isCorrect && answer.isSelected) || (!answer.isCorrect && !answer.isSelected) {
                    tmpScore += 1
                }
            }
            return tmpScore / Double(answers.count)
        }
    }
    let answers = LinkingObjects(fromType: Answer.self, property: "associatedQuestion")
    
    override class func primaryKey() -> String {
        return "questionText"
    }
}

/**
 Class which is used to store the answers locally in Realm.
 */
class Answer: Object {
    dynamic var answerText = ""
    dynamic var isCorrect = false
    dynamic var isSelected = false
    dynamic var associatedQuestion: Question? // to-one relationships must be optional
}



/**
 Class which is used to store the preferences locally in Realm.
 */
class Preference: Object{
    dynamic var feedback = false
    dynamic var showLockButton = false
    dynamic var lockSeconds = 2
}

/**
 Class which is used to store a custom color locally in Realm.
 */
class MyColor: Object {
    dynamic var red = 0
    dynamic var green = 0
    dynamic var blue = 0
    let isAssignedTo = LinkingObjects(fromType: Topic.self, property: "color")
}


