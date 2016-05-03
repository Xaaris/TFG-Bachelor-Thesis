//
//  Util.swift
//  TFG
//
//  Created by Johannes Berger on 26.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import Foundation
import UIKit
import Parse

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
    

    
    
    static func deleteTopic(topic: Topic){
        try! realm.write {
            realm.delete(topic)
        }
        //delete questions without associated topics
        let questions = realm.objects(Question.self)
        for question in questions{
            if question.topic == nil{
                try! realm.write {
                    realm.delete(question)
                }
            }
        }
        //delete answers without associated questions
        let answers = realm.objects(Answer.self)
        for answer in answers{
            if answer.associatedQuestion == nil{
                try! realm.write {
                    realm.delete(answer)
                }
            }
        }
        //delete tags without associated questions
        let tags = realm.objects(Tag.self)
        for tag in tags{
            if tag.associatedQuestions.isEmpty {
                try! realm.write {
                    realm.delete(tag)
                }
            }
        }
        
    }
    
    static func deleteAllTopics(){
        let topics = realm.objects(Topic.self)
        for topic in topics{
            deleteTopic(topic)
        }
    }
    
  }
