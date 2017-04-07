//
//  GameOverScene.swift
//  MATsurgery
//
//  Created by Tom Nam on 2017-03-03.
//  Copyright © 2017 MattAmirTom. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class GameOverScene: SKScene {
    
    init(size:CGSize, score:Int) {
        super.init(size: size)
        
        let bg = SKSpriteNode(imageNamed: "bgdoc")
        bg.name = "background"
        bg.position = CGPoint(x: size.width/2, y: size.height/2)
        bg.zPosition = -3
        bg.size = CGSize(width: size.width, height: size.height)
        addChild(bg)
        
        let scoreMessage1 = "You helped save:"
        
        let label1 = SKLabelNode(fontNamed: "Chalkduster")
        label1.text = scoreMessage1
        label1.fontSize = 35
        label1.fontColor = SKColor.red
        label1.position = CGPoint(x: size.width/2, y: size.height/2+125)
        addChild(label1)
        
        let scoreMessage2 = "\(score) patients!"
        
        let label2 = SKLabelNode(fontNamed: "Chalkduster")
        label2.text = scoreMessage2
        label2.fontSize = 35
        label2.fontColor = SKColor.red
        label2.position = CGPoint(x: size.width/2, y: size.height/2+80)
        addChild(label2)
        
        let playAgainMessage = "tap to play again"
        
        let label3 = SKLabelNode(fontNamed: "Chalkduster")
        label3.text = playAgainMessage
        label3.fontSize = 15
        label3.fontColor = SKColor.red
        label3.position = CGPoint(x: size.width/2, y: 35)
        addChild(label3)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        restart()
    }
    
    func restart() {
        run(SKAction.sequence([
            SKAction.run() {
                let reveal = SKTransition.fade(with: UIColor.white, duration: 0.75)
                let scene = GameScene(size: self.size)
                self.view?.presentScene(scene, transition: reveal)
            }
        ]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
