//
//  TutorialScene4.swift
//  Interstellar Raider
//
//  Created by Josh Manik on 04/06/2021.
//
import Foundation
import SpriteKit
import GameKit

class TutorialScene4: SKScene, SKPhysicsContactDelegate {
    
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
    
    var BoostedBackgroundTextureAtlas = SKTextureAtlas()
    var BoostedBackgroundTextureArray: [SKTexture] = []
    
    var DoublePointsBackgroundTextureAtlas = SKTextureAtlas()
    var DoublePointsBackgroundTextureArray: [SKTexture] = []
    
    var BoostedDoublePointsBackgroundTextureAtlas = SKTextureAtlas()
    var BoostedDoublePointsBackgroundTextureArray: [SKTexture] = []
    
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
        TutorialHelp.text = "The gold coin gives Invincibility"
        TutorialHelp.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.9)
        TutorialHelp.zPosition = 4
        TutorialHelp.fontSize = 35
        TutorialHelp.fontColor = SKColor.white
        self.addChild(TutorialHelp)
        
        let TutorialHelp1 = SKLabelNode(fontNamed: "ADAM.CGPRO")
        TutorialHelp1.text = "The background will turn red while it is active"
        TutorialHelp1.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.87)
        TutorialHelp1.zPosition = 4
        TutorialHelp1.fontSize = 35
        TutorialHelp1.fontColor = SKColor.white
        self.addChild(TutorialHelp1)
        
        let TutorialHelp2 = SKLabelNode(fontNamed: "ADAM.CGPRO")
        TutorialHelp2.text = "You still have to stop enemy ships from reaching the end"
        TutorialHelp2.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.84)
        TutorialHelp2.zPosition = 4
        TutorialHelp2.fontSize = 30
        TutorialHelp2.fontColor = SKColor.white
        self.addChild(TutorialHelp2)
        
        let TutorialHelp3 = SKLabelNode(fontNamed: "ADAM.CGPRO")
        TutorialHelp3.text = "If you have both power-ups"
        TutorialHelp3.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.81)
        TutorialHelp3.zPosition = 4
        TutorialHelp3.fontSize = 30
        TutorialHelp3.fontColor = SKColor.white
        self.addChild(TutorialHelp3)
        
        let TutorialHelp4 = SKLabelNode(fontNamed: "ADAM.CGPRO")
        TutorialHelp4.text = "the background will turn gold"
        TutorialHelp4.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.78)
        TutorialHelp4.zPosition = 4
        TutorialHelp4.fontSize = 30
        TutorialHelp4.fontColor = SKColor.white
        self.addChild(TutorialHelp4)
        
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
        BoostedBackgroundTextureAtlas = SKTextureAtlas(named: "BoostedBackground.atlas")
        DoublePointsBackgroundTextureAtlas = SKTextureAtlas(named: "DoublePointsBackground.atlas")
        BoostedDoublePointsBackgroundTextureAtlas = SKTextureAtlas(named: "BoostedDoublePointsBackground.atlas")
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
        
        for n in 1...LostlifeTextureAtlas.textureNames.count{
            let texture = "lost\(n).png"
            LostlifeTextureArray.append(SKTexture(imageNamed: texture))
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
        
        for p in 1...BoostedBackgroundTextureAtlas.textureNames.count{
            let texture = "red-universe-1-\(p).png"
            BoostedBackgroundTextureArray.append(SKTexture(imageNamed: texture))
        }
        
        for p in 1...DoublePointsBackgroundTextureAtlas.textureNames.count{
            let texture = "green-universe-1-\(p).png"
            DoublePointsBackgroundTextureArray.append(SKTexture(imageNamed: texture))
        }
        
        for p in 1...BoostedDoublePointsBackgroundTextureAtlas.textureNames.count{
            let texture = "gold-universe-1-\(p).png"
            BoostedDoublePointsBackgroundTextureArray.append(SKTexture(imageNamed: texture))
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
            createEnemy(image: "BoostCoin", name: "Boost", category: PhysicsCatergories.GoldCoin)
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
            let destination = TutorialScene3(size: self.size)
            destination.scaleMode = self.scaleMode
            let myTransition = SKTransition.fade(withDuration: 0.4)
            self.view!.presentScene(destination, transition: myTransition)
        }
        
        if nodeTapped.name == "Next"{
            let destination = TutorialScene5(size: self.size)
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
        
        let boostback = SKAction.animate(with: BoostedBackgroundTextureArray, timePerFrame: 0.02)
        let boostback4eva = SKAction.repeatForever(boostback)
        
        // If the bullet hits the gold coin
        
        if body1.categoryBitMask == PhysicsCatergories.Bullet && body2.categoryBitMask == PhysicsCatergories.GoldCoin{
            if body2.node != nil{
                
                if body2.node!.position.y > self.size.height{
                    return
                }else{
                    Explode(explodeposition: body2.node!.position, image: "explosion1gold")
                    body2.node?.removeFromParent()
                }
        }
        }
        
        // If the player runs into the gold coin
        
        else if body1.categoryBitMask == PhysicsCatergories.Player && body2.categoryBitMask == PhysicsCatergories.GoldCoin{
            
            // Since we hit the gold coin we want to give a bonus life and invunerable travel travel
            // My thought process is to call a 30 second timer in which we set the rocketmode to boosted.
            if CurrentRocketMode == RocketMode.DoubleXP{
                CurrentRocketMode = RocketMode.BoostedDoubleXP

            }
            else if CurrentRocketMode == RocketMode.Normal{
                CurrentRocketMode = RocketMode.Boosted
                background.removeAction(forKey: "StanBack")
                background.run(boostback4eva, withKey: "BoostBack")

            }
            body2.node?.removeFromParent()
            
        }
        
        // If the player runs into 2x coin
        
        else if body1.categoryBitMask == PhysicsCatergories.Player && body2.categoryBitMask == PhysicsCatergories.XPCoin{
            
            // Since we hit the 2X coin we want to give doublepoints
            // My thought process is to call a 30 second timer in which we set the rocketmode to boosted.
            if CurrentRocketMode == RocketMode.Boosted{
                CurrentRocketMode = RocketMode.BoostedDoubleXP


            }
            else if CurrentRocketMode == RocketMode.Normal{
                CurrentRocketMode = RocketMode.DoubleXP

            }
            body2.node?.removeFromParent()
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
    
    func FragmentGoldAsteroid(FragPosition: CGPoint){
        let startPoint = FragPosition
        let randomXEnd = CGFloat.random(in: gameArea.minX..<gameArea.maxX)
        let randomXEnd2 = CGFloat.random(in: gameArea.minX..<gameArea.maxX)
        let randomXEnd3 = CGFloat.random(in: gameArea.minX..<gameArea.maxX)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        let endPoint2 = CGPoint(x: randomXEnd2, y: -self.size.height * 0.2)
        let endPoint3 = CGPoint(x: randomXEnd3, y: -self.size.height * 0.2)
        let enemy1 : SKSpriteNode
        enemy1 = SKSpriteNode(imageNamed: "Purple1")
        enemy1.name = "ROID"
        enemy1.physicsBody = SKPhysicsBody(circleOfRadius: enemy1.size.width)
        enemy1.physicsBody!.affectedByGravity = false
        enemy1.physicsBody!.categoryBitMask = PhysicsCatergories.PurpleDiamond
        enemy1.physicsBody!.collisionBitMask = PhysicsCatergories.Enemy | PhysicsCatergories.Bullet
        enemy1.physicsBody!.contactTestBitMask = PhysicsCatergories.Player | PhysicsCatergories.Bullet
        enemy1.position = startPoint
        enemy1.zPosition = 2
        self.addChild(enemy1)
        let enemy2 : SKSpriteNode
        enemy2 = SKSpriteNode(imageNamed: "Green1")
        enemy2.name = "ROID"
        enemy2.physicsBody = SKPhysicsBody(circleOfRadius: enemy2.size.width)
        enemy2.physicsBody!.affectedByGravity = false
        enemy2.physicsBody!.categoryBitMask = PhysicsCatergories.GreenDiamond
        enemy2.physicsBody!.collisionBitMask = PhysicsCatergories.Enemy | PhysicsCatergories.Bullet
        enemy2.physicsBody!.contactTestBitMask = PhysicsCatergories.Player | PhysicsCatergories.Bullet
        enemy2.position = startPoint
        enemy2.zPosition = 2
        self.addChild(enemy2)
        let enemy3 : SKSpriteNode
        enemy3 = SKSpriteNode(imageNamed: "Blue1")
        enemy3.name = "ROID"
        enemy3.physicsBody = SKPhysicsBody(circleOfRadius: enemy3.size.width)
        enemy3.physicsBody!.affectedByGravity = false
        enemy3.physicsBody!.categoryBitMask = PhysicsCatergories.BlueDiamond
        enemy3.physicsBody!.collisionBitMask = PhysicsCatergories.Enemy | PhysicsCatergories.Bullet
        enemy3.physicsBody!.contactTestBitMask = PhysicsCatergories.Player | PhysicsCatergories.Bullet
        enemy3.position = startPoint
        enemy3.zPosition = 2
        self.addChild(enemy3)

        
        let purpAnim = SKAction.animate(with:PurpleDiamondTextureArray, timePerFrame: 0.05)
        let greenAnim = SKAction.animate(with:GreenDiamondTextureArray, timePerFrame: 0.05)
        let blueAnim = SKAction.animate(with:BlueDiamondTextureArray, timePerFrame: 0.05)
        let purpAnim4eva = SKAction.repeatForever(purpAnim)
        let greenAnim4eva = SKAction.repeatForever(greenAnim)
        let blueAnim4eva = SKAction.repeatForever(blueAnim)
        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
        let moveEnemy2 = SKAction.move(to: endPoint2, duration: 1.5)
        let moveEnemy3 = SKAction.move(to: endPoint3, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy])
        let enemySequence2 = SKAction.sequence([moveEnemy2, deleteEnemy])
        let enemySequence3 = SKAction.sequence([moveEnemy3, deleteEnemy])
        let PdSeq = SKAction.group([purpAnim4eva, enemySequence])
        let GdSeq = SKAction.group([greenAnim4eva, enemySequence2])
        let BdSeq = SKAction.group([blueAnim4eva, enemySequence3])

        
        if currentGameState == gameState.DuringGame{
            enemy1.run(PdSeq)
            enemy2.run(GdSeq)
            enemy3.run(BdSeq)

        }
        
        
    }
    
}
