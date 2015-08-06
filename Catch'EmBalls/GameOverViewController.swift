//
//  GameOverViewController.swift
//  Catch'EmBalls
//
//  Created by Sacha BECOURT on 4/16/15.
//  Copyright (c) 2015 CSUSM. All rights reserved.
//

import UIKit

class GameOverViewController: UIViewController {
    var scene:GameScene?
    @IBOutlet var finalScoreLabel: UILabel!
    var finalScore: Double = 0
    var isSoundAllowed: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        finalScoreLabel.text = "Your score : " + (NSString(format: "%0.f", finalScore) as String)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func continueButtonTouched(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.scene?.view?.paused = false
        println(isSoundAllowed)
        if (isSoundAllowed == true) {
            self.scene?.backgroundMusicPlayer?.play()
        }
        self.scene?.startGeneratingBallsEvery()
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
