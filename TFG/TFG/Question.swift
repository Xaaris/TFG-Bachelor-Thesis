//
//  Question.swift
//  TFG
//
//  Created by Johannes Berger on 21.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import Foundation
import RealmSwift

class Question: Object {
    dynamic var title = ""
    dynamic var author = ""
    dynamic var date = ""
    dynamic var type = ""
    dynamic var questionText = ""
    dynamic var hint = ""
    dynamic var feedback = ""
    dynamic var difficulty = 0
    var answers = List<Answer>()
    let tags = List<Tag>()
    
    override class func primaryKey() -> String {
        return "questionText"
    }
}

class Answer: Object {
    
    dynamic var answerText = ""
    dynamic var isCorrect = false
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



