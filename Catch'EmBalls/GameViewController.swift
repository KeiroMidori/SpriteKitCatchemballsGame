//
//  GameViewController.swift
//  Catch'EmBalls
//
//  Created by Sacha BECOURT on 4/15/15.
//  Copyright (c) 2015 CSUSM. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

extension SKNode {
    class func unarchiveFromFile(file : String) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController, SKSceneDelegate {

    @IBOutlet var comboLabel: UILabel!
    @IBOutlet var backToTitleButton: UIButton!
    @IBOutlet var soundButton: UIButton!
    @IBOutlet var helpButton: UIButton!
    @IBOutlet var obstacleLabel: UILabel!
    @IBOutlet var unlimitedLabel: UILabel!
    @IBOutlet var obstaclesSwitch: UISwitch!
    @IBOutlet var unlimitedMissesSwitch: UISwitch!
    @IBOutlet var speedLevelLabel: UILabel!
    @IBOutlet var gameTitle: UILabel!
    @IBOutlet var titleImage: UIImageView!
    @IBOutlet var pauseButton: UIButton!
    @IBOutlet var missedLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var startButton: UIButton!
    var isSoundAllowed: Bool = true
    var scene:GameScene?
    var backgroundMusicPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scoreLabel.hidden = true
        self.missedLabel.hidden = true
        self.pauseButton.titleLabel?.text = "Pause"
        self.pauseButton.hidden = true
        self.speedLevelLabel.hidden = true
        self.soundButton.hidden = false
        self.backToTitleButton.hidden = true
        self.comboLabel.hidden = true
        self.playBackgroundMusic("pokecenter")
        self.soundButton.setImage(UIImage(named: "sound"), forState: UIControlState.Normal)
    }

    func backToTitle() {
        self.scene?.removeFromParent()
//        self.scene?.view?.presentScene(nil)
        self.scoreLabel.hidden = true
        self.missedLabel.hidden = true
        self.pauseButton.hidden = true
        self.speedLevelLabel.hidden = true
        self.soundButton.hidden = false
        self.backToTitleButton.hidden = true
        self.comboLabel.hidden = true
        titleImage.hidden = false
        gameTitle.hidden = false
        unlimitedLabel.hidden = false
        obstacleLabel.hidden = false
        unlimitedMissesSwitch.hidden = false
        obstaclesSwitch.hidden = false
        helpButton.hidden = false
        startButton.hidden = false
        self.scene?.generationTimer?.invalidate()
    }
    
    @IBAction func backToTitleButtonTouched(sender: AnyObject) {
        self.backToTitle()
    }
    
    @IBAction func startButtonTouched(sender: AnyObject) {
        if (self.scene?.view?.paused == true) {
            self.scene?.view?.paused = false
            self.pauseButton.titleLabel?.text = "Pause"
        }
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            self.scene = scene
            self.scene?.delegate = self
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = false
            skView.showsNodeCount = false
            titleImage.hidden = true
            gameTitle.hidden = true
            unlimitedLabel.hidden = true
            obstacleLabel.hidden = true
            unlimitedMissesSwitch.hidden = true
            obstaclesSwitch.hidden = true
            helpButton.hidden = true
            scene.isSoundAllowed = self.isSoundAllowed
            self.soundButton.hidden = true
            self.comboLabel.hidden = false
            
            scene.scoreLabel = self.scoreLabel
            scene.missedLabel = self.missedLabel
            scene.pauseButton = self.pauseButton
            scene.speedLevelLabel = self.speedLevelLabel
            scene.unlimitedMisses = self.unlimitedMissesSwitch.on
            scene.obstacles = self.obstaclesSwitch.on
            scene.backgroundMusicPlayer = self.backgroundMusicPlayer
            scene.comboLabel = self.comboLabel
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill 
            
            startButton.hidden = true
            skView.presentScene(self.scene)
        }
    }
    override func shouldAutorotate() -> Bool {
        return true
    }

    @IBAction func soundButtonTouched(sender: AnyObject) {
        if (isSoundAllowed) {
            self.soundButton.setImage(UIImage(named: "mute"), forState: UIControlState.Normal)
            self.isSoundAllowed = false
            self.backgroundMusicPlayer.stop()
        }
        else {
            self.soundButton.setImage(UIImage(named: "sound"), forState: UIControlState.Normal)
            self.isSoundAllowed = true
        }
    }
    
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "gameover") {
            self.dismissViewControllerAnimated(false, completion: nil)
            let viewController:GameOverViewController = segue.destinationViewController as! GameOverViewController
            viewController.finalScore = scene!.score as Double
            viewController.scene = scene
            viewController.isSoundAllowed = self.isSoundAllowed
            // pass data to next view
        }
    }
    
    func playBackgroundMusic(filename: String) {
        var alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(filename, ofType: "mp3")!)
        println(alertSound)
        
        // Removed deprecated use of AVAudioSessionDelegate protocol
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        
        var error:NSError?
        backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: alertSound, error: &error)
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.volume = 0.2
        backgroundMusicPlayer.numberOfLoops = -1;
    }

    
    @IBAction func pauseButtonTouched(sender: AnyObject) {
        if ((self.scene?.view?.paused) == true) {
            self.scene?.childNodeWithName("pauseScreen")?.zPosition = -1
            self.scene?.childNodeWithName("pauseScreen")?.hidden = true
            self.backToTitleButton.hidden = true
            self.scene?.view?.paused = false
            self.scene?.startGeneratingBallsEvery()
            self.pauseButton.setTitle("Pause", forState: UIControlState.Normal)
        }
        else {
            self.scene?.childNodeWithName("pauseScreen")?.hidden = false
            self.scene?.childNodeWithName("pauseScreen")?.zPosition = 4
            
            self.backToTitleButton.hidden = false
            self.scene?.view?.paused = true
            self.scene?.generationTimer?.invalidate()
            self.pauseButton.setTitle("Resume", forState: UIControlState.Normal)
        }
        
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}
