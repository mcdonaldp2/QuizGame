//
//  SingleQuizViewController.swift
//  QuizGame
//
//  Created by Paul McDonald  on 4/24/16.
//  Copyright © 2016 Paul McDonald . All rights reserved.
//

import UIKit

class SingleQuizViewController: UIViewController {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var answerImage: UIImageView!
    
    @IBOutlet weak var aButton: UIButton!
    @IBOutlet weak var bButton: UIButton!
    @IBOutlet weak var cButton: UIButton!
    @IBOutlet weak var dButton: UIButton!
    
    
    var qHandler: QuestionHandler!
    var currentQuestion: Question!
    var questionCount: Int!
    
    var questionTimer: NSTimer!
    var timerCount: Int!
    
    var answer: String!
    var answered: Bool!
    
    var nextQuestionTimer: NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playQuiz()
    }
    
    @IBAction func answerAction(sender: UIButton) {
        answerImage.hidden = false
        
        if answered != true {
            switch sender.tag {
            case 0 :
                answer = "A"
                checkAnswer("A")
                answerImage.image = UIImage(named: "aIcon")
                break
            case 1 :
                answer = "B"
                checkAnswer("B")
                answerImage.image = UIImage(named: "bIcon")
                break
            case 2 :
                answer = "C"
                checkAnswer("C")
                answerImage.image = UIImage(named: "cIcon")
                break
            case 3:
                answer = "D"
                checkAnswer("D")
                answerImage.image = UIImage(named: "dIcon")
                break
            default:
                break
            }
            answered = true
        }
    }
    
    func checkTime(){
        timerCount = timerCount - 1
        
        if timerCount <= 0 {
            questionTimer.invalidate()
            nextQuestion()
        }
        timerLabel.text = String(timerCount)
    }
    
    func checkAnswer(answer: String) {
        questionTimer.invalidate()
       
        if currentQuestion.correctOption == answer {
            print("That's correct!")
            
            
        }else{
            print("wrong")
        }
        
        if questionCount < qHandler.questionCount {
        nextQuestionTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("nextQuestion"), userInfo: nil, repeats: false)
        }
        
    }
    
    func nextQuestion(){
        questionCount = questionCount + 1
        
        
        if questionCount < qHandler.questionCount {
            timerCount = 20
            timerLabel.text = String(timerCount)
            questionTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("checkTime"), userInfo: nil, repeats: true)
            setQuestion(qHandler.questionArray[questionCount])
            answered = false
            answerImage.hidden = true
        }
        else {
            print("Quiz is over!")
            
            let gameOverAlert = UIAlertController(title: "Quiz Over!", message: "All data will be lost.", preferredStyle: UIAlertControllerStyle.Alert)
            
            gameOverAlert.addAction(UIAlertAction(title: "Back To Menu", style: .Default, handler: { (action: UIAlertAction!) in
                print("Handle Ok logic here")
            }))
            
            gameOverAlert.addAction(UIAlertAction(title: "Replay Quiz", style: .Default, handler: { (action: UIAlertAction!) in
                print("Handle Cancel Logic here")
                self.playQuiz()
            }))
            
            presentViewController(gameOverAlert, animated: true, completion: nil)
        }
        
    }
    
    func setQuestion(question: Question) {
       // nextQuestionTimer.invalidate()
        currentQuestion = question
        var options = question.getOptions()
        
        questionLabel.text = question.getQuestion()
        
        aButton.setTitle("A) " + options["A"]!, forState: .Normal)
        bButton.setTitle("B) " + options["B"]!, forState: .Normal)
        cButton.setTitle("C) " + options["C"]!, forState: .Normal)
        dButton.setTitle("D) " + options["D"]!, forState: .Normal)
        
    }
    
    func playQuiz() {
        
        answered = false
        answerImage.hidden = true
        
        timerCount = 20
        timerLabel.text = String(timerCount)
        questionTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("checkTime"), userInfo: nil, repeats: true)
        questionCount = 0
        setQuestion(qHandler.questionArray[0])
    }
    
    
    
}
