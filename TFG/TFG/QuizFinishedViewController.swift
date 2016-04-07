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
    }

    @IBAction func finishQuizButtonPressed(sender: AnyObject) {
        finishQuizButton.enabled = false
        revealAnswers()
        let vc = parentViewController as! PresentQuestionPageViewController
        vc.endTimeTracking()
        saveToStatistics()
    }
    
    func revealAnswers(){
        realm.beginWrite()
        for question in (Util.getCurrentTopic()?.questions)!{
            question.revealAnswers = true
            question.isLocked = true
            realm.add(question)
        }
        try! realm.commitWrite()
    }
    
    func saveToStatistics(){
        let questions = Util.getCurrentTopic()!.questions
        var numberOfCorrectAnswers:Double = 0.0
        for question in questions{
            numberOfCorrectAnswers += question.answerScore
        }
        let score = numberOfCorrectAnswers
        let vc = parentViewController as! PresentQuestionPageViewController
        let stat = Statistic()
        stat.topic = Util.getCurrentTopic()
        stat.date = NSDate()
        stat.score = score
        stat.startTime = vc.startTime
        stat.endTime = vc.endTime
        realm.beginWrite()
        realm.add(stat)
        try! realm.commitWrite()
    }

}
