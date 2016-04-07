//
//  CloudLink.swift
//  TFG
//
//  Created by Johannes Berger on 07.04.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit
import Parse

struct CloudLink {
    
    static func syncPreferencesFromRealmToCloud(){
        let query = PFQuery(className: "Preferences")
        query.whereKey("userID", equalTo: (PFUser.currentUser()?.objectId)!)
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if error == nil {
                if let preferenceArr = objects{
                    var cloudPref = PFObject(className: "Preferences")
                    if preferenceArr.count > 0{
                        cloudPref = preferenceArr.first!
                    }
                    cloudPref["userID"] = PFUser.currentUser()?.objectId
                    cloudPref["immediateFeedback"] = Util.getPreferences()!.immediateFeedback
                    cloudPref["lockSeconds"] = Util.getPreferences()!.lockSeconds
                    cloudPref.saveEventually()
                    print("Saving preferences to cloud")
                }
            }else{
                print("Error: \(error!.userInfo["error"])")
            }
        }
    }
    
    static func syncPreferencesFromCloudToRealm(){
        let query = PFQuery(className: "Preferences")
        query.whereKey("userID", equalTo: (PFUser.currentUser()?.objectId)!)
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if error == nil {
                if let preferenceArr = objects{
                    if preferenceArr.count > 0{
                        let cloudPref = preferenceArr.first!
                        let localPref = Util.getPreferences()!
                        realm.beginWrite()
                        localPref.immediateFeedback = cloudPref["immediateFeedback"] as! Bool
                        localPref.lockSeconds = cloudPref["lockSeconds"] as! Int
                        realm.add(localPref)
                        try! realm.commitWrite()
                        print("Successfully downloaded Preferences")
                    }else{
                        print("Error: Preferences count is off")
                    }
                }else{
                    print("Error: Preferences is nil")
                }
            }else{
                print("Error: \(error!.userInfo["error"])")
            }
        }
    }


}
