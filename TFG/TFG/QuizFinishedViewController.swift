//
//  QuizFinishedViewController.swift
//  TFG
//
//  Created by Johannes Berger on 26.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit

/**
 The last (right most) of the "cards" displayed by the pageViewController.
 It displays a simple prompt telling the user that he/she has reached the end of the quiz.
 An Exit button is displayed that will bring the user to the results screen
 */
class QuizFinishedViewController: PageViewContent{
    
    @IBOutlet weak var finishQuizButton: UIButton!
    
    ///Delets the hint button in the top right corner
    override func viewWillAppear(animated: Bool) {
        parentViewController!.navigationItem.rightBarButtonItem = nil
    }

    ///Initiates the saving process and starts a segue to the results view
    @IBAction func finishQuizButtonPressed(sender: AnyObject) {
        finishQuizButton.enabled = false
        revealAnswers()
        let vc = parentViewController as! PresentQuestionPageViewController
        vc.endTimeTracking()
        saveStatisticsToRealmAndCloud()
    }
    
    ///Lock all questions and set answers to be revealed
    func revealAnswers(){
        realm.beginWrite()
        for question in (Util.getCurrentTopic()?.questions)!{
            question.revealAnswers = true
            question.isLocked = true
            realm.add(question)
        }
        try! realm.commitWrite()
    }
    
    ///Prepares and saves locally the new statistic. Also initiates the process of saving it to the cloud (async)
    func saveStatisticsToRealmAndCloud(){
        let questions = Util.getCurrentTopic()!.questions
        //Claculate score
        var numberOfCorrectAnswers:Double = 0.0
        for question in questions{
            numberOfCorrectAnswers += question.answerScore
        }
        let vc = parentViewController as! PresentQuestionPageViewController
        let stat = Statistic()
        if let currentTopic = Util.getCurrentTopic(){
            stat.topic = currentTopic
            stat.score = numberOfCorrectAnswers
            stat.startTime = vc.startTime
            stat.endTime = vc.endTime
            realm.beginWrite()
            realm.add(stat)
            try! realm.commitWrite()
            
            //save to cloud
            CloudLink.syncStatisticToCloud(stat)
            CloudLink.updateGlobalAverage(stat.percentageScore / 100)
        }else{
            print("Error: Current Topic was nil")
        }
    }

}
