//
//  HomeScene.swift
//  Interstellar Raider
//
//  Created by Josh Manik on 02/06/2021.
//

import Foundation
import SpriteKit
import GameKit

class HomeScene: SKScene , GKGameCenterControllerDelegate{
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    // Various different nodes and variables we need for the scene
    
    let background = SKSpriteNode(imageNamed: "glitter-universe-1-1")
    var enemy : SKSpriteNode!
    let localPlayer = GKLocalPlayer.local
    var GameCenterPlayer = true
    
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
        authPlayer()
        
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.size.width = self.size.width
        background.size.height = self.size.height
        background.zPosition = 0
        self.addChild(background)
        let anim =  SKAction.animate(with: BackgroundTextureArray, timePerFrame: 0.02)
        let anim4eva = SKAction.repeatForever(anim)
        background.run(anim4eva, withKey: "StanBack")
        
        let GameName = SKLabelNode(fontNamed: "ADAM.CGPRO")
        GameName.text = "Interstellar Raider"
        GameName.fontSize = 80
        GameName.fontColor = SKColor.white
        GameName.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.7)
        GameName.zPosition = 1
        self.addChild(GameName)
        
        let GameStart = SKLabelNode(fontNamed: "ADAM.CGPRO")
        GameStart.text = "Start"
        GameStart.fontSize = 70
        GameStart.fontColor = SKColor.white
        GameStart.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.4)
        GameStart.zPosition = 1
        GameStart.name = "StartButton"
        self.addChild(GameStart)
        
        
        let Leaderboards = SKLabelNode(fontNamed: "ADAM.CGPRO")
        Leaderboards.text = "Leaderboards"
        Leaderboards.fontSize = 70
        Leaderboards.fontColor = SKColor.white
        Leaderboards.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2)
        Leaderboards.zPosition = 1
        Leaderboards.name = "Leaderboards"
        self.addChild(Leaderboards)
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
    
    func authPlayer(){
        localPlayer.authenticateHandler = {
            (view, Error) in
            // if they accept show the view
            if view != nil {self.view?.window?.rootViewController?.present(view!, animated: true, completion: nil)}
            // if they dont dont show view and log they are not in gamecenter
            else {self.GameCenterPlayer = false}
        }}
    
    // function to make labels into buttons
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            let nodeTapped = atPoint(pointOfTouch)
            
            
            if nodeTapped.name == "StartButton"{
                let destination = GameScene(size: self.size)
                destination.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.4)
                self.view!.presentScene(destination, transition: myTransition)
            }
            
            if nodeTapped.name == "Leaderboards"{
                let destination = LeaderboardsScene(size: self.size)
                destination.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.4)
                self.view!.presentScene(destination, transition: myTransition)
            }
            
        }
    }
    
}
