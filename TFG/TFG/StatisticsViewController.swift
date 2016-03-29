//
//  SecondViewController.swift
//  TFG
//
//  Created by Johannes Berger on 14.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit
import Charts

class StatisticsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, ChartViewDelegate {
    
    @IBOutlet weak var topicPickerStackView: UIStackView!
    @IBOutlet weak var currentTopicLabel: UILabel!
    @IBOutlet weak var topicPickerView: UIPickerView!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var barChartDateLabel: UILabel!
    @IBOutlet weak var barChartScoreLabel: UILabel!
    
    var pickerValues:[String] = []
    var timer = NSTimer()
    var displayedStatistics: [Statistic] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Statistics View")
        barChartView.delegate = self
        setupTopicPicker()
        //Highlights last value in bar chart view
        barChartView.highlightValue(xIndex: displayedStatistics.count-1, dataSetIndex: 0, callDelegate: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updatePicker()
        updatePickerSelection()
        setupBarChartView()
    }
    
    func setupTopicPicker() {
        topicPickerStackView.translatesAutoresizingMaskIntoConstraints = false
        topicPickerView.hidden = true
        let topics = realm.objects(Topic.self)
        pickerValues = ["Overview"]
        for topic in topics{
            pickerValues.append(topic.title)
        }
        updatePicker()
        updatePickerSelection()
    }
    
    func updatePicker(){
        if let currentTopic = Util().getCurrentTopic() {
            topicPickerView.selectRow(pickerValues.indexOf(currentTopic.title)!, inComponent: 0, animated: false)
        }else{
            topicPickerView.selectRow(0, inComponent: 0, animated: false)
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerValues.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerValues[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        updatePickerSelection()
        restartPickerTimer()
    }
    
    func updatePickerSelection(){
        currentTopicLabel.text = pickerValues[topicPickerView.selectedRowInComponent(0)]
        
        if topicPickerView.selectedRowInComponent(0) != 0 {
            //save selection to realm
            realm.beginWrite()
            //Uncheck all
            let topics = realm.objects(Topic)
            for topic in topics{
                topic.isSelected = false
            }
            //Check just the one selected
            let selectedTopicTitle = pickerValues[topicPickerView.selectedRowInComponent(0)]
            let selectedTopic = realm.objectForPrimaryKey(Topic.self, key: selectedTopicTitle)!
            selectedTopic.isSelected = true
            realm.add(topics)
            try! realm.commitWrite()
            
            //TODO: update charts
            setupBarChartView()
        }
    }
    
    @IBAction func showPickerButtonPressed(sender: AnyObject) {
        self.topicPickerView.alpha = 0
        UIView.animateWithDuration(0.2) { () -> Void in
            if self.topicPickerView.hidden {
                self.topicPickerView.hidden = false
                self.topicPickerView.alpha = 1
                self.restartPickerTimer()
            }else{
                self.topicPickerView.hidden = true
            }
        }
    }
    
    func restartPickerTimer(){
        timer.invalidate()
        let aSelector : Selector = #selector(StatisticsViewController.hideTopicPicker)
        timer.tolerance = 0.1
        timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: aSelector, userInfo: nil, repeats: false)
    }
    
    func hideTopicPicker(){
        self.topicPickerView.alpha = 0
        UIView.animateWithDuration(0.5) { () -> Void in
            self.topicPickerView.hidden = true
        }
    }
    
    func setupBarChartView(){
        if Util().getCurrentTopic() == nil {
            barChartView.noDataText = "No topic selected"
        }else{
            barChartView.noDataText = "No data yet"
            displayedStatistics = Util().getNLatestStatistics(7, topic: Util().getCurrentTopic()!)
            if !displayedStatistics.isEmpty {
                var dates:[String] = []
                var scores:[Double] = []
                
                let dayDateFormatter = NSDateFormatter()
                let hourDateFormatter = NSDateFormatter()
                dayDateFormatter.dateFormat = "dd.MM" //"yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                hourDateFormatter.dateFormat = "HH:mm"
                
                for i in 0..<displayedStatistics.count {
                    if displayedStatistics[i].date.timeIntervalSinceNow > NSTimeInterval(-86400) { //86.400 seconds = one day
                        dates.append(hourDateFormatter.stringFromDate(displayedStatistics[i].date))
                    }else{
                        dates.append(dayDateFormatter.stringFromDate(displayedStatistics[i].date))
                    }
                    scores.append(displayedStatistics[i].percentageScore)
                }
                var dataEntries: [BarChartDataEntry] = []
                
                for i in 0..<dates.count {
                    let dataEntry = BarChartDataEntry(value: scores[i], xIndex: i)
                    dataEntries.append(dataEntry)
                }
                let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Prozent")
                let chartData = BarChartData(xVals: dates, dataSet: chartDataSet)
                barChartView.data = chartData
                
                chartDataSet.highlightAlpha = 0.3
                chartDataSet.highlightColor = UIColor.whiteColor()
                var chartColors: [UIColor] = []
                for i in 0 ..< displayedStatistics.count {
                    let topicColor = displayedStatistics[i].topic!.color!
                    let topicUIColor = UIColor(red: CGFloat(topicColor.red)/255, green: CGFloat(topicColor.green)/255, blue: CGFloat(topicColor.blue)/255, alpha: 1)
                    chartColors.append(topicUIColor)
                }
                chartDataSet.colors = chartColors
//                chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)] //orange
                barChartView.descriptionText = ""
                barChartView.animate(yAxisDuration: 2.0, easingOption: .EaseInOutCubic)
                barChartView.xAxis.labelPosition = .Bottom
                barChartView.xAxis.labelRotationAngle = -45
                barChartView.xAxis.setLabelsToSkip(0)
                barChartView.drawValueAboveBarEnabled = false
                barChartView.setScaleEnabled(false)
                barChartView.leftAxis.customAxisMin = 0
                barChartView.leftAxis.customAxisMax = 100
                barChartView.rightAxis.enabled = false
                barChartView.leftAxis.enabled = false
                barChartView.legend.enabled = false
                barChartView.leftAxis.labelCount = 2
                barChartView.leftAxis.drawGridLinesEnabled = false
                barChartView.rightAxis.drawGridLinesEnabled = false
                barChartView.xAxis.drawGridLinesEnabled = false
                
                //        let ll = ChartLimitLine(limit: 50)
                //        barChartView.rightAxis.addLimitLine(ll)
            }else{
                barChartView.clear()
            }
        }
        barChartView.setNeedsDisplay()
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        let statistic = displayedStatistics[entry.xIndex]
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy 'at' HH:mm" //"yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        barChartDateLabel.text = "Date: " + dateFormatter.stringFromDate(statistic.date)
        barChartScoreLabel.text = "Score: \(NSString(format: "%.2f", statistic.score)) out of \(statistic.numberOfQuestions)"
    }
    
    
}

