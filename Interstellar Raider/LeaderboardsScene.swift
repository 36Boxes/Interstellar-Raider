//
//  LeaderboardsScene.swift
//  Interstellar Raider
//
//  Created by Josh Manik on 02/06/2021.
//

import Foundation
import SpriteKit
import UIKit

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
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return s_ores.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "leaderboardcell", for: indexPath) as!
            CustomTableViewCell
        let score = s_ores[indexPath.row]
        let name = names[indexPath.row]
        let rank = ranks[indexPath.row]
        
        cell.name.text = name
        cell.rank.text = String(rank)
        cell.score.text = String(score)
        
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section \(section)"
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }
}

class LeaderboardsScene: SKScene{
    var gameTableView = GameRoomTableView()
    private var label : SKLabelNode?
    override func didMove(to view: SKView) {
        // Table setup
        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        gameTableView.register(nib, forCellReuseIdentifier: "leaderboardcell")
        gameTableView.frame=CGRect(x:20,y:50,width:280,height:200)
        self.scene?.view?.addSubview(gameTableView)
        gameTableView.reloadData()
    }
}
