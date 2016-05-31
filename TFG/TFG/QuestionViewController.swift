//
//  QuestionViewController.swift
//  TFG
//
//  Created by Johannes Berger on 01.06.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit

/**
 Parent class for the question cards
 */
class QuestionViewController: PageViewContent, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var questionTextLabel: UILabel?
    @IBOutlet weak var lockButton: UIButton!
    @IBOutlet weak var answerTableView: UITableView!
    
    var isMultiChoiceQuestion = false
    var question: Question!
    
    //Vars for single choice progress view
    var timer = NSTimer()
    var lockProgress = 0.0
    var lastSelectedCell: AnswerCell?
    
    let multiChoiceStr = "AnswerChooserMultiChoice"
    let singleChoiceStr = "AnswerChooserSingelChoice"
    let selectedStr = "Selected"
    let lockedStr = "Locked"
    let correctStr = "Correct"
    let wrongStr = "Wrong"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        answerTableView.delegate = self
        answerTableView.dataSource = self
        question = currentQuestionDataSet[pageIndex]
        if currentQuestionDataSet[pageIndex].type == "MultipleChoice"{
            isMultiChoiceQuestion = true
        }else{
            isMultiChoiceQuestion = false
        }
        updateContent()
    }
    
    ///Reloads data and shows or hides "hint" button depending on wether there is a hint
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateLockedButton()
        answerTableView.reloadData()
        let aSelector : Selector = #selector(QuestionViewController.showHint)
        if !question.hint.isEmpty{
            parentViewController!.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "hint_button"), style: .Plain, target: self, action: aSelector)
            
        }else{
            let disabledButton = UIBarButtonItem(image: UIImage(named: "hint_button_inactive"), style: .Plain, target: self, action: aSelector)
            disabledButton.enabled = false
            parentViewController!.navigationItem.rightBarButtonItem = disabledButton
        }
    }
    
    ///Locks the question if a user swipes further
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if lastSelectedCell != nil && Util.getPreferences()!.showLockButton{
            stopTimer()
            lockQuestion(false)
        }
    }
    
    ///Enables/Disables/shows or hide the lock button depending on the context
    func updateLockedButton(){
        //enable the lock button if answer is not locked
        let pref = Util.getPreferences()!
        if pref.feedback && (!pref.showLockButton || isMultiChoiceQuestion){
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
    
    ///Updates the question text
    override func updateContent() {
        if let label = questionTextLabel{
            label.text = currentQuestionDataSet[pageIndex].questionText + currentQuestionDataSet[pageIndex].picURL
        }
    }
    
    //MARK: TableView
    
    ///Returns the number of answers for the tableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentQuestionDataSet[pageIndex].answers.count
    }
    
    
    /**
     Specifies which which cell content gets shown depending on the status of the question:
     locked? revealt? answerd? correct/false?
     chooses image, text and text color to display
     - returns: a new cell
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if isMultiChoiceQuestion{
            return buildMultiChoiceCell(indexPath)
        }else{
            return buildSingleChoiceCell(indexPath)
        }
    }
    
    func buildSingleChoiceCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = answerTableView.dequeueReusableCellWithIdentifier("AnswerCell", forIndexPath: indexPath) as! AnswerCell
        // Configure the cell...
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
                cell.AnswerTextLabel.textColor = Util.myGreenColor
            }else{
                cell.AnswerTextLabel.textColor = Util.myRedColor
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
    
    func buildMultiChoiceCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = answerTableView.dequeueReusableCellWithIdentifier("AnswerCell", forIndexPath: indexPath) as! AnswerCell
        // Configure the cell...
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
    
    ///Logic for what happens when a cell gets tapped
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let answer = question.answers[indexPath.row]
        
        //do nothing when question is locked
        if !question.isLocked{
            
            realm.beginWrite()
            
            //Multi choice question
            if isMultiChoiceQuestion{
                answer.isSelected = !answer.isSelected
                
            //Single choice question
            }else{
                let pref = Util.getPreferences()!
                
                //Use progress view
                if pref.feedback && pref.showLockButton{
                    if lastSelectedCell != nil {
                        lastSelectedCell!.progressView.progress = 0
                    }
                    stopTimer()
                    lastSelectedCell = tableView.cellForRowAtIndexPath(indexPath) as? AnswerCell
                    
                    //deselect answer if is checked
                    if answer.isSelected{
                        answer.isSelected = false
                    }else{
                        //deselect all answers
                        for ans in question.answers{
                            ans.isSelected = false
                        }
                        //select new answer
                        answer.isSelected = true
                        startTimer()
                    }
                    
                }else{
                    //deselect answer if is checked
                    if answer.isSelected{
                        answer.isSelected = false
                    }else{
                        //deselect all answers
                        for ans in question.answers{
                            ans.isSelected = false
                        }
                        //select new answer
                        answer.isSelected = true
                    }
                }
            }
            
            //Save answer to realm and reload with new data
            realm.add(answer)
            try! realm.commitWrite()
            tableView.reloadData()
        }
    }
    
    ///Timer to lock a question
    func startTimer(){
        timer = NSTimer()
        let aSelector : Selector = #selector(QuestionViewController.updateLockProgress)
        timer.tolerance = 0.1
        timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: aSelector, userInfo: nil, repeats: true)
    }
    
    ///Stops timer and resets lock progress
    func stopTimer(){
        if lastSelectedCell != nil {
            let progView = lastSelectedCell!.progressView
            timer.invalidate()
            lockProgress = 0.0
            progView.progress = lockProgress
        }
    }
    
    ///Increases the counter until the question should lock. Will call lockQuestion when counter reaches 1
    func updateLockProgress(){
        let progView = lastSelectedCell!.progressView
        lockProgress += 0.05 / Double(Util.getPreferences()!.lockSeconds)
        progView.progress = lockProgress
        if lockProgress >= 1 {
            lockQuestion(true)
            stopTimer()
            progView.progress = 0
        }
        
    }
    
    ///Locks question and saves it to realm
    @IBAction func lockButtonPressed(sender: AnyObject) {
        //check if an answer was selected
        var answerWasSelected = false
        for answer in question.answers{
            if answer.isSelected{
                answerWasSelected = true
            }
        }
        if !answerWasSelected && !isMultiChoiceQuestion{
            showAlert(NSLocalizedString("No anser selected", comment: "Single choice question"), message: NSLocalizedString("This is a single choice question. Please select one answer.", comment: "Single choice question"))
        }else{
            
            lockButton.enabled = false
            lockQuestion(true)
        }
    }
    
    /**
     Locks a question so it can't be manipulated any further.
     - parameter withFeedback: boolean that defines if feedback should be shown
     */
    func lockQuestion(withFeedback: Bool){
        realm.beginWrite()
        question.isLocked = true
        question.revealAnswers = true
        realm.add(question)
        try! realm.commitWrite()
        answerTableView.reloadData()
        if question.answerScore < 1 && withFeedback{
            showFeedback()
        }
    }
    
    
    //MARK: Alerts
    
    ///Shows a hint as an alert
    func showHint(){
        let hintStr = currentQuestionDataSet[pageIndex].hint
        showAlert(NSLocalizedString("Hint", comment: "hint button"), message: hintStr)
    }
    
    ///Shows feedback as an alert.
    func showFeedback(){
        let FeedbackStr = question.feedback
        if !FeedbackStr.isEmpty {
            let alertController = UIAlertController(title: NSLocalizedString("Feedback", comment: "Feedback title"), message: FeedbackStr, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Got it", comment: "ok button for feedback"), style: .Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    /**
     Shows an overlay alert with an "OK" button to dimiss it
     - parameters:
     - title: Title of the alert
     - message: body of the alert
     */
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func unwindToLogInScreen(segue:UIStoryboardSegue) {
    }
    
    
}
