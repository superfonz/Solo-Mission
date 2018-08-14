//
//  GameOverScene.swift
//  Solo Mission
//
//  Created by paula duarte on 7/3/18.
//  Copyright © 2018 Alfonzo Sanfilippo. All rights reserved.
//

import Foundation
import SpriteKit
class GameOverScene: SKScene{
    let restartLabel = SKLabelNode(fontNamed: "The Bold Font")

    override func didMove(to view: SKView) {
        let Background = SKSpriteNode(imageNamed: "background")
        Background.size = self.size
        Background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        Background.zPosition = 0
        self.addChild(Background)
        
        let GameOverLabel = SKLabelNode(fontNamed:"The Bold Font")
        GameOverLabel.text = "Game Over"
        GameOverLabel.fontSize = 200
        GameOverLabel.fontColor = SKColor.white
        GameOverLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.7)
        GameOverLabel.zPosition = 1
        self.addChild(GameOverLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
        scoreLabel.text = "Score: \(gameScore)"
        scoreLabel.fontSize = 125
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.55)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        let defaults = UserDefaults()
        var highScoreNumber = defaults.integer(forKey: "highScoreSaved")
        if gameScore > highScoreNumber{
            highScoreNumber = gameScore
            defaults.set(highScoreNumber, forKey: "highScoreSaved")
        }
        let highScoreLabel = SKLabelNode(fontNamed: "The Bold Font")
        highScoreLabel.text = "Highscore: \(highScoreNumber)"
        highScoreLabel.fontSize = 125
        highScoreLabel.fontColor = SKColor.white
        highScoreLabel.zPosition = 1
        highScoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.45)
        self.addChild(highScoreLabel)
        
        restartLabel.text = "Restart"
        restartLabel.fontSize = 90
        restartLabel.fontColor = SKColor.white
        restartLabel.zPosition = 1
        restartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.3)
        self.addChild(restartLabel)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            if restartLabel.contains(pointOfTouch){
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
                
            }
        }
    }
}
