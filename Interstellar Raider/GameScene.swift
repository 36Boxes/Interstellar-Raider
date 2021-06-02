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
    
//    let gameArea: CGRect
//    
//    override init(size: CGSize){
//        
//        // to have this work nicely on most devices i could maybe identify the device and then have the correct aspect ratio
//        let maxAspectRatio: CGFloat = 19.5/9
//        let gameAreaWidth = size.height / maxAspectRatio
//        let margin = (size.width - gameAreaWidth) / 2
//        gameArea = CGRect(x: margin, y: 0, width: gameAreaWidth, height: size.height)
//        super.init(size:size)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func didMove(to view: SKView) {
        
        userScore = 0
        
        self.physicsWorld.contactDelegate = self
        loadTextures()
        
        background.size = CGSize (width: frame.maxX, height: frame.maxY)
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
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
        
        for i in 1...EnemyTextureAtlas.textureNames.count{
            let TexName = "E\(i).png"
            EnemyTextureArray.append(SKTexture(imageNamed: TexName))
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
