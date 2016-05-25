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
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTabBarSelection() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let tabBarsQuery = XCUIApplication().tabBars
        let statistikenButton = tabBarsQuery.buttons["Statistiken"]
        statistikenButton.tap()
        tabBarsQuery.buttons["Preferences"].tap()
        statistikenButton.tap()
        tabBarsQuery.buttons["Home"].tap()
        
    }
    
    func testTopicSelection() {
        
        let app = XCUIApplication()
        let wHleEinThemaButton = app.buttons["Wähle ein Thema"]
        wHleEinThemaButton.tap()
        app.tables.cells["This is the Title"].tap()
        app.navigationBars["Wähle ein Thema"].childrenMatchingType(.Button).matchingIdentifier("Zurück").elementBoundByIndex(0).tap()
        
    }
    
    func testTesting() {
        
        let app = XCUIApplication()
        let tabBarsQuery = app.tabBars
        let statistikenButton = tabBarsQuery.buttons["Statistiken"]
        statistikenButton.tap()
        
        let scrollViewsQuery = app.scrollViews
        let zeitProThemaInMinutenElementsQuery = scrollViewsQuery.otherElements.containingType(.StaticText, identifier:"Zeit pro Thema in minuten")
        let element = zeitProThemaInMinutenElementsQuery.childrenMatchingType(.Other).elementBoundByIndex(0)
        element.tap()
        element.tap()
        
        let elementsQuery = scrollViewsQuery.otherElements
        elementsQuery.staticTexts["Zeit pro Thema in minuten"].tap()
        
        let element2 = zeitProThemaInMinutenElementsQuery.childrenMatchingType(.Other).elementBoundByIndex(2)
        element2.tap()
        element2.tap()
        tabBarsQuery.buttons["Preferences"].tap()
        statistikenButton.tap()
        element.tap()
        
        let button = scrollViewsQuery.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element.childrenMatchingType(.Button).element
        button.tap()
        
        let thisIsTheTitlePickerWheel = elementsQuery.pickerWheels["This is the Title"]
        thisIsTheTitlePickerWheel.tap()
        element.tap()
        button.tap()
        elementsQuery.pickerWheels["Übersicht"].tap()
        elementsQuery.pickerWheels["SAT Math Questions"].tap()
        button.tap()
        elementsQuery.pickerWheels["Java Intro"].tap()
        thisIsTheTitlePickerWheel.tap()
        
    }
    
}
