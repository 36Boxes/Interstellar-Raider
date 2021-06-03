//
//  LeaderboardsScene.swift
//  Interstellar Raider
//
//  Created by Josh Manik on 02/06/2021.
//

import Foundation
import SpriteKit
import UIKit

var s_ores = [Int64()]
var names = [String()]
var ranks = [Int()]

class GameRoomTableView: UITableView,UITableViewDelegate,UITableViewDataSource {
    var s_ores = [1,2,3,4,5,6]
    var names = ["j", "j", "j", "j", "j", "j"]
    var ranks = [1,2,3,4,5,6]
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.delegate = self
        self.dataSource = self
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return s_ores.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "leaderboardcell", for: indexPath) as!
            CustomTableViewCell
        if indexPath.row == 0{
            cell.name.text = "Score"
            cell.rank.text = "Rank"
            cell.score.text = "Username"
            
            return cell
        }
        let score = s_ores[indexPath.row]
        let name = names[indexPath.row]
        let rank = ranks[indexPath.row]
        
        cell.name.text = String(score)
        cell.rank.text = String(rank)
        cell.score.text = name
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }
}

class LeaderboardsScene: SKScene{
    var gameTableView = GameRoomTableView()
    let background = SKSpriteNode(imageNamed: "glitter-universe-1-1")
    
    var BackgroundTextureAtlas = SKTextureAtlas()
    var BackgroundTextureArray: [SKTexture] = []
    
    override func didMove(to view: SKView) {
        // Table setup
        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        gameTableView.register(nib, forCellReuseIdentifier: "leaderboardcell")
        gameTableView.translatesAutoresizingMaskIntoConstraints = false
        self.scene?.view?.addSubview(gameTableView)
        NSLayoutConstraint.activate([
        gameTableView.centerXAnchor.constraint(equalTo: self.view!.centerXAnchor),
        gameTableView.centerYAnchor.constraint(equalTo: self.view!.centerYAnchor, constant: 70),
        gameTableView.widthAnchor.constraint(equalToConstant: 350),
            gameTableView.heightAnchor.constraint(equalToConstant: self.frame.height/3.5)
                                        ])
        gameTableView.reloadData()
        
        loadTextures()
        
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.size.width = self.size.width
        background.size.height = self.size.height
        background.zPosition = 0
        self.addChild(background)
        let anim =  SKAction.animate(with: BackgroundTextureArray, timePerFrame: 0.02)
        let anim4eva = SKAction.repeatForever(anim)
        background.run(anim4eva, withKey: "StanBack")
        
        let GameName = SKLabelNode(fontNamed: "ADAM.CGPRO")
        GameName.text = "Leaderboards"
        GameName.fontSize = 80
        GameName.fontColor = SKColor.white
        GameName.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.8)
        GameName.zPosition = 1
        self.addChild(GameName)
        
        let BackLabel = SKLabelNode(fontNamed: "ADAM.CGPRO")
        BackLabel.text = "  Back"
        BackLabel.fontSize = 50
        BackLabel.fontColor = SKColor.white
        BackLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        BackLabel.position = CGPoint(x:self.size.width * 0.20, y: self.size.height * 0.9)
        BackLabel.zPosition = 100
        self.addChild(BackLabel)
        
        let ReloadLabel = SKLabelNode(fontNamed: "ADAM.CGPRO")
        ReloadLabel.text = "Reload Table"
        ReloadLabel.fontSize = 50
        ReloadLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        ReloadLabel.position = CGPoint(x: self.size.width * 0.8, y: self.size.height * 0.9)
        ReloadLabel.zPosition = 100
        self.addChild(ReloadLabel)
    }
    
    func loadTextures(){


        BackgroundTextureAtlas = SKTextureAtlas(named: "BackgroundImages.atlas")
        
        for p in 1...BackgroundTextureAtlas.textureNames.count{
            let texture = "glitter-universe-1-\(p).png"
            BackgroundTextureArray.append(SKTexture(imageNamed: texture))
        }
        
    }
    
    
}
