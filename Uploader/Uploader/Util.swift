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
    
    //Predefined colors
    static let myGreenColor: UIColor = UIColor(red: 33/255, green: 127/255, blue: 0/255, alpha: 1)
    static let myRedColor: UIColor = UIColor(red: 127/255, green: 0/255, blue: 0/255, alpha: 1)
    static let myLightRedColor: UIColor = UIColor(red: 127/255, green: 0/255, blue: 0/255, alpha: 0.6)
    static let myLightYellowColor: UIColor = UIColor(red: 255/255, green: 236/255, blue: 28/255, alpha: 0.6)
    static let myLightGreenColor: UIColor = UIColor(red: 33/255, green: 127/255, blue: 0/255, alpha: 0.6)
    
    /**
     Returns currently selected topic or nil if none is selected
     - returns: the selected topic or nil
     */
    static func getCurrentTopic() -> Topic? {
        let topics = realm.objects(Topic.self)
        for topic in topics{
            if topic.isSelected {
                return topic
            }
        }
        return nil
    }
    
    /**
     Returns the topic with the specified name or nil if no topic exists with taht name
     - parameter title: title of the topic to be found
     - returns: the topic or nil
     */
    static func getTopicWithTitle(title: String) -> Topic? {
        let topics = realm.objects(Topic.self)
        for topic in topics{
            if topic.title == title {
                return topic
            }
        }
        return nil
    }
    
    /**
     Returns a new MyColor which is not yet assigned to a topic.
     It chooses from a pool of predefined, not yet assigned colors before it generates random new ones
     - returns: a new color
     */
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
    
    /**
     Delets the the specified topic and all its questions and answers locally
     - parameter topic: the topic which should be deleted
     */
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
    }
    
    ///Delets all topics locally
    static func deleteAllTopics(){
        let topics = realm.objects(Topic.self)
        for topic in topics{
            deleteTopic(topic)
        }
    }
    
  }
