//
//  QuizViewController.swift
//  QuizGame
//
//  Created by William Crump on 4/20/16.
//  Copyright © 2016 Paul McDonald . All rights reserved.
//

import UIKit
import MultipeerConnectivity
import CoreMotion

class QuizViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var aButton: UIButton!
    @IBOutlet weak var bButton: UIButton!
    @IBOutlet weak var cButton: UIButton!
    @IBOutlet weak var dButton: UIButton!
    
    @IBOutlet var playerImages: [UIImageView]!
    @IBOutlet var answerImages: [UIImageView]!
    @IBOutlet var scoreLabels: [UILabel]!
    
    var gameOverAlert: UIAlertController!
    
    var session: MCSession!
    var peerID: MCPeerID!
    
    var browser: MCBrowserViewController!
    var assistant: MCAdvertiserAssistant!
    
    let serviceType = "g2-QuizGame"
    
    var answersArray = [String]()
    var selectedAnswer = "N/A"
    var selectedButton = 0
    var origButtonColor: UIColor!
    
    //Handles players answer/scores
    var pManager = playerManager()
    var qHandler: QuestionHandler!
    var qHandlerArray: [QuestionHandler]!
    var quizCount: Int!
    
    var currentQuestion: Question!
    var questionTotal: Int!
    var questionNumber = 0
    var question: String!
    var correctAnswer: String!
    var options = [String : String]()
    
    var timerCount = 20
    var questionTimer: NSTimer!
    
    var youWereCorrect: Bool = false
    
    
    
    
    lazy var manager:CMMotionManager = {
        let motion = CMMotionManager()
        motion.accelerometerUpdateInterval = 0.2
        motion.gyroUpdateInterval = 0.2
        motion.deviceMotionUpdateInterval = 0.2
        return motion
    }()
    var initialized: Bool = false
    var initialAttitude: CMAttitude!
    var attitudeTimer: NSTimer!
    var rotZ: Double = 0.0
    var accelZ: Double = 0.0
    let selectedColor = UIColor.greenColor()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        quizCount = 0
        print("handler array count: \(qHandlerArray.count)")
        
        if (quizCount < qHandlerArray.count) {
            qHandler = qHandlerArray[quizCount]
        } else  {
            quizCount = 0
            qHandler = qHandlerArray[quizCount]
        }

        self.peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        //self.session = MCSession(peer: peerID)
        
        print("answerImages count: \(answerImages.count)")
        print("scoreLabels count: \(scoreLabels.count)")
        
        pManager.addPlayer(peerID.displayName)
        addConnectedPlayers()
        print("checking for totalPlayers")
        print("total players: \(pManager.players.count)")
        pManager.printPlayers()
        hideUI(pManager.players.count)
        
        self.browser = MCBrowserViewController(serviceType: serviceType, session: session)
