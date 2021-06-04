//
//  GameOverScene.swift
//  Interstellar Raider
//
//  Created by Josh Manik on 02/06/2021.
//

import Foundation
import SpriteKit
import GameKit


class GameOverScene: SKScene{
    
    // Different Variables we need to use on the scene
    
    var NewHighScore = Bool()
    var enemy : SKSpriteNode!
    
    // The different sprite nodes
    
    let restartLabel = SKLabelNode(fontNamed: "ADAM.CGPRO")
    let homelabel = SKLabelNode(fontNamed: "ADAM.CGPRO")
    let background = SKSpriteNode(imageNamed: "glitter-universe-1-1")

    // The various different textures needed for animation
    
    var BackgroundTextureAtlas = SKTextureAtlas()
    var BackgroundTextureArray: [SKTexture] = []
    
    var EnemyTextureAtlas = SKTextureAtlas()
    var EnemyTextureArray: [SKTexture] = []
    
    var EnemyBlueTextureAtlas = SKTextureAtlas()
    var EnemyBlueTextureArray: [SKTexture] = []
    
    var BlueDiamondTextureAtlas = SKTextureAtlas()
    var BlueDiamondTextureArray: [SKTexture] = []
    
    var GreenDiamondTextureAtlas = SKTextureAtlas()
    var GreenDiamondTextureArray: [SKTexture] = []
    
    var PurpleDiamondTextureAtlas = SKTextureAtlas()
    var PurpleDiamondTextureArray: [SKTexture] = []
    
    var PlayerShipTextureAtlas = SKTextureAtlas()
    var PlayerShipTextureArray: [SKTexture] = []

    // Calculate where to spawn the enemies in the background
    
    let gameArea: CGRect
    override init(size: CGSize){
        let maxAspectRatio: CGFloat = 19.5/9
        let gameAreaWidth = size.height / maxAspectRatio
        let margin = (size.width - gameAreaWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: gameAreaWidth, height: size.height)
        super.init(size:size)
    }
    
    required init?(coder aDecoder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    
    override func didMove(to view: SKView) {
        
        loadTextures()
        
        background.position = CGPoint(x: self.size.width/2, y:self.size.height/2)
        background.zPosition = 0
        background.size.width = self.size.width
        background.size.height = self.size.height
        self.addChild(background)
        let anim =  SKAction.animate(with: BackgroundTextureArray, timePerFrame: 0.02)
        let anim4eva = SKAction.repeatForever(anim)
        background.run(anim4eva, withKey: "StanBack")
        
        let GameOverLabel = SKLabelNode(fontNamed: "ADAM.CGPRO")
        GameOverLabel.text = "Game Over!"
        GameOverLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.85)
        GameOverLabel.zPosition = 4
        GameOverLabel.fontSize = 120
        GameOverLabel.fontColor = SKColor.white
        self.addChild(GameOverLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: "ADAM.CGPRO")
        scoreLabel.text = "Score: \(userScore)"
        scoreLabel.fontColor = SKColor.white
        scoreLabel.fontSize = 70
        scoreLabel.zPosition = 4
        scoreLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.6)
        self.addChild(scoreLabel)
        
        let defaults = UserDefaults()
        var highscore = defaults.integer(forKey: "highscore")
        
        if userScore > highscore{
            defaults.setValue(userScore, forKey: "highscore")
            highscore = userScore
            NewHighScore = true
        }else{
            NewHighScore = false
        }
        
        let HighScoreLabel = SKLabelNode(fontNamed: "ADAM.CGPRO")
        
