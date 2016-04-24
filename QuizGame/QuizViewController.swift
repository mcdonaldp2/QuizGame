//
//  QuizViewController.swift
//  QuizGame
//
//  Created by William Crump on 4/20/16.
//  Copyright © 2016 Paul McDonald . All rights reserved.
//

import UIKit
import MultipeerConnectivity

class QuizViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var aButton: UIButton!
    @IBOutlet weak var bButton: UIButton!
    @IBOutlet weak var cButton: UIButton!
    @IBOutlet weak var dButton: UIButton!
    
    @IBOutlet var answerImages: [UIImageView]!
    @IBOutlet var scoreLabels: [UILabel]!
    
    var session: MCSession!
    var peerID: MCPeerID!
    
    var browser: MCBrowserViewController!
    var assistant: MCAdvertiserAssistant!
    
    let serviceType = "g2-QuizGame"
    
    var answersArray = [String]()
    var selectedAnswer: String?
    
    //Handles players answer/scores
    var pManager = playerManager()
    var qHandler: QuestionHandler!
    
    var questionTotal: Int!
    var questionNumber = 1
    var question: String!
    var correctAnswer: String!
    var options = [String : String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        //self.session = MCSession(peer: peerID)
        
        pManager.addPlayer(peerID.displayName)
        addConnectedPlayers()
        print("checking for totalPlayers")
        pManager.printPlayers()
        
        self.browser = MCBrowserViewController(serviceType: serviceType, session: session)
//        assistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: self.session)
//        
//        assistant.start()
        
        questionTotal = qHandler.questionCount
        question = qHandler.questionArray[0].questionSentence
        correctAnswer = qHandler.questionArray[0].correctOption
        options = qHandler.questionArray[0].options
        
        
        session.delegate = self
        browser.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendAnswer(sender: UIButton) {
        
        //Determines what button is pressed
        let a = sender.titleLabel!.text
        let letter = a?.substringToIndex((a?.startIndex.advancedBy(1))!)
        print("Letter: \(letter!)")
        print("Peers: \(session.connectedPeers.count)")
        //selectedAnswer = letter!
        
        //updates current players answer after selection
        checkAnswer(letter!)
        pManager.changePlayerAnswer(peerID.displayName, answer: letter!)
        pManager.printPlayers()
        
        //dictionary that holds player values
        let dataToSend = ["playerId": peerID.displayName, "playerAnswer": letter!, "playerScore": pManager.players[peerID.displayName]!.score]

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
            pManager.incrementPlayerScore(peerID.displayName)
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
        }
        
        
    }


}
