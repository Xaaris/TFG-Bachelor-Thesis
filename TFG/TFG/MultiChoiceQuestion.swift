//
//  MultiChoiceQuestion.swift
//  TFG
//
//  Created by Johannes Berger on 01.03.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit

class MultiChoiceQuestion: QuestionContentViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var answerTableView: UITableView!
    @IBOutlet weak var lockButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        answerTableView.delegate = self
        answerTableView.dataSource = self
        updateLockedButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        startTimer()
        let aSelector : Selector = #selector(MultiChoiceQuestion.showHint)
        if !currentQuestionDataSet[pageIndex].hint.isEmpty{
            parentViewController!.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Hint", style: .Plain, target: self, action: aSelector)
        }else{
            let disabledButton = UIBarButtonItem(title: "Hint", style: .Plain, target: self, action: aSelector)
            disabledButton.enabled = false
            parentViewController!.navigationItem.rightBarButtonItem = disabledButton
        }
    }
    
    func updateLockedButton(){
        //enable the lock button if answer is not locked
        //due to problems with realm multithreading
        if Util.getPreferences()!.immediateFeedback{
            lockButton.hidden = false
            if currentQuestionDataSet[pageIndex].isLocked{
                lockButton.enabled = false
            }else{
                lockButton.enabled = true
            }
        }else{
            lockButton.hidden = true
        }
        
    }
    
    func startTimer(){
        var timer = NSTimer()
        let aSelector : Selector = #selector(MultiChoiceQuestion.updateLockedButton)
        timer.tolerance = 0.05
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: aSelector, userInfo: nil, repeats: false)
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
                cell.AnswerSelectImage.image = UIImage(named: multiChoiceStr + correctStr)
            }else if answer.isSelected && !answer.isCorrect{
                cell.AnswerSelectImage.image = UIImage(named: multiChoiceStr + wrongStr)
            }else{
                cell.AnswerSelectImage.image = UIImage(named: multiChoiceStr + lockedStr)
            }
            if answer.isCorrect{
                cell.AnswerTextLabel.textColor = Util.myGreenColor
            }else{
                cell.AnswerTextLabel.textColor = Util.myRedColor
            }
        }else{
            if question.isLocked{
                if answer.isSelected{
                    cell.AnswerSelectImage.image = UIImage(named: multiChoiceStr + lockedStr + selectedStr)
                }else{
                    cell.AnswerSelectImage.image = UIImage(named: multiChoiceStr + lockedStr)
                }
            }else{
                if answer.isSelected{
                    cell.AnswerSelectImage.image = UIImage(named: multiChoiceStr + selectedStr)
                }else{
                    cell.AnswerSelectImage.image = UIImage(named: multiChoiceStr)
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
            realm.beginWrite()
            answer.isSelected = !answer.isSelected
            realm.add(answer)
            try! realm.commitWrite()
            tableView.reloadData()
        }
    }
    
    @IBAction func lockButtonPressed(sender: AnyObject) {
        lockButton.enabled = false
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
    
    func showHint(){
        let hintStr = currentQuestionDataSet[pageIndex].hint
        let alertController = UIAlertController(title: "Hint", message: hintStr, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showFeedback(){
        let FeedbackStr = currentQuestionDataSet[pageIndex].feedback
        if !FeedbackStr.isEmpty {
            let alertController = UIAlertController(title: "Feedback", message: FeedbackStr, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Got it", style: .Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

}
