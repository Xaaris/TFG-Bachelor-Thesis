//
//  QuestionContentViewController.swift
//  TFG
//
//  Created by Johannes Berger on 26.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit

class QuestionContentViewController: PageViewContent, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var questionTextLabel: UILabel?
    @IBOutlet weak var answerTableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateContent()
        answerTableView.delegate = self
        answerTableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        answerTableView.reloadData()
    }
    
    override func updateContent() {
        if let label = questionTextLabel{
            label.text = currentQuestionDataSet[pageIndex].questionText
        }
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
        let singleChoiceImageName = "AnswerChooserSingelChoice"
        let selectedStr = "Selected"
        let lockedStr = "Locked"
        let correctStr = "Correct"
        let wrongStr = "Wrong"
        if question.revealAnswers{
            if answer.isSelected && answer.isCorrect{
                cell.AnswerSelectImage.image = UIImage(named: singleChoiceImageName + correctStr)
            }else if answer.isSelected && !answer.isCorrect{
                cell.AnswerSelectImage.image = UIImage(named: singleChoiceImageName + wrongStr)
            }else{
                cell.AnswerSelectImage.image = UIImage(named: singleChoiceImageName + lockedStr)
            }
            if answer.isCorrect{
                cell.AnswerTextLabel.textColor = Util().myGreenColor
            }else{
                cell.AnswerTextLabel.textColor = Util().myRedColor
            }
        }else{
            if question.isLocked{
                if answer.isSelected{
                    cell.AnswerSelectImage.image = UIImage(named: singleChoiceImageName + lockedStr + selectedStr)
                }else{
                    cell.AnswerSelectImage.image = UIImage(named: singleChoiceImageName + lockedStr)
                }
            }else{
                if answer.isSelected{
                    cell.AnswerSelectImage.image = UIImage(named: singleChoiceImageName + selectedStr)
                }else{
                    cell.AnswerSelectImage.image = UIImage(named: singleChoiceImageName)
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
            answer.isSelected = true
            question.isLocked = true
            realm.add(answer)
            realm.add(question)
            try! realm.commitWrite()
            tableView.reloadData()
        }
    }
    

}
