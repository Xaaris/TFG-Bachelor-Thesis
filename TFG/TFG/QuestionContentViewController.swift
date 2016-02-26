//
//  QuestionContentViewController.swift
//  TFG
//
//  Created by Johannes Berger on 26.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit

class QuestionContentViewController: UIViewController {

    @IBOutlet weak var questionTextLabel: UILabel?
    
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
    }
}
