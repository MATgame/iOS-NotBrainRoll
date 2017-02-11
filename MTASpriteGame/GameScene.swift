//
//  GameScene.swift
//  MATsurgery
//
//  Created by MAT on 2017-02-10.
//  Copyright © 2017 MattAmirTom. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    var isFingerOnOrgan = false
    var touchLocation = CGPoint()
    
    override func didMove(to view: SKView) {
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        touchLocation = touch!.location(in:self)
        
        if let body = physicsWorld.body(at: touchLocation) {
            if body.node!.name == "organ" {
                    print("Began touch on organ")
                isFingerOnOrgan = true
            }
        
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isFingerOnOrgan {
            let touch = touches.first
            touchLocation = touch!.location(in: self)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isFingerOnOrgan = false
        childNode(withName: "organ")!.physicsBody?.affectedByGravity = true
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    override func update(_ currentTime: CFTimeInterval) {
        // Called before each frame is rendered
        if isFingerOnOrgan {
            if childNode(withName: "organ")!.physicsBody?.affectedByGravity == true
            {
                childNode(withName: "organ")!.physicsBody?.affectedByGravity = false
                childNode(withName: "organ")!.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            }
            
            let organ = childNode(withName: "organ") as! SKSpriteNode
            organ.position = CGPoint(x: touchLocation.x, y: touchLocation.y)
        }
    }
}
