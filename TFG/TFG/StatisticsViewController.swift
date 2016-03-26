//
//  SecondViewController.swift
//  TFG
//
//  Created by Johannes Berger on 14.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit
import Charts

class StatisticsViewController: UIViewController {

    @IBOutlet weak var barChartView: BarChartView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Statistics View")
        let stats = Util().getNLatestStatistics(5, topic: Util().getCurrentTopic()!)
        for stat in stats {
            print(stat.date)
        }
        setupBarChartView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupBarChartView(){
        barChartView.noDataText = "No data yet"
        let stats = Util().getNLatestStatistics(7, topic: Util().getCurrentTopic()!)
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
    }
    
    
}

