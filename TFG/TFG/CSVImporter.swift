//
//  CSVImporter.swift
//  CSwiftV
//
//  Created by Daniel Haight on 30/08/2014.
//  Copyright (c) 2014 ManyThings. All rights reserved.
//
//  Modified by Johannes Berger
//

import Foundation

//TODO: make these prettier and probably not extensions
public extension String {
    func splitOnNewLine () -> ([String]) {
        return self.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
    }
}

//MARK: Parser
public class CSVImporter {
    
    public let columnCount: Int
    public let headers: [String]
    public let keyedRows: [[String: String]]?
    public let rows: [[String]]
    
    public init(String string: String, headers: [String]?, separator: String) {
        
        let lines: [String] = includeQuotedStringInFields(Fields: string.splitOnNewLine().filter{(includeElement: String) -> Bool in
            return !includeElement.isEmpty
            }, quotedString: "\r\n")
        
        var parsedLines = lines.map{
            (transform: String) -> [String] in
            let commaSanitized = includeQuotedStringInFields(Fields: transform.componentsSeparatedByString(separator),quotedString: separator)
                .map
                {
                    (input: String) -> String in
                    return sanitizedStringMap(String: input)
                }
                .map
                {
                    (input: String) -> String in
                    return input.stringByReplacingOccurrencesOfString("\"\"", withString: "\"", options: NSStringCompareOptions.LiteralSearch)
            }
            
            return commaSanitized
        }
        
        let tempHeaders: [String]
        
        if let unwrappedHeaders = headers {
            tempHeaders = unwrappedHeaders
        }
        else {
            tempHeaders = parsedLines[0]
            parsedLines.removeAtIndex(0)
        }
        
        self.rows = parsedLines
        self.columnCount = tempHeaders.count
        
        let keysAndRows = self.rows.map { (field: [String]) -> [String: String] in
            
            var row = [String: String]()
            
            for (index, value) in field.enumerate() {
                row[tempHeaders[index]] = value
            }
            
            return row
        }
        
        self.keyedRows = keysAndRows
        self.headers = tempHeaders
    }
    
    //TODO: Document that this assumes header string
    public convenience init(String string: String) {
        self.init(String: string, headers: nil, separator: ",")
    }
    
    public convenience init(String string: String, separator: String) {
        self.init(String: string, headers: nil, separator: separator)
    }
    
    public convenience init(String string: String, headers: [String]?) {
        self.init(String: string, headers: headers, separator: ",")
    }
    
}

//MARK: Helpers
func includeQuotedStringInFields(Fields fields: [String], quotedString: String) -> [String] {
    
    var mergedField = ""
    var newArray = [String]()
    
    for field in fields {
        mergedField += field
        if mergedField.componentsSeparatedByString("\"").count%2 != 1 {
            mergedField += quotedString
            continue
        }
        newArray.append(mergedField)
        mergedField = ""
    }
    
    return newArray
}

func sanitizedStringMap(String string: String) -> String {
    
    let startsWithQuote = string.hasPrefix("\"")
    let endsWithQuote = string.hasSuffix("\"")
    
    if startsWithQuote && endsWithQuote {
        let startIndex = string.startIndex.advancedBy(1)
        let endIndex = string.endIndex.advancedBy(-1)
        let range = startIndex ..< endIndex
        let sanitizedField = string.substringWithRange(range)
        
        return sanitizedField
    }
    else {
        return string
    }
    
}







class ImportAndSaveHelper {
    
    func loadAndSave(filename: String){
        if let keyedRowsDic = loadDataFromFile(filename){
            parseDataForValuesAndSaveToRealm(keyedRowsDic)
        }else{
            print("Could not load Data")
        }
    }
    
