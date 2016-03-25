//
//  SingleChoiceQuestion.swift
//  TFG
//
//  Created by Johannes Berger on 01.03.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit


class SingleChoiceQuestion: QuestionContentViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var answerTableView: UITableView!
    
    var timer = NSTimer()
    var lockProgress = 0.0
    var lastSelectedCell = AnswerCell()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        answerTableView.delegate = self
        answerTableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        answerTableView.reloadData()
        let aSelector : Selector = #selector(MultiChoiceQuestion.showHint)
        if !currentQuestionDataSet[pageIndex].hint.isEmpty{
            parentViewController!.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Hint", style: .Plain, target: self, action: aSelector)
        }else{
            let disabledButton = UIBarButtonItem(title: "Hint", style: .Plain, target: self, action: aSelector)
            disabledButton.enabled = false
            parentViewController!.navigationItem.rightBarButtonItem = disabledButton
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentQuestionDataSet[pageIndex].answers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AnswerCell", forIndexPath: indexPath) as! AnswerCell
        // Configure the cell...
        let question = currentQuestionDataSet[pageIndex]
        let answer = question.answers[indexPath.row]
        if question.revealAnswers{
            if answer.isSelected && answer.isCorrect{
                cell.AnswerSelectImage.image = UIImage(named: singleChoiceStr + correctStr)
            }else if answer.isSelected && !answer.isCorrect{
                cell.AnswerSelectImage.image = UIImage(named: singleChoiceStr + wrongStr)
            }else{
                cell.AnswerSelectImage.image = UIImage(named: singleChoiceStr + lockedStr)
            }
            if answer.isCorrect{
                cell.AnswerTextLabel.textColor = Util().myGreenColor
            }else{
                cell.AnswerTextLabel.textColor = Util().myRedColor
            }
        }else{
            if question.isLocked{
                if answer.isSelected{
                    cell.AnswerSelectImage.image = UIImage(named: singleChoiceStr + lockedStr + selectedStr)
                }else{
                    cell.AnswerSelectImage.image = UIImage(named: singleChoiceStr + lockedStr)
                }
            }else{
                if answer.isSelected{
                    cell.AnswerSelectImage.image = UIImage(named: singleChoiceStr + selectedStr)
                }else{
                    cell.AnswerSelectImage.image = UIImage(named: singleChoiceStr)
                }
            }
        }
        cell.AnswerTextLabel.text = question.answers[indexPath.row].answerText
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let question = currentQuestionDataSet[pageIndex]
        if !question.isLocked{
            let answer = question.answers[indexPath.row]
            if Util().getPreferences()!.immediateFeedback{
                if lastSelectedCell.progressView != nil {
                    lastSelectedCell.progressView.progress = 0
                }
                lastSelectedCell = tableView.cellForRowAtIndexPath(indexPath) as! AnswerCell
                stopTimer()
                realm.beginWrite()
                //deselect answer if is checked
                if answer.isSelected{
                    answer.isSelected = false
                }else{
                    for ans in question.answers{
                        ans.isSelected = false
                    }
                    answer.isSelected = true
                    startTimer()
                }
                realm.add(answer)
                realm.add(question)
                try! realm.commitWrite()

            }else{
                realm.beginWrite()
                //deselect answer if is checked
                if answer.isSelected{
                    answer.isSelected = false
                }else{
                    //deselect all answers
                    for ans in question.answers{
                        ans.isSelected = false
                    }
                    answer.isSelected = true
                }
                realm.add(answer)
                realm.add(question)
                try! realm.commitWrite()
            }
            tableView.reloadData()
        }
    }
    
    func showHint(){
        let hintStr = currentQuestionDataSet[pageIndex].hint
        let alertController = UIAlertController(title: "Hint", message: hintStr, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showFeedback(){
        let FeedbackStr = currentQuestionDataSet[pageIndex].feedback
        let alertController = UIAlertController(title: "Feedback", message: FeedbackStr, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Got it", style: .Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    func startTimer(){
        timer = NSTimer()
        let aSelector : Selector = #selector(SingleChoiceQuestion.updateLockProgress)
        timer.tolerance = 0.1
        timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: aSelector, userInfo: nil, repeats: true)
    }
    
    func lockQuestion(){
        let question = currentQuestionDataSet[pageIndex]
        realm.beginWrite()
        question.isLocked = true
        question.revealAnswers = true
        realm.add(question)
        try! realm.commitWrite()
        answerTableView.reloadData()
        if question.answerScore < 1{
            showFeedback()
        }
    
    }
    
    func updateLockProgress(){
        let progView = lastSelectedCell.progressView
        lockProgress += 0.05 / Double(Util().getPreferences()!.lockSeconds)
        progView.progress = lockProgress
        if lockProgress >= 1 {
            lockQuestion()
            stopTimer()
            progView.progress = 0
        }
        
    }
    
    func stopTimer(){
        if lastSelectedCell.progressView != nil {
            let progView = lastSelectedCell.progressView
            timer.invalidate()
            lockProgress = 0.0
            progView.progress = lockProgress
        }
    }
    

}

