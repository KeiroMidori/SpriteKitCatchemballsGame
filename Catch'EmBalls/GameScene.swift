//
//  GameScene.swift
//  Catch'EmBalls
//
//  Created by Sacha BECOURT on 4/15/15.
//  Copyright (c) 2015 CSUSM. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {
    let ballCategory: uint_least32_t = 0x1 << 0
    let obstacleCategory: uint_least32_t = 0x1 << 1
    @IBOutlet var comboLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var missedLabel: UILabel!
    @IBOutlet var speedLevelLabel: UILabel!
    @IBOutlet var pauseButton: UIButton!
    var unlimitedMisses: Bool = false
    var obstacles: Bool = true
    var viewController: UIViewController?
    var generationTimer: NSTimer?
    var ballGenerationSpeed: Float = 2
    var numberOfMissesAllowed: Int = 30
    var incrementValue: Int = 0
    var incrementValuesArray: Array<Int> = [15, 40, 75, 130, 180, 250, 350, 500, 650]
    var pikachuGravityValue: CGFloat = -16.0
    var normalBallGravityValue: CGFloat = -8.8
    var score : Double = 0
    var missed : Int = 0
    var speedLevel: Int = 1
    var comboMultiplier: Int = 1
    var comboCounter: Int = 0
    var type:BallType?
    var backgroundMusicPlayer: AVAudioPlayer?
    var isSoundAllowed: Bool = true
    
    func addLabelToGame(text: String, size: CGFloat, center : Bool, x: CGFloat, y: CGFloat, sound: String, color: UIColor) {

        var label:SKLabelNode = SKLabelNode()
        label.text = text
        label.fontName = "Pokemon Solid"
        label.fontColor = color
        label.fontSize = size
        
        if (center) {
            label.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        }
        else {
            label.position = CGPoint(x: x, y: y)
        }
        
        var y = label.position.y
        let moveUp = SKAction.moveByX(0, y: y + 200, duration: 2)
        let disappear = SKAction.fadeOutWithDuration(0.7)
        
        if (!sound.isEmpty) {
            let soundAction = SKAction.playSoundFileNamed(sound, waitForCompletion: true)
            label.runAction(SKAction.repeatAction(soundAction, count: 1))
        }
        
        label.runAction(SKAction.repeatAction(disappear, count: 1))
        label.runAction(SKAction.repeatAction(moveUp, count: 1))
        self.addChild(label)
        
    }
    
    func addObstacles(x: CGFloat, y: CGFloat, image: String, rotation: CGFloat) {
        var obstacle = SKSpriteNode(imageNamed: image)
        let obstacleAction = SKAction.repeatAction(SKAction.rotateByAngle(rotation, duration: 0), count: 1)
        obstacle.runAction(obstacleAction)
        obstacle.position = CGPoint(x: x, y: y)
        let physicalBody = SKPhysicsBody(rectangleOfSize: obstacle.size)
        physicalBody.contactTestBitMask = obstacleCategory
        physicalBody.usesPreciseCollisionDetection = true
        physicalBody.dynamic = false
        obstacle.physicsBody = physicalBody
        self.addChild(obstacle)
    }
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        if (isSoundAllowed) {
            self.backgroundMusicPlayer?.play()
        }
        var pauseAlphaScreen = SKSpriteNode(imageNamed: "back_screen")
        pauseAlphaScreen.size = self.size
        pauseAlphaScreen.alpha = 0.7
        pauseAlphaScreen.position = CGPointMake(self.size.width/2, self.size.height/2)
        pauseAlphaScreen.hidden = true
        pauseAlphaScreen.userInteractionEnabled = false
        pauseAlphaScreen.name = "pauseScreen"
        self.addChild(pauseAlphaScreen)

        var bgImage = SKSpriteNode(imageNamed: "pokemon_background")
        bgImage.alpha = 0.5
        bgImage.position = CGPointMake(self.size.width/2, self.size.height/2)
        self.addChild(bgImage)
        self.resetGame()
        self.scoreLabel.hidden = false
        self.missedLabel.hidden = false
        self.pauseButton.hidden = false
        self.speedLevelLabel.hidden = false
        
        if (obstacles) {
            self.addObstacles(self.frame.origin.x + 20, y: self.frame.size.height / 2, image: "blackline", rotation: 45)
            self.addObstacles(self.frame.size.width - 20, y: self.frame.size.height / 2, image: "blackline", rotation: -45)
        }
        if (unlimitedMisses) {
            self.missedLabel.text = "∞ tries"
        }

        self.addLabelToGame("GO !!", size: 120, center: true, x: 0, y: 0, sound: "", color: UIColor.blackColor())
        self.startGeneratingBallsEvery()
    }
    
    func resetGame() {
        generationTimer?.invalidate()
        generationTimer = nil
        ballGenerationSpeed = 2
        incrementValue = 0
        score = 0
        missed = 0
        speedLevel = 1
        comboMultiplier = 1
        comboCounter = 0
        comboLabel.text = "Combo : x1"
        speedLevelLabel.text = "Level : 1"
        scoreLabel.text = "Score : 0"
        missedLabel.text = "Missed : 0"
    }
    
    func missedAction() {
        missed += 1
        comboMultiplier = 1
        comboCounter = 0
        self.comboLabel.text = "Combo : x1"
        if (!self.unlimitedMisses) {
            if (missed == numberOfMissesAllowed) {
                self.view?.paused = true
                self.backgroundMusicPlayer?.stop()
                viewController = self.view?.window?.rootViewController
                viewController?.performSegueWithIdentifier("gameover", sender: self)
                self.resetGame()
            }
        }
    }
    
    func updateCombo(x: CGFloat, y: CGFloat) {
        comboCounter++
        if (comboCounter == 3 || comboCounter == 5 || comboCounter == 10 || comboCounter == 15) {
            switch comboCounter {
            case 3:
                comboMultiplier = 10
                break
            case 5:
                comboMultiplier = 20
                break
            case 10:
                comboMultiplier = 50
                break
            case 15:
                comboMultiplier = 100
                break
            default:
                comboMultiplier = 1
            }
            self.addLabelToGame("x" + (NSString(format: "%d", comboMultiplier) as String) as String, size: 60, center: false, x: x, y: y+30, sound: "item_get.wav", color: UIColor.yellowColor())
            self.comboLabel.text = "Combo : x" + (NSString(format: "%d", comboMultiplier) as String)
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        let touch:UITouch = touches.first as! UITouch
        let positionInScene = touch.locationInNode(self)
        let touchedNode = self.nodeAtPoint(positionInScene)
        
        println(touchedNode.name)
        
        if let name = touchedNode.name
        {
            switch name {
            case "PokeBall":
                score += Double(10 * comboMultiplier)
                break
            case "SafariBall":
                score += Double(12 * comboMultiplier)
                break
            case "DuskBall":
                score += Double(16 * comboMultiplier)
                break
            case "DiveBall":
                score += Double(25 * comboMultiplier)
                break
            case "QuickBall":
                score += Double(50 * comboMultiplier)
                break
            case "HealBall":
                score += Double(60 * comboMultiplier)
                break
            case "LuxBall":
                score += Double(100 * comboMultiplier)
                break
            case "PremierBall":
                score += Double(150 * comboMultiplier)
                break
            case "MasterBall":
                score += Double(300 * comboMultiplier)
                break
            case "Pikachu":
                self.updateCombo(positionInScene.x, y: positionInScene.y)
                score += Double(1000 * comboMultiplier)
                self.addLabelToGame("Pikachu !!", size: 36, center: false, x: positionInScene.x, y: positionInScene.y, sound: "pikachu_sound.wav", color: UIColor.yellowColor())
                break
            default:
                break
            }
            if (name != "Pikachu" && name != "pauseScreen") {
                self.updateCombo(positionInScene.x, y: positionInScene.y)
                println(score)
                self.addLabelToGame("Good !", size: 36, center: false, x: positionInScene.x, y: positionInScene.y, sound: "coin_sound.wav", color: UIColor.greenColor())
            }
            else if (name == "pauseScreen") {
                self.missedAction()
                self.addLabelToGame("Missed !", size: 36, center: false, x: positionInScene.x, y: positionInScene.y, sound: "", color: UIColor.redColor())
            }
        }
        else {
            self.missedAction()
            self.addLabelToGame("Missed !", size: 36, center: false, x: positionInScene.x, y: positionInScene.y, sound: "", color: UIColor.redColor())
        }
        self.scoreLabel.text = "Score : " + (NSString(format: "%0.f", score) as String)
        if (!unlimitedMisses) {
            self.missedLabel.text = "Missed : " + (NSString(format: "%d", missed) as String)
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    
    func startGeneratingBallsEvery() {
        generationTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(ballGenerationSpeed), target: self, selector: "makeItRain", userInfo: nil, repeats: true)
    }
    
    func makeItRain() {
        let location = CGPoint(x: CGFloat(arc4random()) % self.frame.width, y: self.frame.height)
        
        let aBall:Ball = Ball(ballType: BallType.random())
        
        let ball = SKSpriteNode(imageNamed: aBall.ballType.spriteName)
        ball.name = aBall.ballType.spriteName
        if (ball.name == "Pikachu") {
            ball.xScale = 2.5
            ball.yScale = 2.5
            self.physicsWorld.gravity = CGVectorMake(0.0, pikachuGravityValue);
        }
        else {
            ball.xScale = 1.3
            ball.yScale = 1.3
            self.physicsWorld.gravity = CGVectorMake(0.0, normalBallGravityValue);
        }
        
        ball.position = location
        let physicalBody = SKPhysicsBody(rectangleOfSize: ball.size)
        physicalBody.dynamic = true
        physicalBody.mass = 0.7
        physicalBody.contactTestBitMask = ballCategory
        physicalBody.usesPreciseCollisionDetection = true
        
        ball.physicsBody = physicalBody
        self.addChild(ball)
        if (contains(incrementValuesArray, incrementValue)) {
            speedLevel++
            speedLevelLabel.text = "Level : " + (NSString(format: "%d", speedLevel) as String)
            ballGenerationSpeed = ballGenerationSpeed / 1.3
            generationTimer?.invalidate()
            generationTimer = nil
            startGeneratingBallsEvery()
            self.addLabelToGame("! Speed Up !", size: 100, center: true, x: 0, y: 0, sound: "", color: UIColor.blackColor())
        }
        incrementValue++
        println(incrementValue)
    }
    
}
