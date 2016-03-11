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
            let mainStack = stackView
            mainStack.alignment = .Leading
            mainStack.distribution = .EqualSpacing
            mainStack.spacing = 5
            
            let newView = createAnswerView(row)
            mainStack.addArrangedSubview(newView)
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
        expansionButton.addTarget(self, action: "expansionButtonPressed:", forControlEvents: .TouchUpInside)
        expansionButton.tag = row
        
        let questionNumberLabel = UILabel()
        questionNumberLabel.text = "Question \(row)"
        questionNumberLabel.font = UIFont.boldSystemFontOfSize(17.0)
        
        let arrowImageView = UIImageView()
        arrowImageView.image = UIImage(named: "ResultsUnfold")
        
        let titleView = UIView()
        titleView.addSubview(arrowImageView)
        titleView.addSubview(expansionButton)
        titleView.addSubview(questionNumberLabel)
        titleView.heightAnchor.constraintEqualToConstant(50).active = true
        titleView.widthAnchor.constraintEqualToConstant(280).active = true
        titleView.backgroundColor = Util().myLightRedColor
        titleView.translatesAutoresizingMaskIntoConstraints = false
        expansionButton.translatesAutoresizingMaskIntoConstraints = false
        questionNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        //Button Constraints
        var leftSideConstraint = NSLayoutConstraint(item: expansionButton, attribute: .Left, relatedBy: .Equal, toItem: titleView, attribute: .Left, multiplier: 1.0, constant: 0.0)
        var bottomConstraint = NSLayoutConstraint(item: expansionButton, attribute: .Bottom , relatedBy: .Equal, toItem: titleView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        var widthConstraint = NSLayoutConstraint(item: expansionButton, attribute: .Right, relatedBy: .Equal, toItem: titleView, attribute: .Right, multiplier: 1.0, constant: 0)
        var heightConstraint = NSLayoutConstraint(item: expansionButton, attribute: .Top, relatedBy: .Equal, toItem: titleView, attribute: .Top, multiplier: 1.0, constant: 0)
        titleView.addConstraints([leftSideConstraint, bottomConstraint, heightConstraint, widthConstraint])
        
        //Image Constraints
        leftSideConstraint = NSLayoutConstraint(item: arrowImageView, attribute: .Left, relatedBy: .Equal, toItem: titleView, attribute: .Left, multiplier: 1.0, constant: 10.0)
        bottomConstraint = NSLayoutConstraint(item: arrowImageView, attribute: .CenterY , relatedBy: .Equal, toItem: titleView, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        widthConstraint = NSLayoutConstraint(item: arrowImageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 32)
        heightConstraint = NSLayoutConstraint(item: arrowImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 32)
        titleView.addConstraints([leftSideConstraint, bottomConstraint, heightConstraint, widthConstraint])
        
        //questionNumberLabel Constraints
        leftSideConstraint = NSLayoutConstraint(item: questionNumberLabel, attribute: .Left, relatedBy: .Equal, toItem: arrowImageView, attribute: .Right, multiplier: 1.0, constant: 5)
        bottomConstraint = NSLayoutConstraint(item: questionNumberLabel, attribute: .CenterY, relatedBy: .Equal, toItem: arrowImageView, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        widthConstraint = NSLayoutConstraint(item: questionNumberLabel, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: questionNumberLabel.intrinsicContentSize().width)
        heightConstraint = NSLayoutConstraint(item: questionNumberLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: questionNumberLabel.intrinsicContentSize().height)
        titleView.addConstraints([leftSideConstraint, bottomConstraint, heightConstraint, widthConstraint])
        
        
        stack.addArrangedSubview(titleView)
        
        let questionTextLabel = UILabel()
        questionTextLabel.text = question.questionText
        questionTextLabel.numberOfLines = 0
        questionTextLabel.font = UIFont.boldSystemFontOfSize(17.0)
        questionTextLabel.hidden = true
        stack.addArrangedSubview(questionTextLabel)
        
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
        let arrow = arrangedSubViews[0].subviews[0] as! UIImageView
        
        if stackViewArrayHiddenStates[sender.tag]{
            UIView.animateWithDuration(0.3) { () -> Void in
                arrow.image = UIImage(named: "ResultsFold")
                for j in Range(1 ..< arrangedSubViews.count){
                    arrangedSubViews[j].hidden = false
                }
                let scroll = self.scrollView
                let scrollDelta:CGFloat = 32 + 32 * CGFloat(arrangedSubViews.count)
                let offset = CGPoint(x: scroll.contentOffset.x, y: scroll.contentOffset.y + scrollDelta)
                scroll.contentOffset = offset
            }
            self.stackViewArrayHiddenStates[sender.tag] = !self.stackViewArrayHiddenStates[sender.tag]
            
        }else{
            UIView.animateWithDuration(0.3) { () -> Void in
                arrow.image = UIImage(named: "ResultsUnfold")
                for j in Range(1 ..< arrangedSubViews.count){
                    arrangedSubViews[j].hidden = true
                }
            }
            self.stackViewArrayHiddenStates[sender.tag] = !self.stackViewArrayHiddenStates[sender.tag]
        }
    }
    
    
}













