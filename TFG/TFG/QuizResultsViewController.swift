//
//  QuizResultsViewController.swift
//  TFG
//
//  Created by Johannes Berger on 06.03.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit
import RealmSwift

class QuizResultsViewController: UIViewController, UIGestureRecognizerDelegate{
    
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup scrollview
        let insets = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0)
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
        
        loadStackViews()
        
    }
    
    func loadStackViews(){
        for row in Range(0 ..< Util().getCurrentTopic()!.questions.count + 1){
            let stack = stackView
            let index = stack.arrangedSubviews.count
            stack.alignment = .Fill
            stack.distribution = .EqualSpacing
            //        let addView = stack.arrangedSubviews[index]
            
            //        let scroll = scrollView
            //        let offset = CGPoint(x: scroll.contentOffset.x,
            //            y: scroll.contentOffset.y + addView.frame.size.height)
            var newView = UIView()
            if row == 0{
                newView = createResultsView()
            }else{
                newView = createAnswerView(row)
            }
            newView.hidden = true
            stack.insertArrangedSubview(newView, atIndex: index)
            
            UIView.animateWithDuration(0.25) { () -> Void in
                newView.hidden = false
                //            scroll.contentOffset = offset
            }
            
        }
       
    }
    
     
    
    func createResultsView()-> UIView{
        let title = "You did great"
        let xOutOfx = "x out of x"
        
        let stack = UIStackView()
        stack.axis = .Vertical
        stack.alignment = .Center
        stack.distribution = .EqualCentering
        stack.spacing = 8
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textAlignment = .Center
        
        let xOutOfxLabel = UILabel()
        xOutOfxLabel.text = xOutOfx
        xOutOfxLabel.textAlignment = .Center
        
        let quitButton = UIButton(type: .RoundedRect)
        quitButton.setTitle("Quit", forState: .Normal)
        quitButton.setBackgroundImage(UIImage(named: "ButtonBackground"), forState: .Normal)
        quitButton.frame = CGRect(x: quitButton.frame.origin.x, y: quitButton.frame.origin.y, width: 120, height: 50)
        quitButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        quitButton.addTarget(self, action: "goBackToRootVC", forControlEvents: .TouchUpInside)
        
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(xOutOfxLabel)
        stack.addArrangedSubview(quitButton)
        
        return stack
    }

    
    func createAnswerView(row: Int)-> UIView{
        let question = Util().getCurrentTopic()!.questions[row - 1]
        let title = question.questionText
        
        let stack = UIStackView()
        stack.axis = .Vertical
        stack.alignment = .Leading
        stack.distribution = .EqualSpacing
        stack.spacing = 8
        
        let titleLabel = UILabel()
        titleLabel.text = title
        
        stack.addArrangedSubview(titleLabel)
        
        for answer in question.answers{
            let answerLabel = UILabel()
            answerLabel.text = answer.answerText
            stack.addArrangedSubview(answerLabel)
        }
        
        let recognizer = UITapGestureRecognizer(target: self, action: "stackViewTapped")
        recognizer.delegate = self
        stack.addGestureRecognizer(recognizer)
        return stack
    }

    func goBackToRootVC() {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("Home") as! UITabBarController
        vc.selectedIndex = 1
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func stackViewTapped() {
        print("stack view tappt")
    }
    
    
}













