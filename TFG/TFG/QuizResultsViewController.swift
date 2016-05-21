//
//  QuizResultsViewController.swift
//  TFG
//
//  Created by Johannes Berger on 06.03.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit
import RealmSwift

///Class that displays the quiz's results
class QuizResultsViewController: UIViewController{
    
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var stackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var xOutOfxLabel: UILabel!
    
    var screenwidth:CGFloat = 320
    var stackViewArray:[UIStackView] = [UIStackView]() //Array that encompasses all the stackviews
    var stackViewArrayHiddenStates:[Bool] = [Bool]() //Array that saves the states of the stackviews, wheter they are hidden or not
    
    ///Prepares the view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //getting the screens width for later formatting
        screenwidth = UIScreen.mainScreen().bounds.width
        
        // setup scrollview
        let insets = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0)
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
        
        prepareTitleView()
        loadStackViews()
        
        
    }
    
    ///Creates a new stackview for every question and appends it to the main stack view
    func loadStackViews(){
        let numberOfQuestions = Util.getCurrentTopic()!.questions.count
        for row in Range(0 ..< numberOfQuestions){
            let newView = createQuestionRow(row)
            stackView.addArrangedSubview(newView)
        }
    }
    
    /**
     Creates a stackview that represents a question with all its answers
     - parameter row: the number of the question
     - returns: a stackView
     */
    func createQuestionRow(row: Int)-> UIView{
        let question = Util.getCurrentTopic()!.questions[row]
        
        //Create parent stackview that will house the question and all its answers
        let stack = UIStackView()
        stack.axis = .Vertical
        stack.alignment = .Leading
        stack.distribution = .EqualSpacing
        stack.spacing = 5
        
        //Create questionTitleView and add it to the stack
        let titleView = createQuestionTitleView(row)
        stack.addArrangedSubview(titleView)
        
        //Add the question text
        let questionTextLabel = UILabel()
        questionTextLabel.adjustsFontSizeToFitWidth = true
        questionTextLabel.font = UIFont.boldSystemFontOfSize(17.0)
        //foramt depending on device size
        if screenwidth > 700{
            questionTextLabel.preferredMaxLayoutWidth = screenwidth - 300
        }else{
            questionTextLabel.preferredMaxLayoutWidth = screenwidth - 40
        }
        questionTextLabel.hidden = true
        questionTextLabel.numberOfLines = 0
        questionTextLabel.text = question.questionText
        stack.addArrangedSubview(questionTextLabel)
        
        //Create and append answer views
        for answer in question.answers{
            let answerView = createAnswerView(question, answer: answer)
            stack.addArrangedSubview(answerView)
        }
        
        //Append to global stack arrays
        stackViewArray.append(stack)
        stackViewArrayHiddenStates.append(true)
        
        return stack
    }
    
    /**
     Creates the title view of a question which is tappable
     - parameter row: the number of the question
     - returns: a stackView
     */
    func createQuestionTitleView(row: Int) -> UIView {
        let question = Util.getCurrentTopic()!.questions[row]
        
        //Build expansion button (the whole title of the question will be clickable)
        let expansionButton = UIButton()
        expansionButton.addTarget(self, action: #selector(QuizResultsViewController.expansionButtonPressed(_:)), forControlEvents: .TouchUpInside)
        expansionButton.tag = row
        
        //Build question title
        let questionNumberLabel = UILabel()
        questionNumberLabel.text = NSLocalizedString("Question ", comment: "") + String(row + 1)
        questionNumberLabel.font = UIFont.boldSystemFontOfSize(17.0)
        
        //Build little arrow the symbolizes that the question is unfoldable
        let arrowImageView = UIImageView()
        arrowImageView.image = UIImage(named: "ResultsUnfold")
        
        //Build title view
        let titleView = UIView()
        titleView.addSubview(arrowImageView)
        titleView.addSubview(expansionButton)
        titleView.addSubview(questionNumberLabel)
        titleView.heightAnchor.constraintEqualToConstant(50).active = true
        //format depending on device size
        if screenwidth > 700{
            titleView.widthAnchor.constraintEqualToConstant(screenwidth - 300).active = true
        }else{
            titleView.widthAnchor.constraintEqualToConstant(screenwidth - 40).active = true
        }
        if question.answerScore == 0{
            titleView.backgroundColor = Util.myLightRedColor
        }else if question.answerScore < 1{
            titleView.backgroundColor = Util.myLightYellowColor
        }else{
            titleView.backgroundColor = Util.myLightGreenColor
        }
        
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
        
        return titleView
    }
    
    /**
     Creates a answer view of a question
     - parameter question: the question for which the answer is
     - parameter answer: the answer for which to create the view
     - returns: a stackView
     */
    func createAnswerView(question: Question,answer: Answer) -> UIView{
        //The answer view is organized in a horizontal stack
        let subStack = UIStackView()
        subStack.axis = .Horizontal
        subStack.distribution = .EqualSpacing
        subStack.alignment = .Center
        
        //Get the right image depending on the type of question and wether it was answered correctly or not
        var imageName = ""
        if question.type == "MultipleChoice"{
            if answer.isSelected && answer.isCorrect{
                imageName = "AnswerChooserMultiChoiceCorrect"
            }else if answer.isSelected && !answer.isCorrect{
                imageName = "AnswerChooserMultiChoiceWrong"
            }else{
                imageName = "AnswerChooserMultiChoiceLocked"
            }
        }else{
            if answer.isSelected && answer.isCorrect{
                imageName = "AnswerChooserSingelChoiceCorrect"
            }else if answer.isSelected && !answer.isCorrect{
                imageName = "AnswerChooserSingelChoiceWrong"
            }else{
                imageName = "AnswerChooserSingelChoiceLocked"
            }
        }
        let answerImage = UIImage(named: imageName)
        let imageView = UIImageView(image: answerImage)
        
        //Set the text for the answer
        let answerLabel = UILabel()
        //format depending on device size
        if screenwidth > 700{
            answerLabel.preferredMaxLayoutWidth = 500
        }else{
            answerLabel.preferredMaxLayoutWidth = 220
        }
        answerLabel.text = answer.answerText
        answerLabel.numberOfLines = 0
        if answer.isCorrect{
            answerLabel.textColor = Util.myGreenColor
        }else{
            answerLabel.textColor = Util.myRedColor
        }
        
        //add image and text together
        subStack.addArrangedSubview(imageView)
        subStack.addArrangedSubview(answerLabel)
        subStack.hidden = true
        
        return subStack
    }
    
    ///The quit button brings the user to the statistics view
    @IBAction func quitButtonPressed(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("Home") as! UITabBarController
        vc.selectedIndex = 1 // Statistics View
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    ///The expansion button unfolds or fold a question depending on its current state
    func expansionButtonPressed(sender: AnyObject){
        //TODO: nice to have: make button turn
        
        var arrangedSubViews = self.stackViewArray[sender.tag].arrangedSubviews
        let arrow = arrangedSubViews[0].subviews[0] as! UIImageView
        
        //if hidden unfold the question
        if stackViewArrayHiddenStates[sender.tag]{
            UIView.animateWithDuration(0.3) { () -> Void in
                arrow.image = UIImage(named: "ResultsFold")
                for j in Range(1 ..< arrangedSubViews.count){
                    arrangedSubViews[j].hidden = false
                }
                //scroll to show the expanded view better
                let scroll = self.scrollView
                let scrollDelta:CGFloat = 32 + 32 * CGFloat(arrangedSubViews.count)
                let offset = CGPoint(x: scroll.contentOffset.x, y: scroll.contentOffset.y + scrollDelta)
                scroll.contentOffset = offset
            }
            self.stackViewArrayHiddenStates[sender.tag] = !self.stackViewArrayHiddenStates[sender.tag]
            
            //if shown fold the question
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
    
    ///Prepares the title view depending on the score of the last quiz
    func prepareTitleView() {
        if let score = Util.getLatestStatistic()?.percentageScore{
            
            if score < 50 {
                titleLabel.text = NSLocalizedString("That needs more work!", comment: "At the end of a quiz")
            }else if score < 75 {
                titleLabel.text = NSLocalizedString("You did okay..", comment: "At the end of a quiz")
            }else if score < 90 {
                titleLabel.text = NSLocalizedString("That was good", comment: "At the end of a quiz")
            }else if score < 100 {
                titleLabel.text = NSLocalizedString("That was great!", comment: "At the end of a quiz")
            }else{
                titleLabel.text = NSLocalizedString("Perfect!", comment: "At the end of a quiz")
            }
            let numberFormatter = NSNumberFormatter()
            numberFormatter.minimumIntegerDigits = 1
            numberFormatter.maximumFractionDigits = 1
            xOutOfxLabel.text = NSLocalizedString("You got a score of ", comment: "At the end of a quiz") + String(numberFormatter.stringFromNumber(score)!) + "%"
        }else{
            print("Error: no statistic found")
        }
    }
    
    
}













