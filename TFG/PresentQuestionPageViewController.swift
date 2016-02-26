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
        
        let questionContentVC = viewController as! QuestionContentViewController
        
        if questionContentVC.pageIndex > 0 {
            return getPageController(questionContentVC.pageIndex-1)
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let questionContentVC = viewController as! QuestionContentViewController
        
        if questionContentVC.pageIndex+1 < Util().getCurrentTopic()!.questions.count {
            return getPageController(questionContentVC.pageIndex+1)
        }
        
        return nil
    }
    
    private func getPageController(pageIndex: Int) -> QuestionContentViewController? {
        
        if pageIndex < Util().getCurrentTopic()!.questions.count {
            let questionContentVC = self.storyboard!.instantiateViewControllerWithIdentifier("ContentController") as! QuestionContentViewController
            questionContentVC.pageIndex = pageIndex
            return questionContentVC
        }
        
        return nil
    }
    
    
    
    // MARK: - Page Indicator
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return Util().getCurrentTopic()!.questions.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }

}
