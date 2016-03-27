//
//  SecondViewController.swift
//  TFG
//
//  Created by Johannes Berger on 14.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit
import Charts

class StatisticsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var topicPickerStackView: UIStackView!
    @IBOutlet weak var currentTopicLabel: UILabel!
    @IBOutlet weak var topicPickerView: UIPickerView!
    @IBOutlet weak var barChartView: BarChartView!
    
    var pickerValues:[String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Statistics View")
        setupTopicPicker()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
        let topicPicker = topicPickerStackView.arrangedSubviews[1]
        UIView.animateWithDuration(0.2) { () -> Void in
            if topicPicker.hidden {
                topicPicker.hidden = false
            }else{
                topicPicker.hidden = true
            }
        }
    }
    func setupBarChartView(){
        if Util().getCurrentTopic() == nil {
            barChartView.noDataText = "No topic selected"
        }else{
            barChartView.noDataText = "No data yet"
            let stats = Util().getNLatestStatistics(7, topic: Util().getCurrentTopic()!)
            if !stats.isEmpty {
                var dates:[String] = []
                var scores:[Double] = []
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = .ShortStyle
                dateFormatter.timeStyle = .NoStyle
                
                for i in 0..<stats.count {
                    dates.append(dateFormatter.stringFromDate(stats[i].date))
                    scores.append(stats[i].percentageScore)
                }
                var dataEntries: [BarChartDataEntry] = []
                
                for i in 0..<dates.count {
                    let dataEntry = BarChartDataEntry(value: scores[i], xIndex: i)
                    dataEntries.append(dataEntry)
                }
                let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Prozent")
                let chartData = BarChartData(xVals: dates, dataSet: chartDataSet)
                barChartView.data = chartData
                
                chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
                barChartView.descriptionText = ""
                barChartView.animate(yAxisDuration: 2.0, easingOption: .EaseInOutCubic)
                barChartView.xAxis.labelPosition = .Bottom
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
    
    
}

