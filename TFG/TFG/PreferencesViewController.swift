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
    @IBOutlet weak var secondsBeforeLockLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    @IBOutlet weak var lockSecondsSlider: UISlider!
    
    var pref: Preference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Preferences View")
        pref = Util().getPreferences()!
        immediateFeedbackSwitch.on = pref.immediateFeedback
        enableLockSecondsSlider(pref.immediateFeedback)
        lockSecondsSlider.value = Float(pref.lockSeconds)
        secondsLabel.text = String(pref.lockSeconds)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func immediateFeedbackSwitchPressed(sender: AnyObject) {
        realm.beginWrite()
        pref.immediateFeedback = !pref.immediateFeedback
        realm.add(pref)
        try! realm.commitWrite()
        enableLockSecondsSlider(pref.immediateFeedback)
    }
    
    @IBAction func lockSecondsSliderValueDidChange(sender: AnyObject) {
        sender.setValue(Float(lroundf(lockSecondsSlider.value)), animated: true)
        secondsLabel.text = String(Int(lockSecondsSlider.value))
        realm.beginWrite()
        pref.lockSeconds = Int(lockSecondsSlider.value)
        realm.add(pref)
        try! realm.commitWrite()
    }
    
    func enableLockSecondsSlider(enable: Bool){
        secondsBeforeLockLabel.enabled = enable
        secondsLabel.enabled = enable
        lockSecondsSlider.enabled = enable
    }
    
    @IBAction func deleteStatisticsButtonPressed(sender: AnyObject) {
        
        let alertController = UIAlertController(title: "Delete Statistics?", message:
            "Are you sure you want to delete all statistics? This can not be undone!", preferredStyle: UIAlertControllerStyle.Alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
            self.deleteAllStatistics()
        }
        alertController.addAction(deleteAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func deleteAllStatistics(){
        let allStatistics = realm.objects(Statistic)
        try! realm.write {
            realm.delete(allStatistics)
        }
    }
}

