//
//  GameViewController.swift
//  Interstellar Raider
//
//  Created by Josh Manik on 27/05/2021.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let view = self.view as! SKView? {

               // Load the SKScene from 'GameScene.sks'

               let scene = HomeScene(size: CGSize(width: 1536, height: 2048))

                   // Set the scale mode to scale to fit the window

                   scene.scaleMode = .aspectFill
                   
                   // Present the scene

                   view.presentScene(scene)
               
               view.ignoresSiblingOrder = true
               
               view.showsFPS = false

               view.showsNodeCount = false
            
           }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