    private func loadDataFromFile(fileName: String) -> [[String : String]]? {
        let csvURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(fileName, ofType: "csv")!)
        do{
            let text = try String(contentsOfURL: csvURL)
            let csvImporter = CSVImporter(String: text, separator: ";")
            if let keyedRows = csvImporter.keyedRows{
                return keyedRows
            }
        }catch{
            print(error)
        }
        return nil
    }
    
    private func parseDataForValuesAndSaveToRealm(keyedRowsDic: [[String:String]]) {
        var universalTags = Set<String>()
        var topic = Topic()
        for row in keyedRowsDic{
            //Info row
            if row["QuestionType"] == "Info"{
                let returnValues = getTopicAndUniversalTags(row)
                universalTags = returnValues.universalTags
                topic = returnValues.topic
                //Normal row
            }else if !row["QuestionType"]!.isEmpty {
                if let question = buildQuestionFromRow(row, topic: topic, universalTags: universalTags){
                    saveToRealm(question)
                }else{
                    print("could not build a question")
                }
            }
        }
        saveToRealm(topic)
    }
    
    private func getTopicAndUniversalTags(row: [String:String]) -> (topic: Topic,universalTags: Set<String>){
        let topic = Topic()
        topic.title = row["Question"]!.isEmpty ? "No title" : row["Question"]!
        topic.author = row["Hint"]!.isEmpty ? "No author" : row["Hint"]!
        topic.date = row["Feedback"]!.isEmpty ? "No Date" : row["Feedback"]!
        var universalTags = Set<String>()
        for tag in row.values{
            if !tag.isEmpty{
                universalTags.insert(tag)
            }
        }
        universalTags.remove(topic.title)
        universalTags.remove(topic.author)
        universalTags.remove(topic.date)
        universalTags.remove("Info")
        return (topic, universalTags)
    }
    
    private func buildQuestionFromRow(row: [String:String], topic: Topic, universalTags: Set<String>) -> Question? {
        if let type = row["QuestionType"], question = row["Question"], hint = row["Hint"], feedback = row["Feedback"], tmpDifficulty = row["Difficulty"], correctAnswers = row["CorrectAnswers"]?.componentsSeparatedByString(","){
            if let difficulty = Int(tmpDifficulty){
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
                
                //Building a Question
                let tmpQuestion = Question()
                tmpQuestion.topic = topic
                tmpQuestion.type = type
                tmpQuestion.questionText = question
                tmpQuestion.hint = hint
                tmpQuestion.feedback = feedback
                tmpQuestion.difficulty = difficulty
                
                //Creating the answers
                for answer in answers {
                    let tmpAnswer = Answer()
                    tmpAnswer.answerText = answer.0
                    tmpAnswer.isCorrect = answer.1
                    tmpAnswer.associatedQuestion = tmpQuestion
                    tmpQuestion.answers.append(tmpAnswer)
                }
                
                //Creating the tags
                for tag in tags {
                    //See if tag already exists
                    if let tagExists = realm.objectForPrimaryKey(Tag.self, key: tag){
                        tmpQuestion.tags.append(tagExists)
                    }else{
                        let newTag = Tag()
                        newTag.tagText = tag
                        tmpQuestion.tags.append(newTag)
                    }
                }
                return tmpQuestion
            }else{
                print("failed to assign difficulty, Int parsing failed")
            }
        }else{
            print("Unwrapping type, Question, Hint, Feedback or CorrectAnswers failed!")
        }
        return nil
    }
    
    private func saveToRealm(question: Question){
        // Save Question
        realm.beginWrite()
        //check if it already exists
        if realm.objectForPrimaryKey(Question.self, key: question.questionText) == nil {
            realm.add(question)
        }else{
            // print("Question with questionText: \(question.questionText) already exists")
        }
        try! realm.commitWrite()
        
    }
    
    private func saveToRealm(topic: Topic){
        //Save topic to realm
        realm.beginWrite()
        if realm.objectForPrimaryKey(Topic.self, key: topic.title) == nil {
            realm.add(topic)
        }else{
           // print("Topic already exists")
        }
        try! realm.commitWrite()
    }
}
