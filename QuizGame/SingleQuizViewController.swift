//
//  SingleQuizViewController.swift
//  QuizGame
//
//  Created by Paul McDonald  on 4/24/16.
//  Copyright © 2016 Paul McDonald . All rights reserved.
//

import UIKit
import CoreMotion

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
    
    var quizCount: Int!
    var qHandlerArray: [QuestionHandler]!
    var qHandler: QuestionHandler!
    var currentQuestion: Question!
    var questionCount: Int!
    
    var nextQuestionTimer: NSTimer!
    var questionTimer: NSTimer!
    var timerCount: Int!
    
    var answer: String!
    var answered: Bool!
    var correctCount: Int!
    var submitted: Bool!
    
    lazy var manager:CMMotionManager = {
        let motion = CMMotionManager()
        motion.accelerometerUpdateInterval = 0.2
        motion.gyroUpdateInterval = 0.2
        return motion
    }()
    
    var rotX: Double = 0.0
    var rotY: Double = 0.0
    var rotZ: Double = 0.0
    
    var accelX: Double = 0.0
    var accelY: Double = 0.0
    var accelZ: Double = 0.0
    
    var gameOverAlert: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        buttonColor = dButton.backgroundColor
        selectedColor = UIColor.greenColor()
        
        autoSizeButtonText(aButton)
        autoSizeButtonText(bButton)
        autoSizeButtonText(cButton)
        autoSizeButtonText(dButton)
        
        setUpMotion()
        
        quizCount = -1
        playQuiz()
    }
    
    func playQuiz() {
        
        quizCount = quizCount + 1
        
        if (quizCount < qHandlerArray.count) {
        qHandler = qHandlerArray[quizCount]
        } else  {
            quizCount = 0
            qHandler = qHandlerArray[quizCount]
        }
        
        self.navigationItem.title = qHandler.topic
        resetButtonColor()
        questionTimer = nil
        correctCount = 0
        answer = "Z"
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
           // nextQuestionTimer.invalidate()
            
            gameOverAlert = UIAlertController(title: "Quiz Over!", message: "You got " + String(correctCount) + " out of " + String(qHandler.questionCount) + " correct. ", preferredStyle: UIAlertControllerStyle.Alert)
            
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
    
    
    //*******************************************
    //*************MOTION METHODS****************
    //*******************************************
    
    func setUpMotion(){
        manager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!) { (accelerometerData: CMAccelerometerData?, NSError) -> Void in
            
            self.accelX = (accelerometerData?.acceleration.x)!
            self.accelY = (accelerometerData?.acceleration.y)!
            self.accelZ = (accelerometerData?.acceleration.z)!
            
        }
        manager.startGyroUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: { (gyroData: CMGyroData?, NSError) -> Void in
            
            self.rotX = (gyroData?.rotationRate.x)!
            self.rotY = (gyroData?.rotationRate.y)!
            self.rotZ = (gyroData?.rotationRate.z)!
            
            self.handleMotion()
            
            
        })
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            print("you shook the phone")
            randomAnswer()
        }
    }
    
    func randomAnswer() {
        //submitted = false
        let randomAnswer = arc4random_uniform(4)
        
        switch randomAnswer {
        case 0:
            answer = "A"
            answered = true
            resetButtonColor()
            aButton.backgroundColor = selectedColor
        case 1:
            answer = "B"
            answered = true
            resetButtonColor()
            bButton.backgroundColor = selectedColor
        case 2:
            answer = "C"
            answered = true
            resetButtonColor()
            cButton.backgroundColor = selectedColor
        case 3:
            answer = "D"
            answered = true
            resetButtonColor()
            dButton.backgroundColor = selectedColor
        default:
            break
        }
    }
    
    func handleMotion(){
        if submitted != true {
            
            if (rotX > 4) {
                moveDown()
            } else if (rotX < -4) {
                moveUp()
            }else if (rotY > 4) {
                moveRight()
            }else if (rotY < -4) {
                moveLeft()
            } else if (rotZ > 4) {
                moveLeft()
            } else if (rotZ < -4) {
                moveRight()
            }
            
            if (accelZ > 2 || accelZ < -2) {
                switch answer {
                case "A":
                    aButton.backgroundColor = UIColor.grayColor()
                    submitted = true
                    checkAnswer()
                    break
                case "B":
                    bButton.backgroundColor = UIColor.grayColor()
                    submitted = true
                    checkAnswer()
                    break
                case "C":
                    cButton.backgroundColor = UIColor.grayColor()
                    submitted = true
                    checkAnswer()
                    break
                case "D":
                    dButton.backgroundColor = UIColor.grayColor()
                    submitted = true
                    checkAnswer()
                    break
                default:
                    break
                }
            }
        }
    }
    
    func moveUp(){
        switch answer  {
        case "A":
            break
        case "B":
            break
        case "C":
            answer = "A"
            answerImage.image = UIImage(named: "aIcon")
            resetButtonColor()
            aButton.backgroundColor = selectedColor
            answered = true
            break
        case "D":
            answer = "B"
            answerImage.image = UIImage(named: "bIcon")
            resetButtonColor()
            bButton.backgroundColor = selectedColor
            answered = true
        default:
            answer = "A"
            answerImage.image = UIImage(named: "aIcon")
            aButton.backgroundColor = selectedColor
            answered = true
            break
        }
        answerImage.hidden = false
    }
    
    func moveDown(){
        switch answer  {
        case "A":
            answer = "C"
            answerImage.image = UIImage(named: "cIcon")
            resetButtonColor()
            cButton.backgroundColor = selectedColor
            answered = true
            break
        case "B":
            answer = "D"
            answerImage.image = UIImage(named: "dIcon")
            resetButtonColor()
            dButton.backgroundColor = selectedColor
            answered = true
            break
        case "C":
            break
        case "D":
            break
        default:
            answer = "A"
            answerImage.image = UIImage(named: "aIcon")
            aButton.backgroundColor = selectedColor
            answered = true
            break
            
        }
        answerImage.hidden = false
    }
    
    func moveLeft(){
        switch answer  {
        case "A":
            break
        case "B":
            answer = "A"
            answerImage.image = UIImage(named: "aIcon")
            resetButtonColor()
            aButton.backgroundColor = selectedColor
            answered = true
            break
        case "C":
            break
        case "D":
            answer = "C"
            answerImage.image = UIImage(named: "cIcon")
            resetButtonColor()
            cButton.backgroundColor = selectedColor
            answered = true
            break
        default:
            answer = "A"
            answerImage.image = UIImage(named: "aIcon")
            aButton.backgroundColor = selectedColor
            answered = true
            break
        }
        answerImage.hidden = false
    }
    
    func moveRight(){
        switch answer  {
        case "A":
            answer = "B"
            answerImage.image = UIImage(named: "bIcon")
            resetButtonColor()
            bButton.backgroundColor = selectedColor
            answered = true
            break
        case "B":
            break
        case "C":
            answer = "D"
            answerImage.image = UIImage(named: "dIcon")
            resetButtonColor()
            dButton.backgroundColor = selectedColor
            answered = true
            break
        case "D":
            break
        default:
            answer = "A"
            answerImage.image = UIImage(named: "aIcon")
            aButton.backgroundColor = selectedColor
            answered = true
            break
            
        }
        answerImage.hidden = false
    }


    
}
