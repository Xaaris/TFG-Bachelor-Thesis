//
//  QuestionContentViewController.swift
//  TFG
//
//  Created by Johannes Berger on 26.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit

class QuestionContentViewController: PageViewContent{

    @IBOutlet weak var questionTextLabel: UILabel?

    let multiChoiceStr = "AnswerChooserMultiChoice"
    let singleChoiceStr = "AnswerChooserSingelChoice"
    let selectedStr = "Selected"
    let lockedStr = "Locked"
    let correctStr = "Correct"
    let wrongStr = "Wrong"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateContent()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func updateContent() {
        if let label = questionTextLabel{
            label.text = currentQuestionDataSet[pageIndex].questionText
        }
    }
}
