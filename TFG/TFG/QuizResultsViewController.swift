//
//  QuizResultsViewController.swift
//  TFG
//
//  Created by Johannes Berger on 06.03.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit
import RealmSwift

class QuizResultsViewController: UIViewController{
    
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var stackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var xOutOfxLabel: UILabel!
    
    var stackViewArray:[UIStackView] = [UIStackView]()
    var stackViewArrayHiddenStates:[Bool] = [Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup scrollview
        let insets = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0)
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
        
        loadStackViews()
        
    }
    
    func loadStackViews(){
        let numberOfQuestions = Util().getCurrentTopic()!.questions.count
        for row in Range(0 ..< numberOfQuestions){
            let stack = stackView
            let index = stack.arrangedSubviews.count
            stack.alignment = .Leading
            stack.distribution = .EqualSpacing
            stack.spacing = 30
            
            var newView = UIView()
            newView = createAnswerView(row)
            stack.insertArrangedSubview(newView, atIndex: index)
        }
    }
    
    func createAnswerView(row: Int)-> UIView{
        let question = Util().getCurrentTopic()!.questions[row]
        
        let stack = UIStackView()
        stack.axis = .Vertical
        stack.alignment = .Leading
        stack.distribution = .EqualSpacing
        stack.spacing = 5
        
        let expansionButton = UIButton()
        expansionButton.setImage(UIImage(named: "ResultsUnfold"), forState: .Normal)
        expansionButton.addTarget(self, action: "expansionButtonPressed:", forControlEvents: .TouchUpInside)
        expansionButton.tag = row
        
        let questionTextLabel = UILabel()
        questionTextLabel.text = question.questionText
        questionTextLabel.font = UIFont.boldSystemFontOfSize(17.0)
        
        let questionTitleStack = UIStackView()
        questionTitleStack.axis = .Horizontal
        questionTitleStack.distribution = .EqualSpacing
        questionTitleStack.alignment = .Center
        questionTitleStack.addArrangedSubview(expansionButton)
        questionTitleStack.addArrangedSubview(questionTextLabel)
        
        stack.addArrangedSubview(questionTitleStack)
        
        for answer in question.answers{
            let subStack = UIStackView()
            subStack.axis = .Horizontal
            subStack.distribution = .EqualSpacing
            subStack.alignment = .Center
            
            let answerImage = UIImage(named: "AnswerChooserMultiChoiceCorrect")
            let imageView = UIImageView(image: answerImage)
            let answerLabel = UILabel()
            answerLabel.preferredMaxLayoutWidth = 220
            answerLabel.text = answer.answerText
            answerLabel.numberOfLines = 0
            answerLabel.lineBreakMode = .ByWordWrapping
                
            subStack.addArrangedSubview(imageView)
            subStack.addArrangedSubview(answerLabel)
            subStack.hidden = true
            stack.addArrangedSubview(subStack)
        }
        stackViewArray.append(stack)
        stackViewArrayHiddenStates.append(true)
        
        return stack
    }
    
    @IBAction func quitButtonPressed(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("Home") as! UITabBarController
        vc.selectedIndex = 1
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func expansionButtonPressed(sender: AnyObject){
        //TODO: nice to have: make button turn
        var arrangedSubViews = self.stackViewArray[sender.tag].arrangedSubviews
        let button = arrangedSubViews[0].subviews[0] as! UIButton
        
        if stackViewArrayHiddenStates[sender.tag]{
            var scrollDelta:CGFloat = 0
            UIView.animateWithDuration(0.3) { () -> Void in
                button.setImage(UIImage(named: "ResultsFold"), forState: .Normal)
                for j in Range(1 ..< arrangedSubViews.count){
                    arrangedSubViews[j].hidden = false
                    scrollDelta += 64
                }
                let scroll = self.scrollView
                let offset = CGPoint(x: scroll.contentOffset.x, y: scroll.contentOffset.y + scrollDelta)
                scroll.contentOffset = offset
            }
            self.stackViewArrayHiddenStates[sender.tag] = !self.stackViewArrayHiddenStates[sender.tag]
            
        }else{
            UIView.animateWithDuration(0.3) { () -> Void in
                button.setImage(UIImage(named: "ResultsUnfold"), forState: .Normal)
                for j in Range(1 ..< arrangedSubViews.count){
                    arrangedSubViews[j].hidden = true
                }
            }
            self.stackViewArrayHiddenStates[sender.tag] = !self.stackViewArrayHiddenStates[sender.tag]
        }
    }
    
    
}













