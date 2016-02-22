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
    var answerContainer: AnswerContainer? = AnswerContainer()
    var tagContainer: TagContainer? = TagContainer()
    
    override class func primaryKey() -> String {
        return "questionText"
    }
}

class AnswerContainer: Object {
    let answers = List<Answer>()
}

class Answer: Object {
    
    dynamic var text = ""
    dynamic var isCorrect = false
    
    convenience required init(text: String, isCorrect: Bool){
        self.init()
        self.text = text
        self.isCorrect = isCorrect
    }

}

class TagContainer: Object {
    let tags = List<Tag>()
}

class Tag: Object {
    
    dynamic var tag = ""
    
    convenience required init(tag: String){
        self.init()
        self.tag = tag
    }
    
}



