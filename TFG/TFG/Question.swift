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
    var tags: Tags? = Tags()
}

class AnswerContainer: Object {
    let answers = List<Answer>()
}

class Answer: Object {
    dynamic var text = ""
    dynamic var isCorrect = false
}

class Tags: Object {
    let tags = List<Tag>()
}

class Tag: Object {
    dynamic var tag = ""
}