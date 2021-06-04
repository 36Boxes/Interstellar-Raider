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
    var AlreadyHasAnimation = false
    
    // SpriteKit Labels & nodes
    
    let ScoreLabel = SKLabelNode(fontNamed: "ADAM.CGPRO")
    let LivesLabel = SKLabelNode(fontNamed: "ADAM.CGPRO")
    var Heart1: SKSpriteNode!
    var Heart2: SKSpriteNode!
    var Heart3: SKSpriteNode!
    let background = SKSpriteNode(imageNamed: "glitter-universe-1-1")
    var enemy: SKSpriteNode!
    var extraEnemy: SKSpriteNode!
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
        
        static let BlueEnemy: UInt32 = 16
        
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
    
    var LostlifeTextureAtlas = SKTextureAtlas()
    var LostlifeTextureArray: [SKTexture] = []
    
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
        
        Heart1 = SKSpriteNode(imageNamed: "HeartNoBackground")
        Heart1.size = CGSize(width: 75, height: 75)
        Heart1.position = CGPoint(x: self.size.width * 0.78, y: self.size.height * 0.91)
        Heart1.zPosition = 100
        self.addChild(Heart1)
        Heart2 = SKSpriteNode(imageNamed: "HeartNoBackground")
        Heart2.size = CGSize(width: 75, height: 75)
        Heart2.position = CGPoint(x: self.size.width * 0.72, y: self.size.height * 0.91)
        Heart2.zPosition = 100
        self.addChild(Heart2)
        Heart3 = SKSpriteNode(imageNamed: "HeartNoBackground")
        Heart3.size = CGSize(width: 75, height: 75)
        Heart3.position = CGPoint(x: self.size.width * 0.66, y: self.size.height * 0.91)
        Heart3.zPosition = 100
        self.addChild(Heart3)
        
        
        startNewLevel()
        
    }

    func loselives(){
        if lives == 3{
            lives -= 1
            let scaleUp = SKAction.scale(to: 2.5, duration: 0.2)
            let scaleDown = SKAction.scale(to: 0.8, duration: 0.2)
            let changetexture = SKAction.run {
                self.Heart1.texture = SKTexture(imageNamed: "emptyHeartv2")
            }
            let sequence = SKAction.sequence([scaleUp, scaleDown, changetexture])
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            Heart1.run(sequence)

        }
        else if lives == 2{
            lives -= 1
            let scaleUp = SKAction.scale(to: 2.5, duration: 0.2)
            let scaleDown = SKAction.scale(to: 0.8, duration: 0.2)
            let changetexture = SKAction.run {
                self.Heart2.texture = SKTexture(imageNamed: "emptyHeartv2")
            }
            let sequence = SKAction.sequence([scaleUp, scaleDown, changetexture])
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            Heart2.run(sequence)

        }
        else if lives == 1{
            lives -= 1
            let scaleUp = SKAction.scale(to: 2.5, duration: 0.2)
            let scaleDown = SKAction.scale(to: 0.8, duration: 0.2)
            let changetexture = SKAction.run {
                self.Heart3.texture = SKTexture(imageNamed: "emptyHeartv2")
            }
            let sequence = SKAction.sequence([scaleUp, scaleDown, changetexture])
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            Heart3.run(sequence)

        }
        
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
        
        self.enumerateChildNodes(withName: "Enemy"){
            enemy, stop in
            enemy.removeAllActions()
        }
        
        self.enumerateChildNodes(withName: "Asteroid"){
            enemy, stop in
            enemy.removeAllActions()
        }
        
        self.enumerateChildNodes(withName: "Boost"){
            enemy, stop in
            enemy.removeAllActions()
        }
        self.enumerateChildNodes(withName: "GoldAsteroid"){
            enemy, stop in
            enemy.removeAllActions()
        }
        self.enumerateChildNodes(withName: "ROID"){
            enemy, stop in
            enemy.removeAllActions()
        }
        self.enumerateChildNodes(withName: "BlueDiamond"){
            enemy, stop in
            enemy.removeAllActions()
        }
        self.enumerateChildNodes(withName: "DoubleXP"){
            enemy, stop in
            enemy.removeAllActions()
        }
        
        let ChangeSceneAction = SKAction.run(changeScene)
        let waitForChange = SKAction.wait(forDuration: 1)
        let sequence = SKAction.sequence([waitForChange, ChangeSceneAction])
        self.run(sequence)
    }
    
    func changeScene(){
        let destination = GameOverScene(size:self.size)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        if currentGameState == gameState.DuringGame{
        ShootBullet()
        }
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
        enemy.physicsBody!.collisionBitMask = PhysicsCatergories.Bullet
        enemy.physicsBody!.contactTestBitMask = PhysicsCatergories.Player | PhysicsCatergories.Bullet
        
    }
    
    func EnemySpawner(){
        let randomXStart = CGFloat.random(in: gameArea.minX..<gameArea.maxX)
        let randomXEnd = CGFloat.random(in: gameArea.minX..<gameArea.maxX)
        let randomXStartExtra = CGFloat.random(in: gameArea.minX..<gameArea.maxX)
        let randomXEndExtra = CGFloat.random(in: gameArea.minX..<gameArea.maxX)
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let startPointExtra = CGPoint(x: randomXStartExtra, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        let endPointExtra = CGPoint(x: randomXEndExtra, y: -self.size.height * 0.2)
        let EnemyDecider = Int.random(in: 1..<8)
        let Lucky5 = Int.random(in: 1..<6)
        if EnemyDecider == 1{
            createEnemy(image: "E1", name: "Enemy", category: PhysicsCatergories.Enemy)
        }
        if EnemyDecider == 2{
            createEnemy(image: "RocketFlames1", name: "Enemy", category: PhysicsCatergories.Enemy)
        }
        if EnemyDecider == 3{
            createEnemy(image: "Asteroid", name: "Asteroid", category: PhysicsCatergories.Asteroid)
        }
        if EnemyDecider == 4{
            let Lucky = Int.random(in: 1..<4)
            if Lucky == 3{
                createEnemy(image: "BoostCoin", name: "Boost", category: PhysicsCatergories.GoldCoin)
            }else{
                createEnemy(image: "Asteroid", name: "Asteroid", category: PhysicsCatergories.Asteroid)
            }
        }
        if EnemyDecider == 5{
            if Lucky5 == 2{
                createEnemy(image: "Blue1", name: "BlueDiamond", category: PhysicsCatergories.BlueDiamond)
                extraEnemy = SKSpriteNode(imageNamed: "E1")
                extraEnemy.name = "Enemy"
                extraEnemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
                extraEnemy.physicsBody!.affectedByGravity = false
                extraEnemy.physicsBody!.categoryBitMask = PhysicsCatergories.Enemy
                extraEnemy.physicsBody!.collisionBitMask = PhysicsCatergories.Bullet
                extraEnemy.physicsBody!.contactTestBitMask = PhysicsCatergories.Player | PhysicsCatergories.Bullet
                extraEnemy.position = startPointExtra
                extraEnemy.zPosition = 1
                self.addChild(extraEnemy)
            }
            else{
                createEnemy(image: "GoldAsteroid", name: "GoldAsteroid", category: PhysicsCatergories.GoldAsteroid)
            }
        }
        if EnemyDecider == 6{
            createEnemy(image: "GoldAsteroid", name: "GoldAsteroid", category: PhysicsCatergories.GoldAsteroid)
            extraEnemy = SKSpriteNode(imageNamed: "E1")
            extraEnemy.name = "Enemy"
            extraEnemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
            extraEnemy.physicsBody!.affectedByGravity = false
            extraEnemy.physicsBody!.categoryBitMask = PhysicsCatergories.Enemy
            extraEnemy.physicsBody!.collisionBitMask = PhysicsCatergories.Bullet
            extraEnemy.physicsBody!.contactTestBitMask = PhysicsCatergories.Player | PhysicsCatergories.Bullet
            extraEnemy.position = startPointExtra
            extraEnemy.zPosition = 1
            self.addChild(extraEnemy)
        }
        if EnemyDecider == 7{
            let Lucky = Int.random(in: 1..<4)
            if Lucky == 3{
                createEnemy(image: "PurpleXP1", name: "DoubleXP", category: PhysicsCatergories.XPCoin)
            }else{
                createEnemy(image: "GoldAsteroid", name: "Asteroid", category: PhysicsCatergories.GoldAsteroid)
            }
        }
        
        enemy.position = startPoint
        enemy.zPosition = 2
        self.addChild(enemy)
        let anim = SKAction.animate(with: EnemyTextureArray, timePerFrame: 0.1)
        let redAnimForever = SKAction.repeatForever(anim)
        
        let aim = SKAction.animate(with: EnemyBlueTextureArray, timePerFrame: 0.1)
        let blueAnimForever = SKAction.repeatForever(aim)
        
        let diffXExtra = endPointExtra.x - startPointExtra.x
        let diffYExtra = endPointExtra.y - startPointExtra.y
        let amount2RotateExtra = atan2(diffYExtra, diffXExtra)
        
        
        let diffX = endPoint.x - startPoint.x
        let diffY = endPoint.y - startPoint.y
        let amount2Rotate = atan2(diffY, diffX)
        enemy.zRotation = amount2Rotate
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 2)
        let moveEnemyExtra = SKAction.move(to: endPointExtra, duration: 2.2)
        let rotate = SKAction.rotate(byAngle: 5, duration: 1)
        let wait = SKAction.wait(forDuration: 0.4)
        let rotation = SKAction.repeatForever(rotate)
        let deleteEnemy = SKAction.removeFromParent()
        let wellDoneSoldier = SKAction.run(loselives)
        let moveAndRemove = SKAction.sequence([moveEnemy, deleteEnemy])
        let moveAndRemoveandLive = SKAction.sequence([moveEnemy, deleteEnemy, wellDoneSoldier])
        let moveAndRemoveandLiveExtra = SKAction.sequence([moveEnemyExtra, deleteEnemy, wellDoneSoldier])
        let waitMoveRemove = SKAction.sequence([wait, moveEnemyExtra, deleteEnemy])
        let AsteroidSequence = SKAction.group([rotation, moveAndRemove])
        let AsteroidSequenceExtra = SKAction.group([rotation, waitMoveRemove])
        let RedEnemySequence = SKAction.group([redAnimForever, moveAndRemoveandLive])
        let BlueEnemySequence = SKAction.group([blueAnimForever, moveAndRemoveandLive])
        let RedEnemySequenceExtra = SKAction.group([ redAnimForever, moveAndRemoveandLiveExtra])
        let BlueEnemySequenceExtra = SKAction.group([ blueAnimForever, moveAndRemoveandLiveExtra])
        
        if EnemyDecider == 1{
            enemy.run(RedEnemySequence)
        }
        else if EnemyDecider == 2{
            enemy.run(BlueEnemySequence)
        }
        else if EnemyDecider == 5 && Lucky5 == 2{
            extraEnemy.zRotation = amount2RotateExtra
            extraEnemy.run(RedEnemySequenceExtra)
            enemy.run(AsteroidSequenceExtra)

        }
        else if EnemyDecider == 6{
            extraEnemy.zRotation = amount2RotateExtra
            extraEnemy.run(BlueEnemySequenceExtra)
            enemy.run(AsteroidSequenceExtra)
        }
        else{enemy.run(AsteroidSequence)}
    }
    
    func startNewLevel(){
        
        levelNumber += 1
        
        if self.action(forKey: "SpawningEnemies") != nil{
            self.removeAction(forKey: "SpawningEnemies")
        }
        
        var levelDuration = TimeInterval()
        
        switch levelNumber {
        case 1: levelDuration = 1.1
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
    
    // Function called when 2 physics bodies make contact
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        let boostxpback = SKAction.animate(with: BoostedDoublePointsBackgroundTextureArray, timePerFrame: 0.02)
        let boostedXPback4eva = SKAction.repeatForever(boostxpback)
        
        let boostback = SKAction.animate(with: BoostedBackgroundTextureArray, timePerFrame: 0.02)
        let boostback4eva = SKAction.repeatForever(boostback)
        
        let xpback = SKAction.animate(with: DoublePointsBackgroundTextureArray, timePerFrame: 0.02)
        let xpback4eva = SKAction.repeatForever(xpback)
        
        let lost = SKAction.animate(with: LostlifeTextureArray, timePerFrame: 0.1)
        let lostrep = SKAction.repeat(lost, count: 2)
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            body1 = contact.bodyA
            body2 = contact.bodyB
        }else{
            body1 = contact.bodyB
            body2 = contact.bodyA
        }

        
        // If the player hits the enemy
        
        if body1.categoryBitMask == PhysicsCatergories.Player && body2.categoryBitMask == PhysicsCatergories.Enemy{
            
            if CurrentRocketMode == RocketMode.BoostedDoubleXP{
                if body2.node != nil{Explode(explodeposition: body2.node!.position, image: "explosion1red")}
                body2.node?.removeFromParent()
                addScore(number: 2)
            }
            else if CurrentRocketMode == RocketMode.DoubleXP{
                if body1.node != nil{Explode(explodeposition: body1.node!.position, image: "explosion1red")}
                if body2.node != nil{Explode(explodeposition: body2.node!.position, image: "explosion1red")}

                body2.node?.removeFromParent()
                
                player.run(lostrep)
                
                loselives()
            }
            else if CurrentRocketMode == RocketMode.Boosted{
                if body2.node != nil{Explode(explodeposition: body2.node!.position, image: "explosion1red")}
                body2.node?.removeFromParent()
                addScore(number: 1)
            }
            else if CurrentRocketMode == RocketMode.Normal{
                if body1.node != nil{Explode(explodeposition: body1.node!.position, image: "explosion1red")}
                if body2.node != nil{Explode(explodeposition: body2.node!.position, image: "explosion1red")}

                body2.node?.removeFromParent()
                
                player.run(lostrep)
                
                loselives()
            }
        }
        
        // If the player runs into the gold coin
        
        else if body1.categoryBitMask == PhysicsCatergories.Player && body2.categoryBitMask == PhysicsCatergories.GoldCoin{
            
            // Since we hit the gold coin we want to give a bonus life and invunerable travel travel
            // My thought process is to call a 30 second timer in which we set the rocketmode to boosted.
            if CurrentRocketMode == RocketMode.DoubleXP{
                CurrentRocketMode = RocketMode.BoostedDoubleXP
                background.removeAction(forKey: "DoubleBack")
                background.run(boostedXPback4eva, withKey: "DoubleBoostBack")
                count = 10
            }
            else if CurrentRocketMode == RocketMode.Normal{
                CurrentRocketMode = RocketMode.Boosted
                background.removeAction(forKey: "StanBack")
                background.run(boostback4eva, withKey: "BoostBack")
                count = 10
            }
            body2.node?.removeFromParent()
            
        }
        
        // If the player runs into 2x coin
        
        else if body1.categoryBitMask == PhysicsCatergories.Player && body2.categoryBitMask == PhysicsCatergories.XPCoin{
            
            // Since we hit the 2X coin we want to give doublepoints
            // My thought process is to call a 30 second timer in which we set the rocketmode to boosted.
            if CurrentRocketMode == RocketMode.Boosted{
                CurrentRocketMode = RocketMode.BoostedDoubleXP
                background.removeAction(forKey: "DoubleBack")
                background.run(boostedXPback4eva, withKey: "DoubleBoostBack")
                count = 10
            }
            else if CurrentRocketMode == RocketMode.Normal{
                CurrentRocketMode = RocketMode.DoubleXP
                background.removeAction(forKey: "StanBack")
                background.run(xpback4eva, withKey: "BoostBack")
                count = 10
            }
            body2.node?.removeFromParent()
        }
        
        // If the bullet hits the gold coin
        
        else if body1.categoryBitMask == PhysicsCatergories.Bullet && body2.categoryBitMask == PhysicsCatergories.GoldCoin{
            if body2.node != nil{
                
                if body2.node!.position.y > self.size.height{
                    return
                }else{
                    Explode(explodeposition: body2.node!.position, image: "explosion1gold")
                    body2.node?.removeFromParent()
                }
        }
        }
        
        // Bullet hits 2X Coin
        
        else if body1.categoryBitMask == PhysicsCatergories.Bullet && body2.categoryBitMask == PhysicsCatergories.XPCoin{
            if body2.node != nil{
                
                if body2.node!.position.y > self.size.height{
                    return
                }else{
                    Explode(explodeposition: body2.node!.position, image: "explosion1purple")
                    body2.node?.removeFromParent()
                }
        }
        }
        
        // If the bullet hits the enemy
        else if body1.categoryBitMask == PhysicsCatergories.Bullet && body2.categoryBitMask == PhysicsCatergories.Enemy{
            
            if body2.node != nil{
                // Check wether the enemy is on screen when the bullet makes contact
                if body2.node!.position.y > self.size.height{
                    return
                }else{
                    // we know this is on the screen so we want to show an explosion
                    if CurrentRocketMode == RocketMode.BoostedDoubleXP{
                        Explode(explodeposition: body2.node!.position, image: "explosion1red")
                        addScore(number: 2)
                    }
                    else if CurrentRocketMode == RocketMode.DoubleXP{
                        Explode(explodeposition: body2.node!.position, image: "explosion1red")
                        addScore(number: 2)
                    }
                    else if CurrentRocketMode == RocketMode.Boosted{
                        Explode(explodeposition: body2.node!.position, image: "explosion1red")
                        addScore(number: 1)
                    }
                    else if CurrentRocketMode == RocketMode.Normal{
                        Explode(explodeposition: body2.node!.position, image: "explosion1red")
                        addScore(number: 1)
                    }
                }
                body1.node?.removeFromParent()
                body2.node?.removeFromParent()
            }
        }
        
        // If the bullet hits the asteroid
        else if body1.categoryBitMask == PhysicsCatergories.Bullet && body2.categoryBitMask == PhysicsCatergories.Asteroid{
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
        
        // If the bullet hits the GOLD asteroid
        else if body1.categoryBitMask == PhysicsCatergories.Bullet && body2.categoryBitMask == PhysicsCatergories.GoldAsteroid{
            if body2.node != nil{
                // Check wether the enemy is on screen when the bullet makes contact
                if body2.node!.position.y > self.size.height{
                    return
                }else{
                    let startofFragmentation = body2.node!.position
                    Explode(explodeposition: body2.node!.position, image: "explosion1purple")
                    
                    FragmentGoldAsteroid(FragPosition: startofFragmentation)
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
                addScore(number: 2)
            }
            else if CurrentRocketMode == RocketMode.DoubleXP{
                if body1.node != nil{Explode(explodeposition: body1.node!.position, image: "explosion1red")}
                if body2.node != nil{Explode(explodeposition: body2.node!.position, image: "explosion1red")}
                
                body2.node?.removeFromParent()
                player.run(lostrep)
                loselives()
            }
            else if CurrentRocketMode == RocketMode.Boosted{
                if body2.node != nil{Explode(explodeposition: body2.node!.position, image: "explosion1red")}
                body2.node?.removeFromParent()
                addScore(number: 1)
            }
            else if CurrentRocketMode == RocketMode.Normal{
                if body1.node != nil{Explode(explodeposition: body1.node!.position, image: "explosion1red")}
                if body2.node != nil{Explode(explodeposition: body2.node!.position, image: "explosion1red")}

                body2.node?.removeFromParent()
                player.run(lostrep)
                loselives()
            }
        }
        
        // If the player hits the GOLD asteroid
        else if body1.categoryBitMask == PhysicsCatergories.Player && body2.categoryBitMask == PhysicsCatergories.GoldAsteroid{
            
            if CurrentRocketMode == RocketMode.BoostedDoubleXP{
                if body2.node != nil{Explode(explodeposition: body2.node!.position, image: "explosion1blue")}
                body2.node?.removeFromParent()
                addScore(number: 10)
            }
            else if CurrentRocketMode == RocketMode.DoubleXP{
                if body1.node != nil{Explode(explodeposition: body1.node!.position, image: "explosion1gold")}
                if body2.node != nil{Explode(explodeposition: body2.node!.position, image: "explosion1green")}

                body2.node?.removeFromParent()
                player.run(lostrep)
                loselives()
            }
            else if CurrentRocketMode == RocketMode.Boosted{
                if body2.node != nil{Explode(explodeposition: body2.node!.position, image: "explosion1red")}
                body2.node?.removeFromParent()
                addScore(number: 5)
            }
            else if CurrentRocketMode == RocketMode.Normal{
                if body1.node != nil{Explode(explodeposition: body1.node!.position, image: "explosion1gold")}
                if body2.node != nil{Explode(explodeposition: body2.node!.position, image: "explosion1purple")}

                body2.node?.removeFromParent()
                player.run(lostrep)
                loselives()
            }
        }
        
        // If the player hits an asteroid fragment
        else if body1.categoryBitMask == PhysicsCatergories.Player && body2.categoryBitMask == PhysicsCatergories.AsteroidFragment{
            
            if CurrentRocketMode == RocketMode.BoostedDoubleXP{
                if body2.node != nil{Explode(explodeposition: body2.node!.position, image: "explosion1red")}
                body2.node?.removeFromParent()
                addScore(number: 2)
            }
            else if CurrentRocketMode == RocketMode.DoubleXP{
                if body1.node != nil{Explode(explodeposition: body1.node!.position, image: "explosion1red")}
                if body2.node != nil{Explode(explodeposition: body2.node!.position, image: "explosion1red")}

                body2.node?.removeFromParent()
                player.run(lostrep)
                loselives()
            }
            else if CurrentRocketMode == RocketMode.Boosted{
                if body2.node != nil{Explode(explodeposition: body2.node!.position, image: "explosion1red")}
                body2.node?.removeFromParent()
                addScore(number: 1)
            }
            else if CurrentRocketMode == RocketMode.Normal{
                if body1.node != nil{Explode(explodeposition: body1.node!.position,  image: "explosion1red")}
                if body2.node != nil{Explode(explodeposition: body2.node!.position, image: "explosion1red")}

                body2.node?.removeFromParent()
                player.run(lostrep)
                loselives()
            }
        }
        
        // If the player hits a Purple diamond
        
        else if body1.categoryBitMask == PhysicsCatergories.Player && body2.categoryBitMask == PhysicsCatergories.PurpleDiamond{
            
            if CurrentRocketMode == RocketMode.BoostedDoubleXP{
                body2.node?.removeFromParent()
                addScore(number: 30)
            }
            else if CurrentRocketMode == RocketMode.DoubleXP{
                body2.node?.removeFromParent()
                addScore(number: 30)
            }
            else if CurrentRocketMode == RocketMode.Boosted{
                body2.node?.removeFromParent()
                addScore(number: 15)
            }
            else if CurrentRocketMode == RocketMode.Normal{
                body2.node?.removeFromParent()
                addScore(number: 15)
            }
            }
        
        // If the player hits the blue diamond
        
        else if body1.categoryBitMask == PhysicsCatergories.Player && body2.categoryBitMask == PhysicsCatergories.BlueDiamond{
            
            if CurrentRocketMode == RocketMode.BoostedDoubleXP{
                body2.node?.removeFromParent()
                addScore(number: 40)
            }
            else if CurrentRocketMode == RocketMode.DoubleXP{
                body2.node?.removeFromParent()
                addScore(number: 40)
            }
            else if CurrentRocketMode == RocketMode.Boosted{
                body2.node?.removeFromParent()
                addScore(number: 20)
            }
            else if CurrentRocketMode == RocketMode.Normal{
                body2.node?.removeFromParent()
                addScore(number: 20)
            }
            }
        
        // If the player hits the green diamond
        
        else if body1.categoryBitMask == PhysicsCatergories.Player && body2.categoryBitMask == PhysicsCatergories.GreenDiamond{
            
            if CurrentRocketMode == RocketMode.BoostedDoubleXP{
                body2.node?.removeFromParent()
                addScore(number: 30)
            }
            else if CurrentRocketMode == RocketMode.DoubleXP{
                body2.node?.removeFromParent()
                addScore(number: 30)
            }
            else if CurrentRocketMode == RocketMode.Boosted{
                body2.node?.removeFromParent()
                addScore(number: 15)
            }
            else if CurrentRocketMode == RocketMode.Normal{
                body2.node?.removeFromParent()
                addScore(number: 15)
            }
            }
        
        
        // If a bullet hits a purple diamond
        
        else if body1.categoryBitMask == PhysicsCatergories.Bullet && body2.categoryBitMask == PhysicsCatergories.PurpleDiamond{
            if body2.node != nil{Explode(explodeposition: body2.node!.position, image: "explosion1purple")}
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            }
        
        // If a bullet hits a green diamond
        
        else if body1.categoryBitMask == PhysicsCatergories.Bullet && body2.categoryBitMask == PhysicsCatergories.BlueDiamond{
            if body2.node != nil{Explode(explodeposition: body2.node!.position, image: "explosion1blue")}
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            }
        
        // If a bullet hits a blue diamond
        
        else if body1.categoryBitMask == PhysicsCatergories.Bullet && body2.categoryBitMask == PhysicsCatergories.GreenDiamond{
            if body2.node != nil{Explode(explodeposition: body2.node!.position, image: "explosion1green")}
            body1.node?.removeFromParent()
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
