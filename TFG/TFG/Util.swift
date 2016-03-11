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
        myLightRedColor = UIColor(red: 127/255, green: 0/255, blue: 0/255, alpha: 0.5)
        myLightYellowColor = UIColor(red: 255/255, green: 236/255, blue: 28/255, alpha: 0.5)
        myLightGreenColor = UIColor(red: 33/255, green: 127/255, blue: 0/255, alpha: 0.5)
        
//        myLightRedColor = UIColor(red: 250/255, green: 191/255, blue: 143/255, alpha: 1)
//        myLightYellowColor = UIColor(red: 196/255, green: 215/255, blue: 155/255, alpha: 1)
//        myLightGreenColor = UIColor(red: 253/255, green: 240/255, blue: 141/255, alpha: 1)
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
    
    
    
    
    
    
}
