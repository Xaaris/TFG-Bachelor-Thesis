//
//  QuizFinishedViewController.swift
//  TFG
//
//  Created by Johannes Berger on 26.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit

class QuizFinishedViewController: UIViewController {
    
    var pageIndex: Int = 0 {
        didSet {
            
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        let vc = parentViewController as! PresentQuestionPageViewController
        vc.updatePageController(pageIndex)
        revealAnswers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func revealAnswers(){
        realm.beginWrite()
        for question in (Util().getCurrentTopic()?.questions)!{
            question.revealAnswers = true
            question.isLocked = true
            realm.add(question)
        }
        try! realm.commitWrite()
    }

}