        if NewHighScore == true{
            HighScoreLabel.text = "New High Score! : \(highscore)"
            HighScoreLabel.fontSize = 70
            saveHigh(number: userScore)
        }else{
            HighScoreLabel.text = "High Score: \(highscore)"
            HighScoreLabel.fontSize = 70
        }
        HighScoreLabel.fontColor = SKColor.white
        HighScoreLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5)
        HighScoreLabel.zPosition = 4
        self.addChild(HighScoreLabel)
        
        restartLabel.text = "Restart"
        restartLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.3)
        restartLabel.zPosition = 4
        restartLabel.fontSize = 70
        self.addChild(restartLabel)
        
        homelabel.text = "Go Home"
        homelabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.2)
        homelabel.zPosition = 4
        homelabel.fontSize = 70
        self.addChild(homelabel)
        
        SpawnBackgroundEnemies()
        
    }
    
    func loadTextures(){

        PlayerShipTextureAtlas = SKTextureAtlas(named: "Boost.atlas")
        BackgroundTextureAtlas = SKTextureAtlas(named: "BackgroundImages.atlas")
        PurpleDiamondTextureAtlas = SKTextureAtlas(named: "purpleDiamond.atlas")
        GreenDiamondTextureAtlas = SKTextureAtlas(named: "greenDiamond.atlas")
        BlueDiamondTextureAtlas = SKTextureAtlas(named: "blueDiamond.atlas")
        EnemyTextureAtlas = SKTextureAtlas(named: "Enemyflames.atlas")
        EnemyBlueTextureAtlas = SKTextureAtlas(named: "EnemyBlue.atlas")
        
        for i in 1...EnemyTextureAtlas.textureNames.count{
            let TexName = "E\(i).png"
            EnemyTextureArray.append(SKTexture(imageNamed: TexName))
        }
        
        for i in 1...EnemyBlueTextureAtlas.textureNames.count{
            let TexName = "RocketFlames\(i).png"
            EnemyBlueTextureArray.append(SKTexture(imageNamed: TexName))
        }
        
        for n in 1...PlayerShipTextureAtlas.textureNames.count{
            let texture = "Boost\(n).png"
            PlayerShipTextureArray.append(SKTexture(imageNamed: texture))
        }
        
        for a in 1...PurpleDiamondTextureAtlas.textureNames.count{
            let texture = "Purple\(a).png"
            PurpleDiamondTextureArray.append(SKTexture(imageNamed: texture))
        }
        
        for a in 1...GreenDiamondTextureAtlas.textureNames.count{
            let texture = "Green\(a).png"
            GreenDiamondTextureArray.append(SKTexture(imageNamed: texture))
        }
        
        for a in 1...BlueDiamondTextureAtlas.textureNames.count{
            let texture = "Blue\(a).png"
            BlueDiamondTextureArray.append(SKTexture(imageNamed: texture))
        }
        
        for p in 1...BackgroundTextureAtlas.textureNames.count{
            let texture = "glitter-universe-1-\(p).png"
            BackgroundTextureArray.append(SKTexture(imageNamed: texture))
        }
        
    }
    
    func SpawnBackgroundEnemies(){
        let spawn = SKAction.run(EnemySpawner)
        let waitToSpawn = SKAction.wait(forDuration: 0.5)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnLoop = SKAction.repeatForever(spawnSequence)
        self.run(spawnLoop, withKey: "SpawningEnemies")
    }
    
    func createEnemy(image: String, name: String){
        enemy = SKSpriteNode(imageNamed: image)
        enemy.name = name
        if image == "E1"{
            enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        }else {
            enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width)
        }
        enemy.physicsBody!.affectedByGravity = false
        
    }
    
    func EnemySpawner(){
        let randomXStart = CGFloat.random(in: gameArea.minX..<gameArea.maxX)
        let randomXEnd = CGFloat.random(in: gameArea.minX..<gameArea.maxX)
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        let EnemyDecider = Int.random(in: 1..<8)
        if EnemyDecider == 1{
            createEnemy(image: "E1", name: "Enemy")
        }
        if EnemyDecider == 2{
            createEnemy(image: "RocketFlames1", name: "Enemy")
        }
        if EnemyDecider == 3{
            createEnemy(image: "Asteroid", name: "Asteroid")
        }
        if EnemyDecider == 4{
            let Lucky = Int.random(in: 1..<4)
            if Lucky == 3{
                createEnemy(image: "BoostCoin", name: "Boost")
            }else{
                createEnemy(image: "Asteroid", name: "Asteroid")
            }
        }
        if EnemyDecider == 5{
            let Lucky = Int.random(in: 1..<6)
            if Lucky == 2{
                createEnemy(image: "Blue1", name: "BlueDiamond")
            }
            else{
                createEnemy(image: "GoldAsteroid", name: "GoldAsteroid")
            }
        }
        if EnemyDecider == 6{
            createEnemy(image: "GoldAsteroid", name: "GoldAsteroid")
        }
        if EnemyDecider == 7{
            let Lucky = Int.random(in: 1..<4)
            if Lucky == 3{
                createEnemy(image: "PurpleXP1", name: "DoubleXP")
            }else{
                createEnemy(image: "GoldAsteroid", name: "Asteroid")
            }
        }
        
        enemy.position = startPoint
        enemy.zPosition = 2
        self.addChild(enemy)
        let anim = SKAction.animate(with: EnemyTextureArray, timePerFrame: 0.1)
        let redAnimForever = SKAction.repeatForever(anim)
        
        let aim = SKAction.animate(with: EnemyBlueTextureArray, timePerFrame: 0.1)
        let blueAnimForever = SKAction.repeatForever(aim)
        
        let diffX = endPoint.x - startPoint.x
        let diffY = endPoint.y - startPoint.y
        let amount2Rotate = atan2(diffY, diffX)
        enemy.zRotation = amount2Rotate
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 2)
        let rotate = SKAction.rotate(byAngle: 5, duration: 1)
        let rotation = SKAction.repeatForever(rotate)
        let deleteEnemy = SKAction.removeFromParent()
        let moveAndRemove = SKAction.sequence([moveEnemy, deleteEnemy])
        let AsteroidSequence = SKAction.group([rotation, moveAndRemove])
        let RedEnemySequence = SKAction.group([redAnimForever, moveAndRemove])
        let BlueEnemySequence = SKAction.group([blueAnimForever, moveAndRemove])
        
        if enemy.name == "Enemy"{
            if EnemyDecider == 1{
                enemy.run(RedEnemySequence)
            }
            if EnemyDecider == 2{
                enemy.run(BlueEnemySequence)
            }
        
        }
    
        else{enemy.run(AsteroidSequence)}
    }
    
    func saveHigh(number : Int){
        if GKLocalPlayer.local.isAuthenticated{
            let scoreReporter = GKScore(leaderboardIdentifier: "InterstellarRaider")
            scoreReporter.value = Int64(number)
            let ScoreArray : [GKScore] = [scoreReporter]
            GKScore.report(ScoreArray, withCompletionHandler: nil)

        }}
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches{
            let pointTouched = touch.location(in: self)
            
            if restartLabel.contains(pointTouched){
                let destination = GameScene(size: self.size)
                destination.scaleMode = self.scaleMode
                let transition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(destination, transition: transition)
            }
            
            if homelabel.contains(pointTouched){
                let destination = HomeScene(size: self.size)
                destination.scaleMode = self.scaleMode
                let transition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(destination, transition: transition)
            }
        }
        
    }
}
