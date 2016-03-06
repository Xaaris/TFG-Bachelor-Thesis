//
//  QuizFinishedViewController.swift
//  TFG
//
//  Created by Johannes Berger on 26.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit

class QuizFinishedViewController: PageViewContent{
    
    @IBOutlet weak var finishQuizButton: UIButton!
    override func viewWillAppear(animated: Bool) {
        parentViewController!.navigationItem.rightBarButtonItem = nil
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        revealAnswers()
    }

    @IBAction func finishQuizButtonPressed(sender: AnyObject) {
        finishQuizButton.enabled = false
        revealAnswers()
    }
    
    func revealAnswers(){
        realm.beginWrite()
        for question in (Util().getCurrentTopic()?.questions)!{
            question.revealAnswers = true
            question.isLocked = true
            realm.add(question)
        }
        try! realm.commitWrite()
    }

}
