//
//  TutorialScene1.swift
//  Interstellar Raider
//
//  Created by Josh Manik on 04/06/2021.
//

import Foundation
import SpriteKit
import GameKit

class TutorialScene1: SKScene {
    
    // The various different textures needed for animation
    
    var BackgroundTextureAtlas = SKTextureAtlas()
    var BackgroundTextureArray: [SKTexture] = []
    
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
    
    override func didMove(to view: SKView) {
        let BackLabel = SKSpriteNode(imageNamed: "goBack")
        BackLabel.name = "Back"
        BackLabel.size = CGSize(width: 100, height: 100)
        BackLabel.position = CGPoint(x:self.size.width * 0.23, y: self.size.height * 0.9)
        BackLabel.zPosition = 100
        self.addChild(BackLabel)
        
        let ReloadLabel = SKSpriteNode(imageNamed: "Refresh")
        ReloadLabel.name = "Refresh"
        ReloadLabel.size = CGSize(width: 100, height: 100)
        ReloadLabel.position = CGPoint(x: self.size.width * 0.76, y: self.size.height * 0.9)
        ReloadLabel.zPosition = 100
        self.addChild(ReloadLabel)
    }
    
}