//        assistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: self.session)
//        
//        assistant.start()
        
        questionTotal = qHandler.questionCount
        question = qHandler.questionArray[0].questionSentence
        correctAnswer = qHandler.questionArray[0].correctOption
        options = qHandler.questionArray[0].options
        
        setQuestion(qHandler.questionArray[questionNumber])
        
        
        session.delegate = self
        browser.delegate = self
        
        setUpMotion()
        
        aButton.tag = 1
        bButton.tag = 2
        cButton.tag = 3
        dButton.tag = 4
        origButtonColor = aButton.backgroundColor
        
        autoSizeButtonText(aButton)
        autoSizeButtonText(bButton)
        autoSizeButtonText(cButton)
        autoSizeButtonText(dButton)
        
        questionTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector:  #selector(QuizViewController.countDown), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendAnswer(sender: UIButton) {
        
        
        if sender.backgroundColor != UIColor.greenColor() {
            sender.backgroundColor = UIColor.greenColor()
            reverseButtonColor(selectedButton)
            selectedButton = sender.tag
            
        } else {
            sender.backgroundColor = UIColor.lightGrayColor()
            let a = sender.titleLabel!.text
            let letter = a?.substringToIndex((a?.startIndex.advancedBy(1))!)
            submitAnswer(letter!)

        }
        
        
    }
    
    func submitAnswer(letter: String) {
        //Determines what button is pressed
        
        print("Letter: \(letter)")
        print("Peers: \(session.connectedPeers.count)")
        selectedAnswer = letter
        
        //Presents players own answer
        var image: UIImage = UIImage(named: getAnswerImageName(selectedAnswer))!
        answerImages[0].image = image
        
        disableButtons()
        
        //updates current players answer after selection
        checkAnswer(letter)
        pManager.changePlayerAnswer(peerID.displayName, answer: letter)
        pManager.printPlayers()
        
        //dictionary that holds player values
        let dataToSend = ["playerId": peerID.displayName, "playerAnswer": letter, "playerScore": pManager.players[peerID.displayName]!.score]
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(dataToSend)
        
        do{
            //try session.sendData(msg!.dataUsingEncoding(NSUTF16StringEncoding)!, toPeers: session.connectedPeers, withMode: .Unreliable)
            try session.sendData(data, toPeers: session.connectedPeers, withMode: .Reliable)
            
            
        }
        catch let err
        {
            print("Error in sending data \(err)")
        }
        
        if (self.pManager.allPlayersAnswered() == true) {
            self.questionTimer.invalidate()
            self.timerCount == 20
            //self.updatePlayerAnswersUI()
            self.updateScoreLabels()
            
            if self.youWereCorrect == true {
                self.timerLabel.text = "Correct!"
            } else {
                self.timerLabel.text = "Wrong!"
            }
            
            _ = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector:  #selector(QuizViewController.nextQuestion), userInfo: nil, repeats: false)
        }

        
        
//        //Determines what button is pressed
//        let a = sender.titleLabel!.text
//        let letter = a?.substringToIndex((a?.startIndex.advancedBy(1))!)
//        print("Letter: \(letter!)")
//        print("Peers: \(session.connectedPeers.count)")
//        selectedAnswer = letter!
//        
//        //updates current players answer after selection
//        checkAnswer(letter!)
//        pManager.changePlayerAnswer(peerID.displayName, answer: letter!)
//        pManager.printPlayers()
//        
//        //dictionary that holds player values
//        let dataToSend = ["playerId": peerID.displayName, "playerAnswer": letter!, "playerScore": pManager.players[peerID.displayName]!.score]
//
//        let data = NSKeyedArchiver.archivedDataWithRootObject(dataToSend)
//        
//        do{
//            //try session.sendData(msg!.dataUsingEncoding(NSUTF16StringEncoding)!, toPeers: session.connectedPeers, withMode: .Unreliable)
//            try session.sendData(data, toPeers: session.connectedPeers, withMode: .Reliable)
//            
//            
//        }
//        catch let err
//        {
//            print("Error in sending data \(err)")
//        }

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func addConnectedPlayers() {
        for player in session.connectedPeers {
            pManager.addPlayer(player.displayName)
        }
    }
    
    func checkAnswer(playerAnswer: String) {
        if playerAnswer == correctAnswer {
            youWereCorrect = true
            pManager.incrementPlayerScore(peerID.displayName)
        } else {
            youWereCorrect = false
        }
    }
    
//    func updatePlayerAnswersUI() {
//        if (getAnswerImageName(selectedAnswer) != "something went wrong") {
//            var image: UIImage = UIImage(named: getAnswerImageName(selectedAnswer))!
//            answerImages[0].image = image
//            //answerImages[0].frame = CGRectMake(0,0,100,200)
//        }
//        
//        var count = 1
//        for (playerName, playerValues) in pManager.players {
//            if (playerName != peerID.displayName) && getAnswerImageName(playerValues.currentAnswer) != "something went wrong"{
//                var image: UIImage = UIImage(named: getAnswerImageName(playerValues.currentAnswer))!
//                answerImages[count].image = image
//                //answerImages[0].frame = CGRectMake(0,0,100,200)
//            }
//            count += 1
//        }
//    }
    
    func getAnswerImageName(answer: String) -> String {
        if (answer == "A") {
            return "aIcon"
        } else if (answer == "B") {
            return "bIcon"
        } else if (answer == "C") {
            return "cIcon"
        } else if (answer == "D") {
            return "dIcon"
        }
        
        return "something went wrong"
    }
    
    func updateScoreLabels() {
        //print("my score: \(pManager.players[peerID.displayName]!.score)")
        self.scoreLabels[0].text = String(pManager.players[peerID.displayName]!.score)
        var count = 1
        for (playerName, playerValues) in pManager.players {
            if (playerName != peerID.displayName) {
                //var image: UIImage = UIImage(named: getAnswerImageName(playerValues.currentAnswer!))!
                self.scoreLabels[count].text = String(playerValues.score)
                //answerImages[0].frame = CGRectMake(0,0,100,200)
                count += 1
            }
            
        }

    }
    
    func countDown() {
        timerCount -= 1
        
        timerLabel.text = "\(timerCount)"
        
        if timerCount == 0 {
            questionTimer.invalidate()
            timerCount == 20
            //updatePlayerAnswersUI()
            updateScoreLabels()
            
            if youWereCorrect == true {
                timerLabel.text = "Correct!"
            } else {
                timerLabel.text = "Wrong!"
            }
            
            _ = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector:  #selector(QuizViewController.nextQuestion), userInfo: nil, repeats: false)
        }
        
        
    }
    
    func nextQuestion() {
        questionNumber += 1
        enableButtons()
        
        if questionNumber < qHandler.questionCount {
            hideAnswers()
            pManager.resetCurrentAnswers()
            timerCount = 20
            timerLabel.text = String(timerCount)
            correctAnswer = qHandler.questionArray[questionNumber].correctOption
            setQuestion(qHandler.questionArray[questionNumber])
            reverseButtonColor(selectedButton)
            selectedButton = 0
            questionTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector:  #selector(QuizViewController.countDown), userInfo: nil, repeats: true)
        } else {
            print("game over")
            var title: String!
            var score1 = Int(pManager.players[peerID.displayName]!.score)
            var winner = pManager.getWinner()
            var youWon = false
            for index in winner {
                if index == peerID.displayName {
                    youWon = true
                }
            }
            
            if (winner.count > 1) {
                if youWon == true {
                    title = "You are one of the winners!"
                } else {
                    title = "You lose!"
                }
            } else {
                if youWon == true {
                    title = "You won!"
                } else {
                    title = "You lose!"
                }
            }
            
            gameOverAlert = UIAlertController(title: title, message: "You got \(score1)/\(qHandler.questionCount)", preferredStyle: UIAlertControllerStyle.Alert)
            
            gameOverAlert.addAction(UIAlertAction(title: "Back To Menu", style: .Default, handler: { (action: UIAlertAction!) in
                //self.endPeersQuiz()
                self.session.disconnect()
                self.performSegueWithIdentifier("unwindToMenu", sender: nil)
                
            }))
            
            gameOverAlert.addAction(UIAlertAction(title: "Replay Quiz", style: .Default, handler: { (action: UIAlertAction!) in
                self.restartPeersQuiz()
                self.resetScoreLabels()
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
        hideAnswers()
        pManager.resetPlayerValues()
        quizCount = quizCount + 1
        
        if (quizCount < qHandlerArray.count) {
            qHandler = qHandlerArray[quizCount]
        } else  {
            quizCount = 0
            qHandler = qHandlerArray[quizCount]
        }
        
        self.navigationItem.title = qHandler.topic
        reverseButtonColor(selectedButton)
        
        questionTimer = nil
        questionTotal = qHandler.questionCount
        question = qHandler.questionArray[0].questionSentence
        correctAnswer = qHandler.questionArray[0].correctOption
        options = qHandler.questionArray[0].options
        
        timerCount = 20
        timerLabel.text = String(timerCount)
        questionTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(QuizViewController.countDown), userInfo: nil, repeats: true)
        questionNumber = 0
        enableButtons()
        setQuestion(qHandler.questionArray[0])
        
    }

    
    func hideAnswers() {
        for image in answerImages {
            image.image = nil
        }
    }
    
    
    func reverseButtonColor(tag: Int) {
        if tag == 1 {
            aButton.backgroundColor = origButtonColor
        } else if tag == 2 {
            bButton.backgroundColor = origButtonColor
        } else if tag == 3 {
            cButton.backgroundColor = origButtonColor
        } else if tag == 4 {
            dButton.backgroundColor = origButtonColor
        } else {
            print("nothing needs to be changed")
        }
    }
    
    func hideUI(indexHide: Int) {
        var index = indexHide
        while index < 4 {
            playerImages[index].image = UIImage(named: "noPlayerIcon")
            scoreLabels[index].text = ""
            
            index += 1
        }
        
        
    }
    
    func resetScoreLabels() {
        for label in scoreLabels {
            label.text = "0"
        }
    }
    
    
    func restartPeersQuiz() {
        let dataToSend = "restart"
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(dataToSend)
        
        do{
            //try session.sendData(msg!.dataUsingEncoding(NSUTF16StringEncoding)!, toPeers: session.connectedPeers, withMode: .Unreliable)
            try session.sendData(data, toPeers: session.connectedPeers, withMode: .Reliable)
            
            
        }
        catch let err
        {
            print("Error in sending data \(err)")
        }

    }
    
    func endPeersQuiz() {
        let dataToSend = "end"
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(dataToSend)
        
        do{
            //try session.sendData(msg!.dataUsingEncoding(NSUTF16StringEncoding)!, toPeers: session.connectedPeers, withMode: .Unreliable)
            try session.sendData(data, toPeers: session.connectedPeers, withMode: .Reliable)
            
            
        }
        catch let err
        {
            print("Error in sending data \(err)")
        }

    }
    
    func disableButtons() {
        aButton.enabled = false
        bButton.enabled = false
        cButton.enabled = false
        dButton.enabled = false
        
    }
    
    func enableButtons() {
        aButton.enabled = true
        bButton.enabled = true
        cButton.enabled = true
        dButton.enabled = true
    }
    
    func autoSizeButtonText(button: UIButton) {
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.02
    }
    
    //*******************************************
    //*************MOTION METHODS****************
    //*******************************************
    
    func setUpMotion(){
        manager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!) { (accelerometerData: CMAccelerometerData?, NSError) -> Void in
            
            self.accelZ = (accelerometerData?.acceleration.z)!
            
        }
        
        manager.startGyroUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: { (gyroData: CMGyroData?, NSError) -> Void in
            
            
            self.rotZ = (gyroData?.rotationRate.z)!
            
            
            
        })
        manager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: { (data: CMDeviceMotion?, NSError) -> Void in
            
            if self.initialized == false {
                self.initialAttitude = data?.attitude
                self.initialized = true
                //self.attitudeTimer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: #selector(SingleQuizViewController.updateAttitude), userInfo: nil, repeats: true)
                print(self.initialAttitude.pitch)
            }
            
            self.handleMotion((data?.attitude)!)
            
            
        })
    }
    
    func updateAttitude(){
        initialAttitude = manager.deviceMotion?.attitude
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
            selectedAnswer = "A"
            
            reverseButtonColor(selectedButton)
            selectedButton = 1
            aButton.backgroundColor = selectedColor
        case 1:
            selectedAnswer  = "B"
            reverseButtonColor(selectedButton)
            selectedButton = 2
            bButton.backgroundColor = selectedColor
        case 2:
            selectedAnswer = "C"
            reverseButtonColor(selectedButton)
            selectedButton = 3
            cButton.backgroundColor = selectedColor
        case 3:
            selectedAnswer = "D"
            reverseButtonColor(selectedButton)
            selectedButton = 4
            dButton.backgroundColor = selectedColor
        default:
            break
        }
    }
    
    func handleMotion(attitude: CMAttitude){
        if aButton.enabled == true {
            
            let roll = attitude.roll
            let pitch = attitude.pitch
            // print(pitch)
            if (roll > initialAttitude.roll + 0.5) {
                moveRight()
            } else if (roll < initialAttitude.roll - 0.5) {
                moveLeft()
            } else if (pitch > initialAttitude.pitch + 0.5) {
                moveDown()
                //print("\(pitch) > \(initialAttitude.pitch + 0.5)")
            } else if (pitch < initialAttitude.pitch - 0.5) {
                moveUp()
                //print("\(pitch) < \(initialAttitude.pitch - 0.5)")
                
            }
            
            
            if (accelZ > 2 || accelZ < -2) || (rotZ > 3 || rotZ < -3) {
                switch selectedAnswer {
                case "A":
                    aButton.backgroundColor = UIColor.grayColor()
                    submitAnswer("A")
                    break
                case "B":
                    bButton.backgroundColor = UIColor.grayColor()
                    submitAnswer("B")
                    break
                case "C":
                    cButton.backgroundColor = UIColor.grayColor()
                    submitAnswer("C")
                    break
                case "D":
                    dButton.backgroundColor = UIColor.grayColor()
                    submitAnswer("D")
                    break
                default:
                    break
                }
            }
        }
    }
    
    func moveUp(){
        switch selectedAnswer  {
        case "A":
            break
        case "B":
            break
        case "C":
            selectedAnswer = "A"
            reverseButtonColor(selectedButton)
            selectedButton = 1
            aButton.backgroundColor = selectedColor
            
            break
        case "D":
            selectedAnswer = "B"
            reverseButtonColor(selectedButton)
            selectedButton = 2
            bButton.backgroundColor = selectedColor
            
        case "N/A":
            selectedAnswer = "A"
            reverseButtonColor(selectedButton)
            selectedButton = 1
            aButton.backgroundColor = selectedColor
            
            break
        default:
            break
        }
        
    }
    
    func moveDown(){
        switch selectedAnswer  {
        case "A":
            selectedAnswer = "C"
            reverseButtonColor(selectedButton)
            selectedButton = 3
            cButton.backgroundColor = selectedColor
            
            break
        case "B":
            selectedAnswer = "D"
            reverseButtonColor(selectedButton)
            selectedButton = 4
            dButton.backgroundColor = selectedColor
            
            break
        case "C":
            break
        case "D":
            break
        case "N/A":
            selectedAnswer = "A"
            reverseButtonColor(selectedButton)
            selectedButton = 1
            aButton.backgroundColor = selectedColor
            
            break
        default:
            break
        }
        
    }
    
    func moveLeft(){
        switch selectedAnswer  {
        case "A":
            break
        case "B":
            selectedAnswer = "A"
            reverseButtonColor(selectedButton)
            selectedButton = 1
            aButton.backgroundColor = selectedColor
            
            break
        case "C":
            break
        case "D":
            selectedAnswer = "C"
            reverseButtonColor(selectedButton)
            selectedButton = 3
            cButton.backgroundColor = selectedColor
            
            break
        case "N/A":
            selectedAnswer = "A"
            reverseButtonColor(selectedButton)
            selectedButton = 1
            
            break
        default:
            break
        }
        
    }
    
    func moveRight(){
        switch selectedAnswer  {
        case "A":
            selectedAnswer = "B"
            reverseButtonColor(selectedButton)
            selectedButton = 2
            bButton.backgroundColor = selectedColor
            
            break
        case "B":
            break
        case "C":
            selectedAnswer = "D"
            reverseButtonColor(selectedButton)
            selectedButton = 4
            dButton.backgroundColor = selectedColor
            
            break
        case "D":
            break
        case "N/A":
            selectedAnswer = "A"
            reverseButtonColor(selectedButton)
            selectedButton = 1
            aButton.backgroundColor = selectedColor
            
            break
        default:
            break
            
        }
        
    }

    
    
    
    
    //MARK - MCBrowserViewController functions
    
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        // Called when the browser view controller is dismissed
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
        // Called when the browser view controller is cancelled
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        // Called when a file has finished transferring from another peer
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        
        // Called when a peer sends an NSData to this device
        
        
        
        // this needs to be run on the main thread
        dispatch_async(dispatch_get_main_queue(),{
            
            print("inside didReceiveData")
            
            if let playerValues = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Dictionary<String, AnyObject> {
                //self.answersArray.append(letter)
                let playerId = playerValues["playerId"] as! String
                let playerAnswer = playerValues["playerAnswer"] as! String
                let playerScore = playerValues["playerScore"] as! Int
                
                //obeject that holds an answer/score
                let playerVal = playerManager.PlayerValues(answer: playerAnswer, score: playerScore)
                
                //updates playerAnswer/score in pManager
                self.pManager.updatePlayerInfo(playerId, playerValues: playerVal)
               
                print("\(playerId) \(playerAnswer) \(playerScore)")
                self.pManager.printPlayers()
                
                let index = self.pManager.findPlayerIndex(playerId)
                let image: UIImage = UIImage(named: self.getAnswerImageName(playerAnswer))!
                self.answerImages[index].image = image
                
                if (self.pManager.allPlayersAnswered() == true) {
                    self.questionTimer.invalidate()
                    self.timerCount == 20
                    //self.updatePlayerAnswersUI()
                    self.updateScoreLabels()
                    
                    if self.youWereCorrect == true {
                        self.timerLabel.text = "Correct!"
                    } else {
                        self.timerLabel.text = "Wrong!"
                    }
                    
                    _ = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector:  #selector(QuizViewController.nextQuestion), userInfo: nil, repeats: false)
                }
                
            } else {
                print("alertController click")
                if let str = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? String {
                    if str == "restart" {
                        print("in restart bock")
                        self.dismissViewControllerAnimated(false, completion: nil)
                        self.resetScoreLabels()
                        //self.restartPeersQuiz()
                        self.playQuiz()
                    } else {
                        print("in stop quiz block")
                        self.dismissViewControllerAnimated(false, completion: nil)
                        self.session.disconnect()
                        self.performSegueWithIdentifier("unwindToMenu", sender: nil)
                    }
                    
                }
            }
            
        })
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        // Called when a peer starts sending a file to this device
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Called when a peer establishes a stream with this device
    }
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        // Called when a connected peer changes state (for example, goes offline)
        
        switch state {
        case MCSessionState.Connected:
            print("Connected: \(peerID.displayName)")
            
        case MCSessionState.Connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.NotConnected:
            print("Not Connected: \(peerID.displayName)")
            self.session.disconnect()
            self.performSegueWithIdentifier("unwindToMenu", sender: self)
        }
        
        
    }


}
