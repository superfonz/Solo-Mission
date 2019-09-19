//
//  GameScene.swift
//  Solo Mission
//
//  Created by Alfonzo Sanfilippo on 7/2/18.
//  Copyright © 2018 Alfonzo Sanfilippo. All rights reserved.
//

import SpriteKit
import GameplayKit
var gameScore = 0
class GameScene: SKScene, SKPhysicsContactDelegate {
    let Player = SKSpriteNode(imageNamed: "playerShip")
    let bulletsound = SKAction.playSoundFileNamed("Bulletsound.mp3", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("ExplosionSound.mp3", waitForCompletion: false)
    let tapToStartLabel = SKLabelNode(fontNamed: "The Bold Font")
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    var livesNumber = 3
    let livesLabel = SKLabelNode(fontNamed: "The Bold Font")
    var gameArea: CGRect
    var levelNumber = 0
    enum GameState{
        case preGame //before
        case inGame //during
        case afterGame //after the Game
    }
    var currentGameState = GameState.preGame
    struct PhysicsCategories {
        static let None: UInt32 = 0
        static let Player : UInt32 = 0b1 //binary 1
        static let Bullet : UInt32 = 0b10
        static let Enemy : UInt32 = 0b100
    }
    func random() -> CGFloat{
        return CGFloat(Float(arc4random())/0xFFFFFFFF)
    }
    func random(min: CGFloat, max: CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }
    
    override init(size: CGSize){
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth)/2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        gameScore = 0
        self.physicsWorld.contactDelegate = self
        
        for i in 0...1{
            let Background = SKSpriteNode(imageNamed: "background")
            Background.size = self.size
            Background.anchorPoint = CGPoint(x: 0.5, y: 0)
            Background.position = CGPoint(x: self.size.width/2, y: self.size.height * CGFloat(i))
            Background.zPosition = 0
            Background.name = "background"
            self.addChild(Background)
        }
        
        Player.setScale(3)
        Player.position = CGPoint(x: self.size.width/2, y: 0 - Player.size.height)
        Player.zPosition = 2
        Player.physicsBody = SKPhysicsBody(rectangleOf: Player.size)
        Player.physicsBody!.affectedByGravity = false
        Player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        Player.physicsBody!.collisionBitMask = PhysicsCategories.None
        Player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(Player)
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width * 0.15, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        livesLabel.text = "Lives: 3"
        livesLabel.fontSize = 70
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width * 0.85, y: self.size.height + livesLabel.frame.size.height)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        let moveOnToScreenAction = SKAction.moveTo(y: self.size.height * 0.95, duration: 0.3)
        scoreLabel.run(moveOnToScreenAction)
        livesLabel.run(moveOnToScreenAction)
        
        tapToStartLabel.text = " Tap to Begin"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.zPosition = 1
        tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
        
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        tapToStartLabel.run(fadeInAction)
        
    }
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    var amountToMovePerSecond: CGFloat = 600.0
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        else {
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        let amountToMoveBackground = amountToMovePerSecond * CGFloat(deltaFrameTime)
        self.enumerateChildNodes(withName: "background"){
            background, stop in
            if self.currentGameState == GameState.inGame{
            background.position.y -= amountToMoveBackground
            }
            if background.position.y < -self.size.height {
                background.position.y += self.size.height * 2
            }
        }
    }
    func startNewLevel(){
        levelNumber += 1
        if self.action(forKey: "spawningEnemies") != nil{
            self.removeAction(forKey: "spawningEnemies")
        }
        var levelDuration = TimeInterval()
            switch levelNumber{
            case 1: levelDuration = 1.2
            case 2: levelDuration = 1
            case 3: levelDuration = 0.8
            case 4: levelDuration = 0.5
            default:
                levelDuration = 0.5
                print("cannot find level info")
        }
        
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
    }
    func FireBullet(){
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "Bullet"
        bullet.setScale(1)
        bullet.position = Player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bullet)
        let movebullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deletebullet = SKAction.removeFromParent()
        let bulletsequence = SKAction.sequence([bulletsound, movebullet, deletebullet])
        bullet.run(bulletsequence)
    }
    func spawnEnemy(){
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        let randomXstart = random(min: gameArea.minX + enemy.size.width/2, max: gameArea.maxX - enemy.size.width/2)
        let randomXend = random(min: gameArea.minX + enemy.size.width/2, max: gameArea.maxX - enemy.size.width/2)
        let startPoint = CGPoint(x: randomXstart, y:self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXend, y: -self.size.height * 0.2)
        enemy.name = "Enemy"
        enemy.setScale(2.5)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        let loseAlifeAction = SKAction.run(LoseAlife)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseAlifeAction])
        if currentGameState == GameState.inGame{
        enemy.run(enemySequence)
        }
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
    }
    func didBegin(_ contact: SKPhysicsContact) {
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
        else{
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy{
            if body1.node != nil{
                spawnExplosion(spawnPosition: body1.node!.position)
            }
            if body2.node != nil{
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            runGameOver()
        }
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy && (body2.node?.position.y)! < self.size.height{
            addScore()
            if body2.node != nil{
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
    }
    func spawnExplosion(spawnPosition: CGPoint){
        let explosion = SKSpriteNode(imageNamed: "explosition")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let scaleOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        let explosionSequence = SKAction.sequence([explosionSound, scaleIn, scaleOut, delete])
        explosion.run(explosionSequence)
    }
    func addScore(){
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        if gameScore == 10 || gameScore == 25 || gameScore == 50{
            startNewLevel()
        }
    }
    func LoseAlife(){
        livesNumber -= 1
        livesLabel.text = "Lives: \(livesNumber)"
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp,scaleDown])
        livesLabel.run(scaleSequence)
        if livesNumber == 0{
            runGameOver()
        }
    }
    func runGameOver(){
        currentGameState = GameState.afterGame
        
        self.removeAllActions()
        self.enumerateChildNodes(withName: "Bullet"){
            bullet, stop in
            bullet.removeAllActions()
        }
        self.enumerateChildNodes(withName: "Enemy"){
            enemy, stop in
            enemy.removeAllActions()
        }
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
    }
    func changeScene(){
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
        
    }
    func startGame(){
        currentGameState = GameState.inGame
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToStartLabel.run(deleteSequence)
        
        let moveShipOntoScreenAction = SKAction.moveTo(y: self.size.height * 0.2, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameAction = SKAction.sequence([moveShipOntoScreenAction, startLevelAction])
        Player.run(startGameAction)
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentGameState == GameState.preGame {
            startGame()
        }
        else if currentGameState == GameState.inGame{
        FireBullet()
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointofTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            let amountDragged = pointofTouch.x - previousPointOfTouch.x
            if currentGameState == GameState.inGame{
            Player.position.x += amountDragged
            }
            if Player.position.x > gameArea.maxX - Player.size.width/2{
                Player.position.x = gameArea.maxX - Player.size.width/2
            }
            if Player.position.x < gameArea.minX + Player.size.width/2{
                Player.position.x = gameArea.minX + Player.size.width/2
            }
        }
    }
    
}
