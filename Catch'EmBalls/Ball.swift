//
//  Ball.swift
//  Catch'EmBalls
//
//  Created by Sacha BECOURT on 4/15/15.
//  Copyright (c) 2015 CSUSM. All rights reserved.
//

import SpriteKit

class Ball: Printable {
    let ballType: BallType
    var sprite: SKSpriteNode?
    
    init(ballType: BallType) {
        self.ballType = ballType
    }
    
    var description: String {
        return "type:\(ballType)"
    }
}

enum BallType: Int, Printable {
    case Unknown = 0, PokeBall, SafariBall, DuskBall, DiveBall, QuickBall, HealBall, LuxBall, PremierBall, MasterBall, Pikachu
    
    var spriteName: String {
        let spriteNames = [
            "PokeBall",
            "SafariBall",
            "DuskBall",
            "DiveBall",
            "QuickBall",
            "HealBall",
            "LuxBall",
            "PremierBall",
            "MasterBall",
            "Pikachu"]
        return spriteNames[rawValue - 1]
    }
    
    var highlightedSpriteName: String {
        return spriteName + "-Highlighted"
    }
    
    static func random() -> BallType {
        return BallType(rawValue: Int(arc4random_uniform(10)) + 1)!
    }
    
    var description: String {
        return spriteName
    }
}
