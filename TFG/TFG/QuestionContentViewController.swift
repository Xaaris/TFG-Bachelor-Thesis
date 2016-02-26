//
//  QuestionContentViewController.swift
//  TFG
//
//  Created by Johannes Berger on 26.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit

class QuestionContentViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var questionTextLabel: UILabel?
    @IBOutlet weak var answerTableView: UITableView!
    
    var currentQuestionDataSet:[Question] = []

    
    // MARK: - Variables
    var pageIndex: Int = 0 {
        didSet {
            if let label = questionTextLabel{
                label.text = currentQuestionDataSet[pageIndex].questionText
            }
            
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentQuestionDataSet = Util().getCurrentTopic()!.questions
        resetDataSet()
        questionTextLabel!.text = currentQuestionDataSet[pageIndex].questionText
        answerTableView.delegate = self
        answerTableView.dataSource = self
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
        if answer.isSelected {
            cell.AnswerSelectImage.image = UIImage(named: "AnswerChooserSingelChoiceSelected")
        }else{
            cell.AnswerSelectImage.image = UIImage(named: "AnswerChooserSingelChoiceNotSelected")
        }
        cell.AnswerTextLabel.text = question.answers[indexPath.row].answerText
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let question = currentQuestionDataSet[pageIndex]
        let answer = question.answers[indexPath.row]
        realm.beginWrite()
        answer.isSelected = true
        realm.add(answer)
        try! realm.commitWrite()
        tableView.reloadData()
    }
    
    func resetDataSet() {
        realm.beginWrite()
        for question in currentQuestionDataSet{
            question.isAnswered = false
            realm.add(question)
            for answer in question.answers{
                answer.isSelected = false
                realm.add(answer)
            }
        }
        try! realm.commitWrite()
    }
}
