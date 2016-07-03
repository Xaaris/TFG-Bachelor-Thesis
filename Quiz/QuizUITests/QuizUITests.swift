//
//  TFGUITests.swift
//  TFGUITests
//
//  Created by Johannes Berger on 25.05.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import XCTest


class TFGUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        //Dismiss Onboarding
        let app = XCUIApplication()
        app.buttons["Skip"].tap()
        
        //Login
        app.buttons["Sign Up"].tap()
        app.buttons["Close"].tap()
        app.textFields["Username"].tap()
        app.buttons["Login"].tap()
        app.alerts["Invalid"].collectionViews.buttons["OK"].tap()
        app.textFields["Username"].typeText("Xaaris")
        app.buttons["Return"].tap()
        app.buttons["Login"].tap()
        app.alerts["Invalid"].collectionViews.buttons["OK"].tap()
        app.secureTextFields["Password"].typeText("testtest")
        app.buttons["Login"].tap()
        app.images["Logo_big"].tap()
        
        //Select a topic
        let chooseBtn = app.buttons["Choose a topic"]
        chooseBtn.tap()
        let javaCell = app.tables.cells["Java Intro"]
        javaCell.tap()
        app.navigationBars["Choose a Topic"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
        //Back on Home Screen
        app.images["Logo_big"].tap()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        //Logout
        let app = XCUIApplication()
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Preferences"].tap()
        
        app.navigationBars["Preferences"].staticTexts["Preferences"].tap()
        app.tables.buttons["Log Out"].tap()
        app.alerts["Log Out?"].collectionViews.buttons["Log Out"].tap()
        //Back at onboarding
        app.pageIndicators["page 1 of 4"].tap()
    }

    
    func testTabBarSelection() {
        
        let app = XCUIApplication()
        let tabBarsQuery = app.tabBars
        let statistikenButton = tabBarsQuery.buttons["Statistics"]
        statistikenButton.tap()
        app.scrollViews.otherElements.buttons["ButtonBackgroundStroke"].tap()
        tabBarsQuery.buttons["Preferences"].tap()
        app.navigationBars["Preferences"].staticTexts["Preferences"].tap()
        statistikenButton.tap()
        app.scrollViews.otherElements.buttons["ButtonBackgroundStroke"].tap()
        tabBarsQuery.buttons["Home"].tap()
        //Back on Home Screen
        app.images["Logo_big"].tap()
        
    }
    
    
    func testQuiz() {
        
        let app = XCUIApplication()
        app.buttons["Start"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.elementBoundByIndex(0).swipeLeft()
        app.navigationBars["Home"].buttons["hint button"].tap()
        app.alerts["Hint"].collectionViews.buttons["OK"].tap()
        for _ in 0 ..< 5 {
            tablesQuery.elementBoundByIndex(0).swipeLeft()
        }
        app.buttons["Finish Quiz"].tap()
        let scrollViewsQuery = app.scrollViews
        let button = scrollViewsQuery.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(0).childrenMatchingType(.Other).elementBoundByIndex(0).childrenMatchingType(.Button).element
        button.tap()
        button.tap()
        app.buttons["Exit"].tap()
        scrollViewsQuery.otherElements.buttons["ButtonBackgroundStroke"].tap()
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Home"].tap()
        //Back on Home Screen
        app.images["Logo_big"].tap()
        
    }
}
