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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var xOutOfxLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup scrollview
        let insets = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0)
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
        
        loadStackViews()
        
    }
    
    func loadStackViews(){
        for row in Range(0 ..< Util().getCurrentTopic()!.questions.count){
            let stack = stackView
            let index = stack.arrangedSubviews.count
            stack.alignment = .Leading
            stack.distribution = .EqualSpacing
            stack.spacing = 30
            //        let addView = stack.arrangedSubviews[index]
            
            //        let scroll = scrollView
            //        let offset = CGPoint(x: scroll.contentOffset.x,
            //            y: scroll.contentOffset.y + addView.frame.size.height)
            var newView = UIView()
            newView = createAnswerView(row)
            newView.hidden = true
            stack.insertArrangedSubview(newView, atIndex: index)
            
            UIView.animateWithDuration(0.25) { () -> Void in
                newView.hidden = false
                //            scroll.contentOffset = offset
            }
            
        }
       
    }

    
    func createAnswerView(row: Int)-> UIView{
        let question = Util().getCurrentTopic()!.questions[row]
        let title = question.questionText
        
        let stack = UIStackView()
        stack.axis = .Vertical
        stack.alignment = .Leading
        stack.distribution = .EqualSpacing
        stack.spacing = 5
        
        let titleLabel = UILabel()
        titleLabel.text = title
        
        stack.addArrangedSubview(titleLabel)
        
        for answer in question.answers{
            let subStack = UIStackView()
            subStack.axis = .Horizontal
            subStack.distribution = .EqualSpacing
            subStack.alignment = .Center
            
            
            let answerImage = UIImage(named: "AnswerChooserMultiChoiceCorrect")
            let imageView = UIImageView(image: answerImage)
            let answerLabel = UILabel()
            answerLabel.preferredMaxLayoutWidth = 250
            answerLabel.text = answer.answerText
            answerLabel.numberOfLines = 0
            answerLabel.lineBreakMode = .ByWordWrapping
            
                
            subStack.addArrangedSubview(imageView)
            subStack.addArrangedSubview(answerLabel)
            stack.addArrangedSubview(subStack)
        }
        
        let recognizer = UITapGestureRecognizer(target: self, action: "stackViewTapped")
        recognizer.delegate = self
        stack.addGestureRecognizer(recognizer)
        return stack
    }
    
    
    @IBAction func quitButtonPressed(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("Home") as! UITabBarController
        vc.selectedIndex = 1
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func stackViewTapped() {
        print("stack view tappt")
    }
    
    
}













