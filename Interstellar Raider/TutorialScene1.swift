//
//  TutorialScene1.swift
//  Interstellar Raider
//
//  Created by Josh Manik on 04/06/2021.
//

import Foundation
import SpriteKit
import GameKit

class TutorialScene1: SKScene, SKPhysicsContactDelegate {
    
    let background = SKSpriteNode(imageNamed: "glitter-universe-1-1")
    var enemy : SKSpriteNode!
    let player = SKSpriteNode(imageNamed: "Boost1")
    
    // The various different textures needed for animation
    
    var BackgroundTextureAtlas = SKTextureAtlas()
    var BackgroundTextureArray: [SKTexture] = []
    
    var LostlifeTextureAtlas = SKTextureAtlas()
    var LostlifeTextureArray: [SKTexture] = []
    
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
    
    struct PhysicsCatergories {
        
        static let None: UInt32 = 0
        
        static let Player: UInt32 = 1
        
        static let Bullet: UInt32 = 2
        
        static let Enemy: UInt32 = 4
        
        static let Asteroid: UInt32 = 8
        
        static let BlueEnemy: UInt32 = 16
        
        static let GoldCoin: UInt32 = 32
        
        static let AsteroidFragment: UInt32 = 64
        
        static let GoldAsteroid: UInt32 = 128
        
        static let XPCoin: UInt32 = 256
        
        static let PurpleDiamond: UInt32 = 512
        
        static let GreenDiamond: UInt32 = 1024
        
        static let BlueDiamond: UInt32 = 2048
    }
    
    // Calculate where to spawn the enemies in the background
    
    let gameArea: CGRect
    override init(size: CGSize){
        let maxAspectRatio: CGFloat = 19.5/9
        let gameAreaWidth = size.height / maxAspectRatio
        let margin = (size.width - gameAreaWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: gameAreaWidth, height: size.height)
        super.init(size:size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Rocket Mode cases
    
    enum gameState{
        case PreGame
        case DuringGame
        case GameFinished
    }
    
    enum RocketMode {
        case Boosted
        case Normal
        case DoubleXP
        case BoostedDoubleXP
    }
    
    var CurrentRocketMode = RocketMode.Normal
    var currentGameState = gameState.DuringGame
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        let TutorialHelp = SKLabelNode(fontNamed: "ADAM.CGPRO")
        TutorialHelp.text = "Avoid the brown asteroids"
        TutorialHelp.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.9)
        TutorialHelp.zPosition = 4
        TutorialHelp.fontSize = 40
        TutorialHelp.fontColor = SKColor.white
        self.addChild(TutorialHelp)
        
        let TutorialHelp1 = SKLabelNode(fontNamed: "ADAM.CGPRO")
        TutorialHelp1.text = "they offer no points"
        TutorialHelp1.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.87)
        TutorialHelp1.zPosition = 4
        TutorialHelp1.fontSize = 40
        TutorialHelp1.fontColor = SKColor.white
        self.addChild(TutorialHelp1)
        
