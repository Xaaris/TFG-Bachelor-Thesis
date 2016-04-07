//
//  PresentQuestionPageViewController.swift
//  TFG
//
//  Created by Johannes Berger on 26.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit

class PresentQuestionPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    var pageControl:UIPageControl! = UIPageControl()
    
    var startTime = NSDate()
    var endTime = NSDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createPageViewController()
        setupPageControl()
        resetDataSet()
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        startTimeTracking()
    }
    
    func startTimeTracking(){
        startTime = NSDate()
    }
    
    func endTimeTracking(){
        endTime = NSDate()
    }
    
    private func createPageViewController() {
        self.dataSource = self
        let firstController = getPageController(0)!
        let startingViewControllers: NSArray = [firstController]
        self.setViewControllers(startingViewControllers as? [UIViewController], direction: .Forward, animated: true, completion: nil)
    }
    
    private func setupPageControl() {
        pageControl = UIPageControl()
        pageControl.frame = CGRectMake(0,0,self.view.frame.width,37)
        self.view.addSubview(pageControl)
        pageControl.pageIndicatorTintColor = UIColor.grayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.darkGrayColor()
        pageControl.backgroundColor = UIColor.clearColor()
        pageControl.numberOfPages = Util.getCurrentTopic()!.questions.count + 1
        pageControl.currentPage = 0
    }
    
    func updatePageController(pageIndex: Int){
        pageControl.currentPage = pageIndex
    }
    
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! PageViewContent
            if vc.pageIndex > 0{
                return getPageController(vc.pageIndex - 1)
            }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! PageViewContent
            if vc.pageIndex + 1 <= Util.getCurrentTopic()!.questions.count {
                return getPageController(vc.pageIndex + 1)
            }
        return nil
    }
    
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
    
    
    //resets the questiondata so no question is answered and no answer is seleted
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
    
    //Brings Pgae indicator to front
    override func viewDidLayoutSubviews() {
        for subView in self.view.subviews {
            if subView is UIPageControl {
                self.view.bringSubviewToFront(subView)
            }
        }
        super.viewDidLayoutSubviews()
    }
    
}







class PageViewContent: UIViewController{
    
    var currentQuestionDataSet:[Question] = []
    
    var pageIndex: Int = 0 {
        didSet {
            updateContent()
        }
    }
    
    func updateContent(){}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentQuestionDataSet = Util.getCurrentTopic()!.questions
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let vc = parentViewController as! PresentQuestionPageViewController
        vc.updatePageController(pageIndex)
    }
    
    
}




