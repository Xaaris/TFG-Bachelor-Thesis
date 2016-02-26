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
    
    // MARK: - Variables
    var pageIndex: Int = 0 {
        didSet {
            if let label = questionTextLabel{
                label.text = Util().getCurrentTopic()!.questions[pageIndex].questionText
            }
            
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionTextLabel!.text = Util().getCurrentTopic()!.questions[pageIndex].questionText
        answerTableView.delegate      =   self
        answerTableView.dataSource    =   self
    }
    
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Util().getCurrentTopic()!.questions[pageIndex].answers.count
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AnswerCell", forIndexPath: indexPath)
        // Configure the cell...
        let question = Util().getCurrentTopic()!.questions[pageIndex]
        cell.textLabel?.text = question.answers[indexPath.row].answerText
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }
}
