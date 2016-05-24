//
//  PresentQuestionPageViewController.swift
//  TFG
//
//  Created by Johannes Berger on 26.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit

/**
 Parent class that houses all "cards" that are displayed during a quiz
 */
class PresentQuestionPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    var pageControl:UIPageControl! = UIPageControl()
    var pageNumberLabel: UILabel! = UILabel()
    
    var numberOfPages = 0
    
    //Variables used to measure the time taken for a quiz run
    var startTime = NSDate()
    var endTime = NSDate()
    
    ///Initializes a basic card and resets the data set
    override func viewDidLoad() {
        super.viewDidLoad()
        createPageViewController()
        setupPageControl()
        resetDataSet()
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    ///Starts the time tracking
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        startTimeTracking()
    }
    
    ///Starts the time tracking
    func startTimeTracking(){
        startTime = NSDate()
    }
    
    ///Ends the time tracking
    func endTimeTracking(){
        endTime = NSDate()
    }
    
    ///Initializes the page view controller which displays the "cards"
    private func createPageViewController() {
        self.dataSource = self
        let firstController = getPageController(0)!
        let startingViewControllers: NSArray = [firstController]
        self.setViewControllers(startingViewControllers as? [UIViewController], direction: .Forward, animated: true, completion: nil)
    }
    
    ///Initializes the page controller which displays the number of "cards" as dots or numbers depending on the number of cards
    private func setupPageControl() {
        numberOfPages = Util.getCurrentTopic()!.questions.count
        if numberOfPages < 20{
            pageControl = UIPageControl()
            pageControl.userInteractionEnabled = false
            pageControl.frame = CGRectMake(0,0,self.view.frame.width,37)
            self.view.addSubview(pageControl)
            pageControl.pageIndicatorTintColor = UIColor.grayColor()
            pageControl.currentPageIndicatorTintColor = UIColor.darkGrayColor()
            pageControl.backgroundColor = UIColor.clearColor()
            pageControl.numberOfPages = numberOfPages + 1
            pageControl.currentPage = 0
        }else{
            pageNumberLabel = UILabel(frame: CGRectMake(0,0,self.view.frame.width,35))
            pageNumberLabel.text = "1/\(numberOfPages + 1)"
            pageNumberLabel.textColor = UIColor.grayColor()
            pageNumberLabel.textAlignment = .Center
            self.view.addSubview(pageNumberLabel)
        }
    }
    
    ///Updates the current page number or dot for the page control
    func updatePageController(pageIndex: Int){
        if numberOfPages < 20{
            pageControl.currentPage = pageIndex
        }else{
            pageNumberLabel.text = "\(pageIndex + 1)/\(numberOfPages + 1)"
        }
    }
    
    
    // MARK: - UIPageViewControllerDataSource
    
    /**
     Will return the pageviewcontroller to the left
     - returns: left pageviewcontroller or nil if there is none
     */
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! PageViewContent
            if vc.pageIndex > 0{
                return getPageController(vc.pageIndex - 1)
            }
        return nil
    }
    
    /**
     Will return the pageviewcontroller to the right
     - returns: right pageviewcontroller or nil if there is none
     */
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! PageViewContent
            if vc.pageIndex + 1 <= Util.getCurrentTopic()!.questions.count {
                return getPageController(vc.pageIndex + 1)
            }
        return nil
    }
    
    /**
     Will return the desired pageviewcontroller
     - parameter pageIndex: int that specifies the number of the page
     - returns: desired pageviewcontroller
     */
    private func getPageController(pageIndex: Int) -> UIViewController? {
        var vc:PageViewContent = PageViewContent()
        
        if pageIndex < Util.getCurrentTopic()!.questions.count {
            if Util.getCurrentTopic()!.questions[pageIndex].type == "SingleChoice"{
                vc = self.storyboard!.instantiateViewControllerWithIdentifier("SingleChoice") as! SingleChoiceQuestion
            }else if Util.getCurrentTopic()!.questions[pageIndex].type == "MultipleChoice"{
                vc = self.storyboard!.instantiateViewControllerWithIdentifier("MultiChoice") as! MultiChoiceQuestion
            }else{
                //TODO: Implement other question types
                vc = self.storyboard!.instantiateViewControllerWithIdentifier("SingleChoice") as! SingleChoiceQuestion
            }
            
        } else if pageIndex == Util.getCurrentTopic()!.questions.count {
            vc = self.storyboard!.instantiateViewControllerWithIdentifier("QuizFinished") as! QuizFinishedViewController
        }else{
            print("Error: Out of bounds (PageviewController)")
        }
        vc.pageIndex = pageIndex
        return vc
    }
    
    
    ///resets the questiondata so no question is answered and no answer is seleted
    func resetDataSet() {
        realm.beginWrite()
        for question in Util.getCurrentTopic()!.questions{
            question.isLocked = false
            question.revealAnswers = false
            realm.add(question)
            for answer in question.answers{
                answer.isSelected = false
                realm.add(answer)
            }
        }
        try! realm.commitWrite()
    }
    
    ///Brings Page indicator to front
    override func viewDidLayoutSubviews() {
        for subView in self.view.subviews {
            if subView is UIPageControl {
                self.view.bringSubviewToFront(subView)
            }
        }
        super.viewDidLayoutSubviews()
    }
    
}





/**
 Parent class that for all "cards" that are displayed during a quiz
 */
class PageViewContent: UIViewController{
    
    var currentQuestionDataSet:[Question] = []
    
    ///Current page number. Gets updated from pageviewcontroller
    var pageIndex: Int = 0 {
        didSet {
            updateContent()
        }
    }
    
    ///Method stub for child classes
    func updateContent(){}
    
    ///Loads current question data set
    override func viewDidLoad() {
        super.viewDidLoad()
        currentQuestionDataSet.removeAll()
        for question in Util.getCurrentTopic()!.questions{
            currentQuestionDataSet.append(question)
        }
    }
    
    ///Updates page number
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let vc = parentViewController as! PresentQuestionPageViewController
        vc.updatePageController(pageIndex)
    }
    
    
}




