//
//  SecondViewController.swift
//  TFG
//
//  Created by Johannes Berger on 14.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit

class PreferencesViewController: UIViewController {
    
    
    @IBOutlet weak var immediateFeedbackSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Preferences View")
        if !realm.objects(Preference.self).isEmpty{
            immediateFeedbackSwitch.on = realm.objects(Preference.self).first!.immediateFeedback
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func immediateFeedbackSwitchPressed(sender: AnyObject) {
        realm.beginWrite()
        if let pref = realm.objects(Preference.self).first{
            pref.immediateFeedback = !pref.immediateFeedback
            realm.add(pref)
        }else{
            let pref = Preference()
            pref.immediateFeedback = immediateFeedbackSwitch.on
            realm.add(pref)
        }
        try! realm.commitWrite()
    }
    
}

