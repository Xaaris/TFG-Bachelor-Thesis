//
//  FirstViewController.swift
//  TFG
//
//  Created by Johannes Berger on 14.02.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Main View")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loadExampleDataButtonPressed(sender: AnyObject) {
        if let keyedRowsDic = loadDataFromFile("Sample1"){
//            print(keyedRowsDic)
            var title = ""
            var author = ""
            var date = ""
            var universalTags = Set<String>()
            for row in keyedRowsDic{
//                print(row)
                //Info row
                if row["QuestionType"] == "Info"{
                    title = row["Question"]!.isEmpty ? "No title" : row["Question"]!
                    author = row["Hint"]!.isEmpty ? "No author" : row["Hint"]!
                    date = row["Feedback"]!.isEmpty ? "No Date" : row["Feedback"]!
                    for tag in row.values{
                        if !tag.isEmpty{
                            universalTags.insert(tag)
                        }
                    }
                    universalTags.remove(title)
                    universalTags.remove(author)
                    universalTags.remove(date)
                    universalTags.remove("Info")
                //Normal row
                }else if !row["QuestionType"]!.isEmpty {
                    if let type = row["QuestionType"], question = row["Question"], hint = row["Hint"], feedback = row["Feedback"], difficulty = row["Difficulty"], correctAnswers = row["CorrectAnswers"]?.componentsSeparatedByString(","){
                        var tmpAnswerDic = [String:String]()
                        var answers = [String: Bool]()
                        var tags = universalTags
                        //extracting answers and tags
                        for cell in row{
                            if cell.0.containsString("Answer") && !cell.0.containsString("C") && !cell.1.isEmpty{
                                tmpAnswerDic[cell.0.lowercaseString.stringByReplacingOccurrencesOfString("answer", withString: "")] = cell.1
                            }else if cell.0.containsString("Tag") && !cell.1.isEmpty{
                                tags.insert(cell.1)
                            }
                        }
                        //mapping answers with their value of truth
                        for answerKey in tmpAnswerDic.keys {
                            if correctAnswers.contains(answerKey){
                                answers[tmpAnswerDic[answerKey]!] = true
                            }else{
                                answers[tmpAnswerDic[answerKey]!] = false
                            }
                        }
                        
                        print("Type: \(type)")
                        print("question: \(question)")
                        print("Hint: \(hint)")
                        print("Feedback: \(feedback)")
                        print("Difficulty: \(difficulty)")
                        print("CorrectAnswers: \(correctAnswers)")
                        print("Answers: \(answers)")
                        print("Tags: \(tags)")
                        print("")
                        
                        
                    }else{
                        print("Unwrapping type, Question, Hint, Feedback or CorrectAnswers failed!")
                    }
                }
            }
            print("Title: \(title)")
            print("Author: \(author)")
            print("Date: \(date)")
            print("Tags: \(universalTags)")
        }else{
            print("Could not load Data")
        }
        
    }
    
    func loadDataFromFile(fileName: String) -> [[String : String]]? {
        let csvURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(fileName, ofType: "csv")!)
        //                print(csvURL)
        do{
            let text = try String(contentsOfURL: csvURL)
            let csv = CSwiftV(String: text, separator: ";")
            //            let rows = csv.rows
            //            let headers = csv.headers
            let keyedRows = csv.keyedRows!
            //            print(headers)
            //            print(rows)
            //            print("")
            //            print(keyedRows[1])
            //            print(keyedRows[2])
            //            print(keyedRows[3])
            return keyedRows
        }catch{
            print(error)
        }
        return nil
    }
    
}