        let TutorialHelp2 = SKLabelNode(fontNamed: "ADAM.CGPRO")
        TutorialHelp2.text = "& if you shoot them they fragment"
        TutorialHelp2.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.84)
        TutorialHelp2.zPosition = 4
        TutorialHelp2.fontSize = 40
        TutorialHelp2.fontColor = SKColor.white
        self.addChild(TutorialHelp2)
        
        loadTextures()
        
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.size.width = self.size.width
        background.size.height = self.size.height
        background.zPosition = 0
        self.addChild(background)
        let anim =  SKAction.animate(with: BackgroundTextureArray, timePerFrame: 0.02)
        let anim4eva = SKAction.repeatForever(anim)
        background.run(anim4eva, withKey: "StanBack")
        
        let BackLabel = SKSpriteNode(imageNamed: "arrow-left")
        BackLabel.name = "Back"
        BackLabel.size = CGSize(width: 100, height: 100)
        BackLabel.position = CGPoint(x:self.size.width * 0.23, y: self.size.height * 0.1)
        BackLabel.zPosition = 100
        self.addChild(BackLabel)
        let Backtext = SKLabelNode(fontNamed: "ADAM.CGPRO")
        Backtext.text = "Back"
        Backtext.name = "Back"
        Backtext.position = CGPoint(x:self.size.width * 0.23, y: self.size.height * 0.05)
        Backtext.zPosition = 100
        self.addChild(Backtext)
        
        let ReloadLabel = SKSpriteNode(imageNamed: "arrow-right")
        ReloadLabel.name = "Next"
        ReloadLabel.size = CGSize(width: 100, height: 100)
        ReloadLabel.position = CGPoint(x: self.size.width * 0.77, y: self.size.height * 0.1)
        ReloadLabel.zPosition = 100
        self.addChild(ReloadLabel)
        let NextText = SKLabelNode(fontNamed: "ADAM.CGPRO")
        NextText.text = "Next"
        NextText.name = "Next"
        NextText.position = CGPoint(x:self.size.width * 0.77, y: self.size.height * 0.05)
        NextText.zPosition = 100
        self.addChild(NextText)
        
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.25)
        player.setScale(1)
        player.zPosition = 3
        self.addChild(player)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
        player.physicsBody!.affectedByGravity = false
        player.name = "Player"
        player.physicsBody!.categoryBitMask = PhysicsCatergories.Player
        player.physicsBody!.collisionBitMask = PhysicsCatergories.None
        player.physicsBody!.contactTestBitMask = PhysicsCatergories.Enemy
        let an1m = SKAction.animate(with: PlayerShipTextureArray, timePerFrame: 0.08)
        let an1m4eva = SKAction.repeatForever(an1m)
        player.run(an1m4eva, withKey:"Standard")
        
        SpawnBackgroundEnemies()
    }
    
    func loadTextures(){

        PlayerShipTextureAtlas = SKTextureAtlas(named: "Boost.atlas")
        LostlifeTextureAtlas = SKTextureAtlas(named: "Lostlifeanim.atlas")
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
        
        for n in 1...LostlifeTextureAtlas.textureNames.count{
            let texture = "lost\(n).png"
            LostlifeTextureArray.append(SKTexture(imageNamed: texture))
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
        let waitToSpawn = SKAction.wait(forDuration: 1)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnLoop = SKAction.repeatForever(spawnSequence)
        self.run(spawnLoop, withKey: "SpawningEnemies")
    }
    
    func createEnemy(image: String, name: String, category: UInt32){
        enemy = SKSpriteNode(imageNamed: image)
        enemy.name = name
        if image == "E1"{
            enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        }else {
            enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width)
        }
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = category
        enemy.physicsBody!.collisionBitMask = PhysicsCatergories.Enemy | PhysicsCatergories.Bullet
        enemy.physicsBody!.contactTestBitMask = PhysicsCatergories.Player | PhysicsCatergories.Bullet
        
    }
    
    func EnemySpawner(){
        let randomXStart = CGFloat.random(in: gameArea.minX..<gameArea.maxX)
        let randomXEnd = CGFloat.random(in: gameArea.minX..<gameArea.maxX)
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        let EnemyDecider = 1
        if EnemyDecider == 1{
            createEnemy(image: "Asteroid", name: "Asteroid", category: PhysicsCatergories.Asteroid)
        }
        
        enemy.position = startPoint
        enemy.zPosition = 2
        self.addChild(enemy)
        
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
    
        enemy.run(AsteroidSequence)
    }
    
    func ShootBullet() {
        let bullet = SKSpriteNode(imageNamed: "MissileFinished")
        bullet.name = "BullitBang"
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(texture: player.texture!,
                                           size: player.texture!.size())
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCatergories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCatergories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCatergories.Enemy
        self.addChild(bullet)
        
        let fireBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let removeBullet = SKAction.removeFromParent()
        let ActionsToPerform = SKAction.sequence([fireBullet, removeBullet])
        bullet.run(ActionsToPerform)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches{
            
            let pointOfTouch = touch.location(in: self)
            let prevoiusTouch = touch.previousLocation(in: self)
            
            let difference = pointOfTouch.x - prevoiusTouch.x
            
            player.position.x  += difference
            
            
            if player.position.x >= gameArea.maxX - player.size.width/2{
                player.position.x = gameArea.maxX - player.size.width/2
            }
            
            if player.position.x < gameArea.minX + player.size.width/2{
                player.position.x = gameArea.minX + player.size.width / 2
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        ShootBullet()
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            let nodeTapped = atPoint(pointOfTouch)
        if nodeTapped.name == "Back"{
            let destination = HomeScene(size: self.size)
            destination.scaleMode = self.scaleMode
            let myTransition = SKTransition.fade(withDuration: 0.4)
            self.view!.presentScene(destination, transition: myTransition)
        }
        
        if nodeTapped.name == "Next"{
            let destination = TutorialScene2(size: self.size)
            destination.scaleMode = self.scaleMode
            let myTransition = SKTransition.fade(withDuration: 0.4)
            self.view!.presentScene(destination, transition: myTransition)
        }
        }
        
    }
    
    // Function called when 2 physics bodies make contact
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        

        let lost = SKAction.animate(with: LostlifeTextureArray, timePerFrame: 0.1)
        let lostrep = SKAction.repeat(lost, count: 2)
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            body1 = contact.bodyA
            body2 = contact.bodyB
        }else{
            body1 = contact.bodyB
            body2 = contact.bodyA
        }

        // If the bullet hits the asteroid
        if body1.categoryBitMask == PhysicsCatergories.Bullet && body2.categoryBitMask == PhysicsCatergories.Asteroid{
            if body2.node != nil{
                // Check wether the enemy is on screen when the bullet makes contact
                if body2.node!.position.y > self.size.height{
                    return
                }else{
                    let startofFragmentation = body2.node!.position
                    Explode(explodeposition: body2.node!.position, image: "explosion1red")
                    
                    FragmentAsteroid(FragPosition: startofFragmentation)
                    body1.node?.removeFromParent()
                    body2.node?.removeFromParent()
                }
            }
        }
        
        // If the bullet hits the asteroid fragment
        else if body1.categoryBitMask == PhysicsCatergories.Bullet && body2.categoryBitMask == PhysicsCatergories.AsteroidFragment{
            if body2.node != nil{
                // Check wether the enemy is on screen when the bullet makes contact
                if body2.node!.position.y > self.size.height{
                    return
                }else{
                    Explode(explodeposition: body2.node!.position, image: "explosion1red")
                    body1.node?.removeFromParent()
                    body2.node?.removeFromParent()
                }
            }
        }
        
        // If the player hits the asteroid
        else if body1.categoryBitMask == PhysicsCatergories.Player && body2.categoryBitMask == PhysicsCatergories.Asteroid{
            
            if CurrentRocketMode == RocketMode.BoostedDoubleXP{
                if body2.node != nil{Explode(explodeposition: body2.node!.position, image: "explosion1red")}
                body2.node?.removeFromParent()

            }
            else if CurrentRocketMode == RocketMode.DoubleXP{
                if body1.node != nil{Explode(explodeposition: body1.node!.position, image: "explosion1red")}
                if body2.node != nil{Explode(explodeposition: body2.node!.position, image: "explosion1red")}
                
                body2.node?.removeFromParent()
                player.run(lostrep)

            }
            else if CurrentRocketMode == RocketMode.Boosted{
                if body2.node != nil{Explode(explodeposition: body2.node!.position, image: "explosion1red")}
                body2.node?.removeFromParent()

            }
            else if CurrentRocketMode == RocketMode.Normal{
                if body1.node != nil{Explode(explodeposition: body1.node!.position, image: "explosion1red")}
                if body2.node != nil{Explode(explodeposition: body2.node!.position, image: "explosion1red")}

                body2.node?.removeFromParent()
                player.run(lostrep)

            }
        }
        
        // If the player hits an asteroid fragment
        else if body1.categoryBitMask == PhysicsCatergories.Player && body2.categoryBitMask == PhysicsCatergories.AsteroidFragment{
            
            if CurrentRocketMode == RocketMode.BoostedDoubleXP{
                if body2.node != nil{Explode(explodeposition: body2.node!.position, image: "explosion1red")}
                body2.node?.removeFromParent()

            }
            else if CurrentRocketMode == RocketMode.DoubleXP{
                if body1.node != nil{Explode(explodeposition: body1.node!.position, image: "explosion1red")}
                if body2.node != nil{Explode(explodeposition: body2.node!.position, image: "explosion1red")}

                body2.node?.removeFromParent()
                player.run(lostrep)

            }
            else if CurrentRocketMode == RocketMode.Boosted{
                if body2.node != nil{Explode(explodeposition: body2.node!.position, image: "explosion1red")}
                body2.node?.removeFromParent()

            }
            else if CurrentRocketMode == RocketMode.Normal{
                if body1.node != nil{Explode(explodeposition: body1.node!.position,  image: "explosion1red")}
                if body2.node != nil{Explode(explodeposition: body2.node!.position, image: "explosion1red")}

                body2.node?.removeFromParent()
                player.run(lostrep)

            }
        }

        


        
        

    }
    
    func Explode(explodeposition: CGPoint, image: String){
        let explosion = SKSpriteNode(imageNamed: image)
        explosion.position = explodeposition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fade = SKAction.fadeOut(withDuration: 0.1)
        let remove = SKAction.removeFromParent()
        let explosionSequence = SKAction.sequence([scaleIn, fade, remove])
        explosion.run(explosionSequence)
    }
    
    func FragmentAsteroid(FragPosition: CGPoint){
        let startPoint = FragPosition
        let randomXEnd = CGFloat.random(in: gameArea.minX..<gameArea.maxX)
        let randomXEnd2 = CGFloat.random(in: gameArea.minX..<gameArea.maxX)
        let randomXEnd3 = CGFloat.random(in: gameArea.minX..<gameArea.maxX)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        let endPoint2 = CGPoint(x: randomXEnd2, y: -self.size.height * 0.2)
        let endPoint3 = CGPoint(x: randomXEnd3, y: -self.size.height * 0.2)
        let enemy1 : SKSpriteNode
        enemy1 = SKSpriteNode(imageNamed: "Asteroidfrag")
        enemy1.name = "ROID"
        enemy1.physicsBody = SKPhysicsBody(rectangleOf: enemy1.size)
        enemy1.physicsBody!.affectedByGravity = false
        enemy1.physicsBody!.categoryBitMask = PhysicsCatergories.AsteroidFragment
        enemy1.physicsBody!.collisionBitMask = PhysicsCatergories.Enemy | PhysicsCatergories.Bullet
        enemy1.physicsBody!.contactTestBitMask = PhysicsCatergories.Player | PhysicsCatergories.Bullet
        enemy1.position = startPoint
        enemy1.zPosition = 2
        self.addChild(enemy1)
        let enemy2 : SKSpriteNode
        enemy2 = SKSpriteNode(imageNamed: "AsteroidFrag2")
        enemy2.name = "ROID"
        enemy2.physicsBody = SKPhysicsBody(rectangleOf: enemy2.size)
        enemy2.physicsBody!.affectedByGravity = false
        enemy2.physicsBody!.categoryBitMask = PhysicsCatergories.AsteroidFragment
        enemy2.physicsBody!.collisionBitMask = PhysicsCatergories.Enemy | PhysicsCatergories.Bullet
        enemy2.physicsBody!.contactTestBitMask = PhysicsCatergories.Player | PhysicsCatergories.Bullet
        enemy2.position = startPoint
        enemy2.zPosition = 2
        self.addChild(enemy2)
        let enemy3 : SKSpriteNode
        enemy3 = SKSpriteNode(imageNamed: "asteroidfrag3")
        enemy3.name = "ROID"
        enemy3.physicsBody = SKPhysicsBody(rectangleOf: enemy3.size)
        enemy3.physicsBody!.affectedByGravity = false
        enemy3.physicsBody!.categoryBitMask = PhysicsCatergories.AsteroidFragment
        enemy3.physicsBody!.collisionBitMask = PhysicsCatergories.Enemy | PhysicsCatergories.Bullet
        enemy3.physicsBody!.contactTestBitMask = PhysicsCatergories.Player | PhysicsCatergories.Bullet
        enemy3.position = startPoint
        enemy3.zPosition = 2
        self.addChild(enemy3)

        
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
        let moveEnemy2 = SKAction.move(to: endPoint2, duration: 1.5)
        let moveEnemy3 = SKAction.move(to: endPoint3, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy])
        let enemySequence2 = SKAction.sequence([moveEnemy2, deleteEnemy])
        let enemySequence3 = SKAction.sequence([moveEnemy3, deleteEnemy])
        
        if currentGameState == gameState.DuringGame{
            enemy1.run(enemySequence)
            enemy2.run(enemySequence2)
            enemy3.run(enemySequence3)

        }
        
        
    }
        
    
}
