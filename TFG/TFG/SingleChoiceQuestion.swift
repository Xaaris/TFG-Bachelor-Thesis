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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        answerTableView.delegate = self
        answerTableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        answerTableView.reloadData()
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
            realm.beginWrite()
            answer.isSelected = !answer.isSelected
            question.isLocked = true
            realm.add(answer)
            realm.add(question)
            try! realm.commitWrite()
            tableView.reloadData()
        }
    }

}

