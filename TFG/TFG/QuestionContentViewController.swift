//
//  QuestionContentViewController.swift
//  TFG
//
//  Created by Johannes Berger on 26.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit

/**
 Parent class for the question cards
 */
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
    
    ///Updates the question text
    override func updateContent() {
        if let label = questionTextLabel{
            label.text = currentQuestionDataSet[pageIndex].questionText + currentQuestionDataSet[pageIndex].picURL
        }
    }
    
}
