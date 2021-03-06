//
//  StatisticsViewController.swift
//  TFG
//
//  Created by Johannes Berger on 14.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit
import Charts
import Parse

///View controller for the statistics scene
class StatisticsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, ChartViewDelegate {
    
    @IBOutlet weak var topicPickerStackView: UIStackView!
    @IBOutlet weak var currentTopicLabel: UILabel!
    @IBOutlet weak var topicPickerView: UIPickerView!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var barChartTopicLabel: UILabel!
    @IBOutlet weak var barChartDateLabel: UILabel!
    @IBOutlet weak var barChartScoreLabel: UILabel!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var pickerValues:[String] = []
    var timer = NSTimer()
    var displayedStatistics: [Statistic] = []
    var overviewWasSelected = false
    var refresher: UIRefreshControl!
    
    ///Initializes the view
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Statistics View")
        //select overview if no topic is selected
        if Util.getCurrentTopic() == nil{
            overviewWasSelected = true
        }
        barChartView.delegate = self
        setupTopicPicker()
        //Highlights last value in bar chart view
        barChartView.highlightValue(xIndex: displayedStatistics.count - 1, dataSetIndex: 0, callDelegate: true)
        addRefresher()
        refreshStatistics()
    }
    
    ///Prepare view for appearance
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updatePicker()
        updatePickerSelection()
        setupCharts()
        reloadCharts()
        resetLabels()
    }
    
    func resetLabels(){
        if displayedStatistics.isEmpty{
            barChartTopicLabel.text = NSLocalizedString("Topic: No topic selected", comment: "")
            barChartDateLabel.text = NSLocalizedString("Date: No data", comment: "")
            barChartScoreLabel.text = NSLocalizedString("Score: No data", comment: "")
        }
    }
    
    ///Adds the "Pull to refresh" mechanism
    func addRefresher(){
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(StatisticsViewController.refreshStatistics), forControlEvents: .ValueChanged)
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to refresh", comment: "message for the refresher"))
        scrollView.addSubview(refresher)
    }
    
    /**
     Loads the statistics asociated with the current user asynchronisly and saves them to the Realm database
     */
    func refreshStatistics(){
        
        refresher.beginRefreshing()
        //Stop if there is no internet connection
        if !CloudLink.isConnected(){
            refresher.endRefreshing()
        }else{
            
            //Load new Statistics
            let query = PFQuery(className: "Statistic")
            query.whereKey("userID", equalTo: (PFUser.currentUser()?.objectId)!)
            query.findObjectsInBackgroundWithBlock { (objects, error) in
                if error == nil {
                    if let stats = objects{
                        
                        //Delete old statistics
                        Util.deleteStatisticsLocally()
                        
                        for cloudStat in stats{
                            if let topic = Util.getTopicWithTitle(cloudStat["topic"] as! String){
                                realm.beginWrite()
                                let localStat = Statistic()
                                localStat.topic = topic
                                localStat.score = cloudStat["score"] as! Double
                                localStat.startTime = cloudStat["startTime"] as! NSDate
                                localStat.endTime = cloudStat["endTime"] as! NSDate
                                realm.add(localStat)
                                try! realm.commitWrite()
                            }else{
                                print("Error: Topic does not exist")
                            }
                        }
                        print("Successfully downloaded Statistics")
                        self.reloadCharts()
                        self.refresher.endRefreshing()
                    }
                }else{
                    print("Error: \(error!.userInfo["error"])")
                }
            }
        }
    }
    
    ///Calls setup on all charts
    func setupCharts(){
        setupBarChartView()
        setupPieChartView()
    }
    
    ///Reloads all charts. Takes into account if overview should be displayed
    func reloadCharts(){
        reloadBarChartData(overviewWasSelected)
        reloadPieChartData()
    }
    
    ///Initializes the picker view
    func setupTopicPicker() {
        topicPickerStackView.translatesAutoresizingMaskIntoConstraints = false
        topicPickerView.hidden = true
        updatePicker()
        updatePickerSelection()
    }
    
    ///Updates the picker with the current values it should display
    func updatePicker(){
        let topics = realm.objects(Topic.self)
        pickerValues = [NSLocalizedString("Overview", comment: "Name for overview in topic picker")]
        for topic in topics{
            pickerValues.append(topic.title)
        }
        var rowToSelect = 0
        if !overviewWasSelected {
            if let currentTopic = Util.getCurrentTopic() {
                rowToSelect = pickerValues.indexOf(currentTopic.title)!
            }
        }
        topicPickerView.selectRow(rowToSelect, inComponent: 0, animated: false)
    }
    
    ///Just one component is needed in the picker
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    ///Number of topics plus one row for the overview
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerValues.count
    }
    
    ///The picker displays the topics plus the overview
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerValues[row]
    }
    
    ///Updates the picker view when called and restarts the picker timer
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        updatePickerSelection()
        restartPickerTimer()
    }
    
    ///Updates the picker view and takes action accordingly
    func updatePickerSelection(){
        currentTopicLabel.text = pickerValues[topicPickerView.selectedRowInComponent(0)]
        
        if topicPickerView.selectedRowInComponent(0) != 0 {
            //save selection to realm
            realm.beginWrite()
            //Uncheck all topics
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
            
            overviewWasSelected = false
            reloadCharts()
            
            // topic is only shown in overview
            barChartTopicLabel.hidden = true
        }else{
            overviewWasSelected = true
            reloadCharts()
            barChartTopicLabel.hidden = false
        }
    }
    
    ///Invoked by tapping the big topic label up top. It will show the picker and start the picker timer
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
    
    ///The picker timer is used to autohide the picker. When it fires it calls hideTopicPicker
    func restartPickerTimer(){
        timer.invalidate()
        let aSelector : Selector = #selector(StatisticsViewController.hideTopicPicker)
        timer.tolerance = 0.1
        timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: aSelector, userInfo: nil, repeats: false)
    }
    
    ///This will hide the topic picker. It is either called manully by tapping the topic label or from the topic picker timer
    func hideTopicPicker(){
        self.topicPickerView.alpha = 0
        UIView.animateWithDuration(0.5) { () -> Void in
            self.topicPickerView.hidden = true
        }
    }
    
    ///Initializes the bar chart view
    func setupBarChartView(){
        barChartView.descriptionText = ""
        barChartView.animate(yAxisDuration: 2.0, easingOption: .EaseInOutCubic)
        barChartView.xAxis.labelPosition = .Bottom
        barChartView.xAxis.labelRotationAngle = -60
        barChartView.xAxis.setLabelsToSkip(0)
        barChartView.drawValueAboveBarEnabled = false
        barChartView.setScaleEnabled(false)
        barChartView.leftAxis.axisMinValue = 0
        barChartView.leftAxis.axisMaxValue = 100
        barChartView.rightAxis.enabled = false
        barChartView.leftAxis.enabled = false
        barChartView.legend.enabled = false
        barChartView.leftAxis.drawGridLinesEnabled = false
        barChartView.rightAxis.drawGridLinesEnabled = false
        barChartView.xAxis.drawGridLinesEnabled = false
    }
    
    /**
     Checks if data has changed and if so, reloads the bar chart view.
     - parameters:
     - overview: boolean that determins if the overview bar chart view is presented or not
     */
    func reloadBarChartData(overview: Bool) {
        let oldStatistics = displayedStatistics
        //getting new statistics
        if overview || Util.getCurrentTopic() == nil{
            displayedStatistics = Util.getNLatestStatistics(14)
            barChartView.noDataText = NSLocalizedString("No topic selected", comment: "")
        }else{
            displayedStatistics = Util.getNLatestStatisticsOfTopic(10, topic: Util.getCurrentTopic()!)
            barChartView.noDataText = NSLocalizedString("No data yet", comment: "")
        }
        //Check if something changed
        if oldStatistics != displayedStatistics{
            if !displayedStatistics.isEmpty {
                var dates:[String] = []
                var scores:[Double] = []
                
                //Preparing formatters
                let currentLocaleFormater = NSDateFormatter.dateFormatFromTemplate("MMdd", options: 0, locale: NSLocale.currentLocale())
                let dayDateFormatter = NSDateFormatter()
                let hourDateFormatter = NSDateFormatter()
                //This will set the format to the current Locale specified by the user
                dayDateFormatter.dateFormat =  currentLocaleFormater //"dd.MM" //"yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                hourDateFormatter.dateFormat = "HH:mm"
                let numberFormatter = NSNumberFormatter()
                numberFormatter.minimumIntegerDigits = 1
                numberFormatter.maximumFractionDigits = 1
                
                //Preparing data labels
                for i in 0..<displayedStatistics.count {
                    if displayedStatistics[i].startTime.timeIntervalSinceNow > NSTimeInterval(-86400) { //86.400 seconds = one day
                        dates.append(hourDateFormatter.stringFromDate(displayedStatistics[i].startTime))
                    }else{
                        dates.append(dayDateFormatter.stringFromDate(displayedStatistics[i].startTime))
                    }
                    scores.append(displayedStatistics[i].percentageScore)
                }
                //Preparing chart data
                var dataEntries: [BarChartDataEntry] = []
                for i in 0..<dates.count {
                    let dataEntry = BarChartDataEntry(value: scores[i], xIndex: i)
                    dataEntries.append(dataEntry)
                }
                let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Prozent")
                let chartData = BarChartData(xVals: dates, dataSet: chartDataSet)
                chartData.setValueFormatter(numberFormatter)
                chartData.setValueTextColor(UIColor.whiteColor())
                barChartView.data = chartData
                
                chartDataSet.highlightAlpha = 0.3
                chartDataSet.highlightColor = UIColor.whiteColor()
                
                //getting chart colors from topics
                var chartColors: [UIColor] = []
                for i in 0 ..< displayedStatistics.count {
                    let topicColor = displayedStatistics[i].topic!.color!
                    let topicUIColor = UIColor(red: CGFloat(topicColor.red)/255, green: CGFloat(topicColor.green)/255, blue: CGFloat(topicColor.blue)/255, alpha: 1)
                    chartColors.append(topicUIColor)
                }
                chartDataSet.colors = chartColors
                
                //Show limit line when overview is not selected
                barChartView.leftAxis.removeAllLimitLines()
                if !overview{
                    if let limitLine = buildLimitLine(){
                        barChartView.leftAxis.addLimitLine(limitLine)
                    }
                }
            }else{
                barChartView.clear()
            }
        }
        barChartView.setNeedsDisplay()
    }
    
    /**
     Builds and returns the limitline for the global average
     - returns: Limitline in case of success, else nil
     */
    func buildLimitLine() -> ChartLimitLine?{
        if let currentTopic = Util.getCurrentTopic(){
            let globalAverage = currentTopic.globalAverage * 100
            let limitLine = ChartLimitLine(limit: globalAverage, label: NSLocalizedString("Global Average", comment: "for limit line"))
            let greyColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 0.7)
            limitLine.lineColor = greyColor
            limitLine.valueTextColor = greyColor
            limitLine.labelPosition = .LeftTop
            limitLine.valueFont = NSUIFont.systemFontOfSize(10.0)
            limitLine.lineDashLengths = [7,5]
            limitLine.lineWidth = 0.5
            return limitLine
        }
        print("Error: currentTopic was nil")
        return nil
    }
    
    ///Initialzes the pie chart view
    func setupPieChartView() {
        pieChartView.descriptionText = ""
        pieChartView.animate(yAxisDuration: 2.0, easingOption: .EaseInOutCubic)
        //        pieChartView.drawHoleEnabled = false
        pieChartView.drawSliceTextEnabled = false
    }
    
    /**
     Reloads the pie chart view.
     */
    func reloadPieChartData() {
        
        pieChartView.noDataText = NSLocalizedString("No data yet", comment: "")
        
        //Preparing chart data and colors
        var dataEntries: [ChartDataEntry] = []
        var colors: [UIColor] = []
        let topics = realm.objects(Topic)
        var topicTitles: [String] = []
        for (i,topic) in topics.enumerate(){
            let dataEntry = ChartDataEntry(value: topic.timeStudied / 60 , xIndex: i) // in minutes
            dataEntries.append(dataEntry)
            topicTitles.append(topic.title)
            let topicColor = topic.color!
            let color = UIColor(red: CGFloat(topicColor.red)/255, green: CGFloat(topicColor.green)/255, blue: CGFloat(topicColor.blue)/255, alpha: 1)
            colors.append(color)
        }
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        pieChartDataSet.colors = colors
        let pieChartData = PieChartData(xVals: topicTitles, dataSet: pieChartDataSet)
        let numberFormatter = NSNumberFormatter()
        numberFormatter.minimumIntegerDigits = 1
        numberFormatter.maximumFractionDigits = 1
        pieChartData.setValueFormatter(numberFormatter)
        pieChartView.data = pieChartData
    }
    
    /**
     Called when a bar in the barchartview is selected. It updates the description with the values of the currently selected statistic
     - parameters:
     - chartView: sender chart view
     - entry: selected entry
     - dataSetIndex: index in dataset
     - highlight: which highlight to apply
     */
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        let statistic = displayedStatistics[entry.xIndex]
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        let numberFormatter = NSNumberFormatter()
        numberFormatter.minimumIntegerDigits = 1
        numberFormatter.maximumFractionDigits = 2
        barChartTopicLabel.text = NSLocalizedString("Topic: ", comment: "") + statistic.topic!.title
        barChartDateLabel.text = NSLocalizedString("Date: ", comment: "") + dateFormatter.stringFromDate(statistic.startTime)
        barChartScoreLabel.text = NSLocalizedString("Score: ", comment: "") + numberFormatter.stringFromNumber(statistic.score)! + NSLocalizedString(" out of ", comment: "For Score x out of x") + String(statistic.numberOfQuestions)
    }
    
    
}

