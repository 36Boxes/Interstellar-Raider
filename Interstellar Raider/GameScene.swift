//
//  GameScene.swift
//  Interstellar Raider
//
//  Created by Josh Manik on 27/05/2021.
//

import SpriteKit
import GameplayKit
import GameKit

var userScore = 0

class GameScene: SKScene , SKPhysicsContactDelegate{
    
    // Levels and user lives
    
    var levelNumber = 0
    var lives = 3
    var count = 0
    
    // SpriteKit Labels & nodes
    
    let ScoreLabel = SKLabelNode(fontNamed: "ADAM.CGPRO")
    let LivesLabel = SKLabelNode(fontNamed: "ADAM.CGPRO")
    let background = SKSpriteNode(imageNamed: "glitter-universe-1-1")
    var enemy: SKSpriteNode!
    let player = SKSpriteNode(imageNamed: "Boost1")
    
    
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

    
    // Physics categories for different nodes that appear on the screen
    
    struct PhysicsCatergories {
        
        static let None: UInt32 = 0
        
        static let Player: UInt32 = 1
        
        static let Bullet: UInt32 = 2
        
        static let Enemy: UInt32 = 4
        
        static let Asteroid: UInt32 = 8
        
        static let DoublePoints: UInt32 = 16
        
        static let GoldCoin: UInt32 = 32
        
        static let AsteroidFragment: UInt32 = 64
        
        static let GoldAsteroid: UInt32 = 128
        
        static let XPCoin: UInt32 = 256
        
        static let PurpleDiamond: UInt32 = 512
        
        static let GreenDiamond: UInt32 = 1024
        
        static let BlueDiamond: UInt32 = 2048
    }
    
    // Texture atlas and array configuration
    
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
    
    var BackgroundTextureAtlas = SKTextureAtlas()
    var BackgroundTextureArray: [SKTexture] = []
    
    var BoostedBackgroundTextureAtlas = SKTextureAtlas()
    var BoostedBackgroundTextureArray: [SKTexture] = []
    
    var DoublePointsBackgroundTextureAtlas = SKTextureAtlas()
    var DoublePointsBackgroundTextureArray: [SKTexture] = []
    
    var BoostedDoublePointsBackgroundTextureAtlas = SKTextureAtlas()
    var BoostedDoublePointsBackgroundTextureArray: [SKTexture] = []
    
    // Game Area calculation, this isnt my code and i think it can be improved upon however it is not a priority as it works
    
    let gameArea: CGRect

    override init(size: CGSize){

        // to have this work nicely on most devices i could maybe identify the device and then have the correct aspect ratio
        let maxAspectRatio: CGFloat = 19.5/9
        let gameAreaWidth = size.height / maxAspectRatio
        let margin = (size.width - gameAreaWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: gameAreaWidth, height: size.height)
        super.init(size:size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    override func didMove(to view: SKView) {
        
        userScore = 0
        self.physicsWorld.contactDelegate = self
        loadTextures()
        
        // Adding the background to the scene and animating it
        
        background.size = CGSize (width: frame.maxX, height: frame.maxY)
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        let anim =  SKAction.animate(with: BackgroundTextureArray, timePerFrame: 0.02)
        let anim4eva = SKAction.repeatForever(anim)
        background.run(anim4eva, withKey: "StanBack")
        
        // Adding the player to the screen and animating it
        
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2)
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
        
        // Adding the Score label to the screen
        
        ScoreLabel.text = "Score : 0"
        ScoreLabel.fontSize = 70
        ScoreLabel.fontColor = SKColor.white
        ScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        ScoreLabel.position = CGPoint(x:self.size.width * 0.20, y: self.size.height * 0.9)
        ScoreLabel.zPosition = 100
        self.addChild(ScoreLabel)
        
        // Adding the lives label to the screen
        
        LivesLabel.text = "Lives : \(lives)"
        LivesLabel.fontSize = 70
        LivesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        LivesLabel.position = CGPoint(x: self.size.width * 0.8, y: self.size.height * 0.9)
        LivesLabel.zPosition = 100
        self.addChild(LivesLabel)
        
        startNewLevel()
        
    }

    func loselives(){
        lives -= 1
        LivesLabel.text = "Lives : \(lives)"
        
        let scaleUp = SKAction.scale(to: 2.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        LivesLabel.run(sequence)
        
        if lives == 0{
            gameOver()
        }

    }
    
    func addScore(number: Int){
        userScore += number
        ScoreLabel.text = "Score: \(userScore)"
        
    }
    
    func gameOver(){
        
        currentGameState = gameState.GameFinished
        
        self.removeAllActions()
        
        self.enumerateChildNodes(withName: "BullitBang"){
            bullet, stop in
            bullet.removeAllActions()
        }
        
        self.enumerateChildNodes(withName: "OPPBOY"){
            enemy, stop in
            enemy.removeAllActions()
        }
        
        let ChangeSceneAction = SKAction.run(changeScene)
        let waitForChange = SKAction.wait(forDuration: 1)
        let sequence = SKAction.sequence([waitForChange, ChangeSceneAction])
        self.run(sequence)
    }
    
    func changeScene(){
        let destination = GameScene(size:self.size)
        destination.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(destination, transition: myTransition)
    }
    
    // Fire Bullet function
    
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
        var EnemyDecider = Int.random(in: 1..<6)
        EnemyDecider = 1
        if EnemyDecider == 1{
            createEnemy(image: "E1", name: "EnemyRed", category: PhysicsCatergories.Enemy)
            enemy.position = startPoint
            enemy.zPosition = 2
            self.addChild(enemy)

        }
        let anim = SKAction.animate(with: EnemyTextureArray, timePerFrame: 0.1)
        let redAnimForever = SKAction.repeatForever(anim)
        
        let aim = SKAction.animate(with: EnemyBlueTextureArray, timePerFrame: 0.1)
        let blueAnimForever = SKAction.repeatForever(aim)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 2)
        let rotate = SKAction.rotate(byAngle: 5, duration: 1)
        let rotation = SKAction.repeatForever(rotate)
        let deleteEnemy = SKAction.removeFromParent()
        let wellDoneSoldier = SKAction.run(loselives)
        let moveAndRemove = SKAction.sequence([moveEnemy, deleteEnemy])
        let moveAndRemoveandLive = SKAction.sequence([moveEnemy, deleteEnemy, wellDoneSoldier])
        let AsteroidSequence = SKAction.group([rotation, moveAndRemove])
        let RedEnemySequence = SKAction.group([redAnimForever, moveAndRemoveandLive])
        let BlueEnemySequence = SKAction.group([blueAnimForever, moveAndRemoveandLive])
        
        if enemy.name == "EnemyRed"{enemy.run(RedEnemySequence)}
        if enemy.name == "EnemyBlue"{enemy.run(BlueEnemySequence)}
        else{enemy.run(AsteroidSequence)}
    }
    
