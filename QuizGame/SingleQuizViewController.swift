//
//  SingleQuizViewController.swift
//  QuizGame
//
//  Created by Paul McDonald  on 4/24/16.
//  Copyright © 2016 Paul McDonald . All rights reserved.
//

import UIKit

class SingleQuizViewController: UIViewController {

    var qHandler: QuestionHandler!
    
    var questionTimer: NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //questionTimer = NSTimer.scheduledTimerWithTimeInterval(20, target: <#T##AnyObject#>, selector: <#T##Selector#>, userInfo: <#T##AnyObject?#>, repeats: <#T##Bool#>)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
