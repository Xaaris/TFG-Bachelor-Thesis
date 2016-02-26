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
    var pageIndex: Int = 0
    
    var randomString: String = "" {
        
        didSet {
            if let label = questionTextLabel{
                label.text = randomString + String(pageIndex) + "Bla"
            }
            
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionTextLabel!.text = randomString + String(pageIndex)
    }
}
