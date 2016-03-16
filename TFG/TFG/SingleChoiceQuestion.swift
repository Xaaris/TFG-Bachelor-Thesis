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
        if !currentQuestionDataSet[pageIndex].hint.isEmpty{
            parentViewController!.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Hint", style: .Plain, target: self, action: "showHint")
        }else{
            let disabledButton = UIBarButtonItem(title: "Hint", style: .Plain, target: self, action: "showHint")
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
            //TODO: implement timer here
            let answer = question.answers[indexPath.row]
            if Util().getPreferences()!.immediateFeedback{
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
                    lastSelectedCell = tableView.cellForRowAtIndexPath(indexPath) as! AnswerCell
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
        let aSelector : Selector = "updateLockProgress"
        timer.tolerance = 0.1
        timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: aSelector, userInfo: nil, repeats: true)
    }
    
    func lockQuestion(){
        print("Question should lock now")
        let question = currentQuestionDataSet[pageIndex]
        realm.beginWrite()
        question.isLocked = true
        realm.add(question)
        try! realm.commitWrite()
        answerTableView.reloadData()
    
    }
    
    func updateLockProgress(){
        let progressView = lastSelectedCell.AnswerSelectImage

        lockProgress += 0.05
        print(lockProgress)
        //Not working yet
        progressView.progress = lockProgress
        if lockProgress >= 1 {
            lockQuestion()
            stopTimer()
            progressView.progress = 1
        }
        
    }
    
    func stopTimer(){
        timer.invalidate()
        lockProgress = 0.0
    }
    

}

