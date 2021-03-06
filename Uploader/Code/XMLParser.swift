//
//  XMLParser.swift
//  Uploader
//
//  Created by Johannes Berger on 24.06.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import Foundation
import SWXMLHash

///Class that parses moodle xml documents (limited functionality)
class XMLParser {
    
    /**
     Parses an xml document and returns an array of dictionaries if no error occurs, else nil
        - parameter filename: String which specifies the file name
        - returns: array of dictionaries, keyed rows
     */
    func parseXML(filename: String) -> [[String:String]]? {
        
        let xmlURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(filename, ofType: "xml")!)
        var xmlStr = ""
        do{
            xmlStr = try String(contentsOfURL: xmlURL)
            let xml = SWXMLHash.parse(xmlStr)
            
            var keyedRowsDic = [[String:String]]()
            
            
            for elem in xml["quiz"]["question"] {
                var row = [String:String]()
                switch elem.element!.attributes["type"]! {
                case "category":
                    row = buildHeaderRow(elem)
                case "multichoice":
                    row = buildMultiChoiceQuestion(elem)
                case "truefalse":
                    row = buildMultiChoiceQuestion(elem)
                default:
                    print("Error: can not handle: \(elem.element!.attributes["type"]!)")
                    return nil
                }
                keyedRowsDic.append(row)
            }
            return keyedRowsDic
            
        } catch _ {
            print("Error: could not convert xml document to string!")
        }
        return nil
    }
    
    /**
     Builds the header row for a topic from a category question. Since many attributes
     are not supported by moodle xml most fields are left empty.
     - parameter elem: XMLIndexer, one question or more specifically the category question
     - returns: dictionary, header or Info row
     */
    func buildHeaderRow(elem: XMLIndexer) -> [String:String] {
        var row = [String:String]()
        row["QuestionType"] = "Info"
        row["Question"] = ""
        row["Hint"] = ""
        row["Feedback"] = ""
        
        if elem["category"]["text"].element?.text != nil {
            row["Question"] = elem["category"]["text"].element!.text!
        }
        return row
    }
    
    /**
     Builds a multiple choice question
     - parameter elem: XMLIndexer, one question from the xml doc
     - returns: dictionary containing the data of the question
     */
    func buildMultiChoiceQuestion(elem: XMLIndexer) -> [String:String] {
        var row = [String:String]()
        row["QuestionType"] = "MultipleChoice"
        row["Question"] = ""
        row["Hint"] = ""
        row["Feedback"] = ""
        row["Pic-URL"] = ""
        row["CorrectAnswers"] = ""
        
        if elem["name"]["text"].element?.text != nil {
            row["Question"] = elem["questiontext"]["text"].element!.text!
        }
        if elem["incorrectfeedback"]["text"].element?.text != nil {
            row["Feedback"] = elem["incorrectfeedback"]["text"].element!.text!
        }
        
        for (index, ans) in elem["answer"].enumerate(){
            
            if ans["text"].element?.text != nil {
                row["Answer\(index + 1)"] = ans["text"].element!.text!
            }
            let fraction = ans.element!.attributes["fraction"]!
            if Int(fraction)! > 0 {
                if row["CorrectAnswers"] != nil {
                    row["CorrectAnswers"] = row["CorrectAnswers"]! + ",\(index + 1)"
                }
                row["CorrectAnswers"] = "\(index + 1)"
            }
        }
        return row
    }
    
}