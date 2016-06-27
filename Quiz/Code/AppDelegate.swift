//
//  AppDelegate.swift
//  TFG
//
//  Created by Johannes Berger on 14.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit
import RealmSwift
import Parse
import Fingertips

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

//    var window: UIWindow?
    
    // For screen recording
    lazy var window: UIWindow? = {
        let fingerTips = MBFingerTipWindow.init(frame: UIScreen.mainScreen().bounds)
        fingerTips.alwaysShowTouches = true
        return fingerTips
    }()


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //realm path for debugging purposes
        //print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        //TODO: change schema version
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 3,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 3) {
                    realm.deleteAll()
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        
        // Override point for customization after application launch.
        
        //TODO: delete and test
        if realm.objects(MyColor.self).isEmpty{
            realm.beginWrite()
            let blue = MyColor(value: [64,89,129])
            let green = MyColor(value: [149,166,124])
            let red = MyColor(value: [179,48,80])
            let beige = MyColor(value: [216,184,161])
            let orange = MyColor(value: [192,134,133])
            realm.add(blue)
            realm.add(green)
            realm.add(red)
            realm.add(beige)
            realm.add(orange)
            try! realm.commitWrite()
        }
        
        //Initializing Parse
        Parse.enableLocalDatastore()
        let parseConfiguration = ParseClientConfiguration(block: { (ParseMutableClientConfiguration) -> Void in
            ParseMutableClientConfiguration.applicationId = "instragra3456789yxcvbnm"
            ParseMutableClientConfiguration.clientKey = "instragra3456789yxcvbnmdfghjkl45678cvbn"
            ParseMutableClientConfiguration.server = "https://instragra.herokuapp.com/parse"
        })
        Parse.initializeWithConfiguration(parseConfiguration)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

///Global Realm variable to be able to access the database from everywhere
let realm = try! Realm()

