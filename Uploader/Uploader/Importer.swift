//
//  Importer.swift
//  Uploader
//
//  Created by Johannes Berger on 24.06.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import Foundation

class Importer {
    
    func loadAndSave(filename: String, ext: String){
        var optionalKeyedRows = [[String : String]]?()
        switch ext {
        case "csv":
            optionalKeyedRows = loadDataFromFile(filename)
        case "xml":
            let xmlParser = XMLParser()
            optionalKeyedRows = xmlParser.parseXML(filename)
        default:
            print("Error: unrecognized extension")
        }
        if let keyedRowsDic = optionalKeyedRows{
            if checkCSV(keyedRowsDic) {
                parseDataForValuesAndSaveToRealm(keyedRowsDic)
            }else{
                print("CSV check failed")
            }
        }else{
            print("Could not load Data")
        }
    }
    
    private func loadDataFromFile(fileName: String) -> [[String : String]]? {
        let csvURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(fileName, ofType: "csv")!)
        do{
            let text = try String(contentsOfURL: csvURL)
            let csvImporter = CSVParser(String: text, separator: ";")
            if let keyedRows = csvImporter.keyedRows{
                return keyedRows
            }
        }catch{
            print(error)
        }
        return nil
    }
    
    private func parseDataForValuesAndSaveToRealm(keyedRowsDic: [[String:String]]) {
        var topic = Topic()
        var counter = 1
        for row in keyedRowsDic{
            //Info row
            if row["QuestionType"] == "Info"{
                print("Parsing header")
                topic = getTopic(row)
                //Normal row
            }else if !row["QuestionType"]!.isEmpty {
                print("Parsing question \(counter)")
                counter += 1
                if let question = buildQuestionFromRow(row, topic: topic){
                    print(question)
                    saveToRealm(question)
                }else{
                    print("could not build a question")
                }
            }
        }
        saveToRealm(topic)
    }
    
    private func getTopic(row: [String:String]) -> Topic{
        let topic = Topic()
        topic.title = row["Question"]!.isEmpty ? "No title" : row["Question"]!
        topic.author = row["Hint"]!.isEmpty ? "No author" : row["Hint"]!
        topic.date = row["Feedback"]!.isEmpty ? "No Date" : row["Feedback"]!
        topic.color = Util.getUnassignedColor()
        return topic
    }
    
    private func buildQuestionFromRow(row: [String:String], topic: Topic) -> Question? {
        
        if let type = row["QuestionType"], question = row["Question"], hint = row["Hint"], feedback = row["Feedback"], picURL = row["Pic-URL"], correctAnswers = row["CorrectAnswers"]?.componentsSeparatedByString(","){
            var tmpAnswerDic = [String:String]()
            var answers = [String: Bool]()
            //extracting answers
            for cell in row{
                if cell.0.containsString("Answer") && !cell.0.containsString("C") && !cell.1.isEmpty{
                    tmpAnswerDic[cell.0.lowercaseString.stringByReplacingOccurrencesOfString("answer", withString: "")] = cell.1
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
            
            //Building a Question
            let tmpQuestion = Question()
            tmpQuestion.topic = topic
            tmpQuestion.type = type
            tmpQuestion.questionText = question
            tmpQuestion.hint = hint
            tmpQuestion.feedback = feedback
            tmpQuestion.picURL = picURL
            
            //Creating the answers
            for answer in answers {
                let tmpAnswer = Answer()
                tmpAnswer.answerText = answer.0
                tmpAnswer.isCorrect = answer.1
                tmpAnswer.associatedQuestion = tmpQuestion
                realm.beginWrite()
                realm.add(tmpAnswer)
                try! realm.commitWrite()
                
            }
            
            return tmpQuestion
        }else{
            print("Unwrapping type, Question, Hint, Feedback or CorrectAnswers failed!")
        }
        return nil
    }
    
    private func saveToRealm(question: Question){
        realm.beginWrite()
        realm.add(question)
        try! realm.commitWrite()
    }
    
    private func saveToRealm(topic: Topic){
        //Save topic to realm
        realm.beginWrite()
        if realm.objectForPrimaryKey(Topic.self, key: topic.title) == nil {
            realm.add(topic)
        }
        try! realm.commitWrite()
    }
    
    private func checkCSV(keyedRows: [[String:String]]) -> Bool {
        
        if !checkHeaderRow(keyedRows[0]){
            print("Header is faulty")
            return false
        }
        for i in Range(1 ..< keyedRows.count){
            if !checkBodyRow(keyedRows[i]){
                print("Body row \(i) is faulty")
                return false
            }
        }
        return true
    }
    
    private func checkHeaderRow(headerRow: [String:String]) -> Bool {
        //Check if keys exist
        if headerRow["QuestionType"] != "Info"{
            print("Info missing")
            return false
        }
        if headerRow["Question"] == nil || headerRow["Question"]!.isEmpty{
            print("Title missing")
            return false
        }
//        Not necessary
//        if headerRow["Hint"] == nil || headerRow["Hint"]!.isEmpty{
//            print("Author missing")
//            return false
//        }
//        if headerRow["Feedback"] == nil || headerRow["Feedback"]!.isEmpty{
//            print("Date missing")
//            return false
//        }
//        if headerRow["CorrectAnswers"] == nil || headerRow["Answer1"] == nil || headerRow["Answer2"] == nil{
//            print("Columns missing")
//            return false
//        }
        return true
    }
    
    private func checkBodyRow(bodyRow: [String:String]) -> Bool {
        let questionTypes: Set = ["SingleChoice", "TrueFalse", "MultipleChoice"]
        if !bodyRow["QuestionType"]!.isEmpty {
            if !questionTypes.contains(bodyRow["QuestionType"]!){
                print("QuestionType wrong")
                return false
            }
            if bodyRow["Question"] == nil || bodyRow["Question"]!.isEmpty{
                print("Question missing")
                return false
            }
            if bodyRow["CorrectAnswers"] == nil || bodyRow["CorrectAnswers"]!.isEmpty {
                print("CorrectAnswers missing")
                return false
            }
            var numberOfAnswers = 0
            for cell in bodyRow{
                if cell.0.containsString("Answer") && !cell.0.containsString("C") && !cell.1.isEmpty{
                    numberOfAnswers += 1
                }
            }
            let correctAnswersArr = bodyRow["CorrectAnswers"]!.componentsSeparatedByString(",")
            for i in correctAnswersArr{
                if Int(i) == nil{
                    print("CorrectAnswers not convertable to int")
                    return false
                }
                if Int(i) > numberOfAnswers{
                    print("CorrectAnswers out of bounds")
                    return false
                }
            }
            if bodyRow["QuestionType"] == "SingleChoice"{
                if correctAnswersArr.count != 1{
                    print("CorrectAnswers.count revealed wrong number")
                    return false
                }
            }
            if bodyRow["Answer1"] == nil || bodyRow["Answer1"]!.isEmpty{
                print("First answer missing")
                return false
            }
            if bodyRow["Answer2"] == nil || bodyRow["Answer2"]!.isEmpty{
                print("Second answer missing")
                return false
            }
        }
        
        return true
    }
}
