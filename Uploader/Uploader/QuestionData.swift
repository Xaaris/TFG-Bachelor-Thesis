//
//  Question.swift
//  TFG
//
//  Created by Johannes Berger on 21.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import Foundation
import RealmSwift

class Topic: Object{
    dynamic var title = ""
    dynamic var author = ""
    dynamic var date = ""
    dynamic var isSelected = false
    dynamic var color: MyColor? // to-one relationships must be optional
    var questions: [Question] {
        return linkingObjects(Question.self, forProperty: "topic")
    }
    dynamic var timeStudied: Double { //Saved in seconds
        var totalTime = 0.0
        let stats = linkingObjects(Statistic.self, forProperty: "topic")
        for stat in stats {
            totalTime += stat.timeTaken
        }
        return totalTime
    }
    
    override class func primaryKey() -> String {
        return "title"
    }
}

class Question: Object {
    dynamic var topic: Topic? // to-one relationships must be optional
    dynamic var type = ""
    dynamic var questionText = ""
    dynamic var hint = ""
    dynamic var feedback = ""
    dynamic var difficulty = 0
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
    let answers = List<Answer>()
    let tags = List<Tag>()
    
    override class func primaryKey() -> String {
        return "questionText"
    }
}

class Answer: Object {
    dynamic var answerText = ""
    dynamic var isCorrect = false
    dynamic var isSelected = false
    dynamic var associatedQuestion: Question? // to-one relationships must be optional
}

class Tag: Object {
    
    dynamic var tagText = ""
    var associatedQuestions: [Question] {
        // Realm doesn't persist this property because it only has a getter defined
        // Define "associatedQuestions" as the inverse relationship to Question.tags
        return linkingObjects(Question.self, forProperty: "tags")
    }
    
    override class func primaryKey() -> String {
        return "tagText"
    }
}