    func startNewLevel(){
        
        levelNumber += 1
        
        if self.action(forKey: "SpawningEnemies") != nil{
            self.removeAction(forKey: "SpawningEnemies")
        }
        
        var levelDuration = TimeInterval()
        
        switch levelNumber {
        case 1: levelDuration = 1
        case 2: levelDuration = 0.8
        case 3: levelDuration = 0.6
        case 4: levelDuration = 0.5
        case 5: levelDuration = 0.3
        default:
            levelDuration = 0.4
            print("Something went wrong with my level numbers")
        }
        
        let spawn = SKAction.run(EnemySpawner)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnLoop = SKAction.repeatForever(spawnSequence)
        self.run(spawnLoop, withKey: "SpawningEnemies")
        let second_wait = SKAction.wait(forDuration: 1)
        let check_boost = SKAction.run(CheckRocketStatus)
        let seq = SKAction.sequence([second_wait, check_boost])
        let seqLoop = SKAction.repeatForever(seq)
        self.run(seqLoop)
    }
    
    func CheckRocketStatus(){
        print(CurrentRocketMode)
        if CurrentRocketMode == RocketMode.Boosted{
            count -= 1
        }
        if CurrentRocketMode == RocketMode.DoubleXP {
            count -= 1
        }
        if CurrentRocketMode == RocketMode.BoostedDoubleXP{
            count -= 1
        }
        
        if count == 0{
            if CurrentRocketMode == RocketMode.Boosted{
                background.removeAction(forKey: "BoostBack")
                let anim =  SKAction.animate(with: BackgroundTextureArray, timePerFrame: 0.02)
                let anim4eva = SKAction.repeatForever(anim)
                background.run(anim4eva, withKey: "StanBack")
                CurrentRocketMode = RocketMode.Normal
            }
            if CurrentRocketMode == RocketMode.BoostedDoubleXP{
                background.removeAction(forKey: "BoostDoubleBack")
                let anim =  SKAction.animate(with: BackgroundTextureArray, timePerFrame: 0.02)
                let anim4eva = SKAction.repeatForever(anim)
                background.run(anim4eva, withKey: "StanBack")
                CurrentRocketMode = RocketMode.Normal
            }
            if CurrentRocketMode == RocketMode.DoubleXP{
                background.removeAction(forKey: "DoubleBack")
                let anim =  SKAction.animate(with: BackgroundTextureArray, timePerFrame: 0.02)
                let anim4eva = SKAction.repeatForever(anim)
                background.run(anim4eva, withKey: "StanBack")
                CurrentRocketMode = RocketMode.Normal
            }
            
            
            
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches{
            
            let pointOfTouch = touch.location(in: self)
            let prevoiusTouch = touch.previousLocation(in: self)
            
            let difference = pointOfTouch.x - prevoiusTouch.x
            
            if currentGameState == gameState.DuringGame{
                player.position.x  += difference
            }
            
            if player.position.x >= gameArea.maxX - player.size.width/2{
                player.position.x = gameArea.maxX - player.size.width/2
            }
            
            if player.position.x < gameArea.minX + player.size.width/2{
                player.position.x = gameArea.minX + player.size.width / 2
            }
        }
        
    }
    
    
    func loadTextures(){

        PlayerShipTextureAtlas = SKTextureAtlas(named: "Boost.atlas")
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
            let TexName = "E\(i).png"
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

}
