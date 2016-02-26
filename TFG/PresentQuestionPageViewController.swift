//
//  PresentQuestionPageViewController.swift
//  TFG
//
//  Created by Johannes Berger on 26.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit

class PresentQuestionPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createPageViewController()
        setupPageControl()
        resetDataSet()
    }
    
    private func createPageViewController() {
        
        self.dataSource = self
        let firstController = getPageController(0)!
        let startingViewControllers: NSArray = [firstController]
        self.setViewControllers(startingViewControllers as? [UIViewController], direction: .Forward, animated: false, completion: nil)
    
    }
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.grayColor()
        appearance.currentPageIndicatorTintColor = UIColor.darkGrayColor()
        appearance.backgroundColor = UIColor.whiteColor()
    }
    
    
    
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        if let questionContentVC = viewController as? QuestionContentViewController{
            if questionContentVC.pageIndex > 0{
                return getPageController(questionContentVC.pageIndex-1)
            }
        }else if let finishedVC = viewController as? QuizFinishedViewController{
            if finishedVC.pageIndex > 0{
                return getPageController(finishedVC.pageIndex-1)
            }
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        if let questionContentVC = viewController as? QuestionContentViewController{
            if questionContentVC.pageIndex+1 < Util().getCurrentTopic()!.questions.count + 1{
                return getPageController(questionContentVC.pageIndex+1)
            }
        }else if let finishedVC = viewController as? QuizFinishedViewController{
            if finishedVC.pageIndex+1 < Util().getCurrentTopic()!.questions.count + 1{
                return getPageController(finishedVC.pageIndex+1)
            }
        }
        return nil
    }
    
    private func getPageController(pageIndex: Int) -> UIViewController? {
        
        if pageIndex < Util().getCurrentTopic()!.questions.count {
            let questionContentVC = self.storyboard!.instantiateViewControllerWithIdentifier("ContentController") as! QuestionContentViewController
            questionContentVC.pageIndex = pageIndex
            return questionContentVC
        } else if pageIndex < Util().getCurrentTopic()!.questions.count + 1 {
            let finishedVC = self.storyboard!.instantiateViewControllerWithIdentifier("QuizFinished") as! QuizFinishedViewController
            finishedVC.pageIndex = pageIndex
            return finishedVC
        }
        
        return nil
    }
    
    
    
    // MARK: - Page Indicator
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return Util().getCurrentTopic()!.questions.count + 1
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    //resets the questiondata so no question is answered and no answer is seleted
    func resetDataSet() {
        realm.beginWrite()
        for question in Util().getCurrentTopic()!.questions{
            question.isAnswered = false
            realm.add(question)
            for answer in question.answers{
                answer.isSelected = false
                realm.add(answer)
            }
        }
        try! realm.commitWrite()
    }

}
