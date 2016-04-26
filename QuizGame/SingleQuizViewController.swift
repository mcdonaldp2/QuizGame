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
    
    var buttonColor: UIColor!
    var selectedColor: UIColor!
    
    var qHandler: QuestionHandler!
    var currentQuestion: Question!
    var questionCount: Int!
    
    var questionTimer: NSTimer!
    var timerCount: Int!
    
    var answer: String!
    var answered: Bool!
    var correctCount: Int!
    var submitted: Bool!
    
    var nextQuestionTimer: NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = qHandler.topic
        
        buttonColor = dButton.backgroundColor
        selectedColor = UIColor.greenColor()
        
        autoSizeButtonText(aButton)
        autoSizeButtonText(bButton)
        autoSizeButtonText(cButton)
        autoSizeButtonText(dButton)
        
        playQuiz()
    }
    
    func autoSizeButtonText(button: UIButton) {
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.02
    }
    @IBAction func answerAction(sender: UIButton) {
        answerImage.hidden = false
        if submitted != true {
            if answered != true {
                switch sender.tag {
                case 0 :
                    answer = "A"
                    answerImage.image = UIImage(named: "aIcon")
                    break
                case 1 :
                    answer = "B"
                    answerImage.image = UIImage(named: "bIcon")
                    break
                case 2 :
                    answer = "C"
                    answerImage.image = UIImage(named: "cIcon")
                    break
                case 3:
                    answer = "D"
                    answerImage.image = UIImage(named: "dIcon")
                    break
                default:
                    break
            }
                answered = true
                sender.backgroundColor = selectedColor
            } else {
                switch sender.tag {
                case 0 :
                    let secondClick = "A"
                    if secondClick == answer {
                        sender.backgroundColor = UIColor.grayColor()
                        checkAnswer()
                    }else {
                        answered = true
                        resetButtonColor()
                        answer = secondClick
                        sender.backgroundColor = selectedColor
                    }
                    answerImage.image = UIImage(named: "aIcon")
                    break
                case 1 :
                    let secondClick = "B"
                    if secondClick == answer {
                        sender.backgroundColor = UIColor.grayColor()
                        checkAnswer()
                    }else {
                        answered = true
                        resetButtonColor()
                        answer = secondClick
                        sender.backgroundColor = selectedColor
                    }
                    answerImage.image = UIImage(named: "bIcon")
                    break
                case 2 :
                    let secondClick = "C"
                    if secondClick == answer {
                        sender.backgroundColor = UIColor.grayColor()
                        checkAnswer()
                    }else {
                        answered = true
                        resetButtonColor()
                        answer = secondClick
                        sender.backgroundColor = selectedColor
                }
                    answerImage.image = UIImage(named: "cIcon")
                    break
                case 3:
                    let secondClick = "D"
                    if secondClick == answer {
                        sender.backgroundColor = UIColor.grayColor()
                        checkAnswer()
                    }else {
                        answered = true
                        resetButtonColor()
                        answer = secondClick
                        sender.backgroundColor = selectedColor
                    }
                    answerImage.image = UIImage(named: "dIcon")
                    break
                default:
                    break
                }

            }
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
    
    func resetButtonColor(){
        aButton.backgroundColor = buttonColor
        bButton.backgroundColor = buttonColor
        cButton.backgroundColor = buttonColor
        dButton.backgroundColor = buttonColor
    }
    
    func checkAnswer() {
        submitted = true
        questionTimer.invalidate()
       
        if currentQuestion.correctOption == answer {
            correctCount = correctCount + 1
            timerLabel.text = "CORRECT!"
            navigationItem.rightBarButtonItem?.title = "Score: " + String(correctCount)
        }else{
            timerLabel.text = "WRONG ;_;"
        }
        
        if questionCount < qHandler.questionCount {
        nextQuestionTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(SingleQuizViewController.nextQuestion), userInfo: nil, repeats: false)
        }
        
    }
    
    func nextQuestion(){
        resetButtonColor()
        questionCount = questionCount + 1
        
        submitted = false
        
        if questionCount < qHandler.questionCount {
            timerCount = 20
            timerLabel.text = String(timerCount)
            questionTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(SingleQuizViewController.checkTime), userInfo: nil, repeats: true)
            setQuestion(qHandler.questionArray[questionCount])
            answered = false
            answerImage.hidden = true
        }
        else {
            print("Quiz is over!")
            questionTimer.invalidate()
            nextQuestionTimer.invalidate()
            
            let gameOverAlert = UIAlertController(title: "Quiz Over!", message: "You got " + String(correctCount) + " out of " + String(qHandler.questionCount) + " correct. ", preferredStyle: UIAlertControllerStyle.Alert)
            
            gameOverAlert.addAction(UIAlertAction(title: "Back To Menu", style: .Default, handler: { (action: UIAlertAction!) in
                self.performSegueWithIdentifier("unwindToMenu", sender: nil)
            }))
            
            gameOverAlert.addAction(UIAlertAction(title: "Replay Quiz", style: .Default, handler: { (action: UIAlertAction!) in
                self.playQuiz()
            }))
            
            presentViewController(gameOverAlert, animated: true, completion: nil)
        }
        
    }
    
    func setQuestion(question: Question) {
       // nextQuestionTimer.invalidate()
        currentQuestion = question
        var options = question.getOptions()
        
        questionLabel.text = String(question.getNumber()) + "/" + String(qHandler.questionCount) + " " + question.getQuestion()
        
        aButton.setTitle("A). " + options["A"]!, forState: .Normal)
        bButton.setTitle("B). " + options["B"]!, forState: .Normal)
        cButton.setTitle("C). " + options["C"]!, forState: .Normal)
        dButton.setTitle("D). " + options["D"]!, forState: .Normal)
        
    }
    
    func playQuiz() {
        resetButtonColor()
        questionTimer = nil
        correctCount = 0
        self.navigationItem.rightBarButtonItem!.title = "Score: 0"
        
        submitted = false
        answered = false
        answerImage.hidden = true
        
        timerCount = 20
        timerLabel.text = String(timerCount)
        questionTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(SingleQuizViewController.checkTime), userInfo: nil, repeats: true)
        questionCount = 0
        setQuestion(qHandler.questionArray[0])
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            print("you shook the phone")
            randomAnswer()
        }
    }
    
    func randomAnswer() {
        submitted = true
        let randomAnswer = arc4random_uniform(4)
        
        switch randomAnswer {
        case 0:
            answer = "A"
            resetButtonColor()
            aButton.backgroundColor = selectedColor
            checkAnswer()
        case 1:
            answer = "B"
            resetButtonColor()
            bButton.backgroundColor = selectedColor
            checkAnswer()
        case 2:
            answer = "C"
            resetButtonColor()
            cButton.backgroundColor = selectedColor
            checkAnswer()
        case 3:
            answer = "D"
            resetButtonColor()
            dButton.backgroundColor = selectedColor
            checkAnswer()
        default:
            break
        }
    }
    
}
