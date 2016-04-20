//
//  Question.swift
//  QuizGame
//
//  Created by Paul McDonald  on 4/20/16.
//  Copyright © 2016 Paul McDonald . All rights reserved.
//

import Foundation

class Question {
    var number: Int!
    var questionSentence: String!
    var options: [String : String]!
    var correctOption: String!
    
    init(number: Int, questionSentence: String, options: [String: String], correctOption: String){
        self.number = number
        self.questionSentence = questionSentence
        self.options = options
        self.correctOption = correctOption
    }
    
    func getNumber() -> Int {
        return self.number
    }
    
    func getQuestion() -> String {
        return self.questionSentence
    }
    
    func getOptions() -> [String: String] {
        return self.options
    }
    
    func getCorrectOption() -> String  {
        return self.correctOption
    }
}
