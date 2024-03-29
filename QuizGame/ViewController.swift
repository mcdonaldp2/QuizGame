//
//  ViewController.swift
//  QuizGame
//
//  Created by Paul McDonald  on 4/20/16.
//  Copyright © 2016 Paul McDonald . All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate, UINavigationControllerDelegate,  NSURLConnectionDelegate {
    
    var handlerArray: [QuestionHandler]!
    var handler: QuestionHandler!
    var quizNumber: Int!
    var gameOverAlert: UIAlertController!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var singlePlayerButton: UIButton!
    @IBOutlet weak var multiplayerButton: UIButton!
    @IBOutlet weak var connectBarButton: UIBarButtonItem!
    
    var unselectedColor: UIColor!
    
    var session: MCSession!
    var peerID: MCPeerID!
    
    var browser: MCBrowserViewController!
    var assistant: MCAdvertiserAssistant!
    
    let serviceType = "g2-QuizGame"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        self.session = MCSession(peer: peerID)
        
        unselectedColor = singlePlayerButton.backgroundColor
        
        self.browser = MCBrowserViewController(serviceType: serviceType, session: session)
        assistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: self.session)
        
        assistant.start()
        
        
        session.delegate = self
        browser.delegate = self
        browser.maximumNumberOfPeers = 4

        
        quizNumber = 0
        handlerArray = []
        beginConnection()

    }
    
    override func viewDidAppear(animated: Bool) {
        //beginConnection()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func connect(sender: UIBarButtonItem) {
        presentViewController(self.browser, animated: true, completion: nil)
    }
    
    @IBAction func goToSinglePlayerQuiz(sender: UIButton) {
        multiplayerButton.backgroundColor = unselectedColor
        singlePlayerButton.backgroundColor = UIColor.greenColor()
        
        //performSegueWithIdentifier("singleQuizSegue", sender: self)
    }
    
    @IBAction func goToMultiplayerQuiz(sender: UIButton) {
        
        singlePlayerButton.backgroundColor = unselectedColor
        multiplayerButton.backgroundColor = UIColor.greenColor()
        
        
        //performSegueWithIdentifier("quizSegue", sender: self)
    }
    
    @IBAction func beginQuiz(sender: UIButton) {
        if (singlePlayerButton.backgroundColor == UIColor.greenColor()) {
            performSegueWithIdentifier("singleQuizSegue", sender: self)
        } else if (multiplayerButton.backgroundColor == UIColor.greenColor()) {
            
            print("go to multiplayer")
            if session.connectedPeers.count == 0 {
                gameOverAlert = UIAlertController(title: title, message: "You must be connected to other players to play multiplayer.", preferredStyle: UIAlertControllerStyle.Alert)
                
                gameOverAlert.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: { (action: UIAlertAction!) in
                    //self.endPeersQuiz()
                    
                }))
                
                
                
                presentViewController(gameOverAlert, animated: true, completion: nil)
            } else {
                let dataToSend = "goToMulti"
                
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
            
            performSegueWithIdentifier("quizSegue", sender: self)
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "quizSegue" {
            if let destination = segue.destinationViewController as? QuizViewController {
                destination.session = session as MCSession
                //destination.qHandler = handler as QuestionHandler
                destination.qHandlerArray = handlerArray as [QuestionHandler]
            }
            
        } else if segue.identifier == "singleQuizSegue" {
            if let destination = segue.destinationViewController as? SingleQuizViewController {
                //destination.qHandler = handler as QuestionHandler
                destination.qHandlerArray = handlerArray as [QuestionHandler]
            }
        }
    }
   
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
            
            //var msg = NSString(data: data, encoding: NSUTF16StringEncoding)
            //self.updateChatView(msg! as String, id: peerID)
            
            print("inside didReceiveData")
            
            if let receivedString =  NSKeyedUnarchiver.unarchiveObjectWithData(data) as? String{
                print(receivedString)
                if let topController = self.presentedViewController as? MCBrowserViewController {
                    print("topController: \(topController)")
                    
                    print("found controller")
                    self.dismissViewControllerAnimated(false, completion: nil)
                    
                    
                }
                
                self.performSegueWithIdentifier("quizSegue", sender: self)
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
    
    func beginConnection (){
        quizNumber = quizNumber + 1
        let url_string : String = "http://www.people.vcu.edu/~ebulut/jsonFiles/quiz" + String(quizNumber) + ".json"
        let url : NSURL = NSURL(string: url_string)!
        
        
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                //print("Everyone is fine, file downloaded successfully.")
                do{
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    //print(json)
                    self.convertJSON(json)
                    self.beginConnection()
                }catch {
                    print("something went wrong")
                }
            } else {
                print("done adding quizes!")
                print(self.handlerArray.count)
                
            }
        }
        
        task.resume()
    }
    
    func convertJSON(json: AnyObject){
        print(json)
        var questArray: [Question] = []
        
        let questionCount = json["numberOfQuestions"] as! Int
        let topic = json["topic"] as! String
        
        if let questions = json["questions"] as? [[String: AnyObject]] {
            
            for question in questions {
                
                let correctOption = question["correctOption"] as! String
                let questionNumber = question["number"] as! Int
                let options = question["options"] as! [String: String]
                let sentence = question["questionSentence"] as! String
                questArray.append(Question(number: questionNumber, questionSentence: sentence, options: options, correctOption: correctOption))
                
            }
            
            handler = QuestionHandler(array: questArray, questCount: questionCount, questTopic: topic)
            
        }
        handlerArray.append(handler)
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue){
        //self.session.disconnect()
    }
    
}

