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
            immediateFeedbackSwitch.on = Util().getPreferences()!.immediateFeedback
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func immediateFeedbackSwitchPressed(sender: AnyObject) {
        realm.beginWrite()
        let pref = Util().getPreferences()!
        pref.immediateFeedback = !pref.immediateFeedback
        realm.add(pref)
        try! realm.commitWrite()
    }
    
}

