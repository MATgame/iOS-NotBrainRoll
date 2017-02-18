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
    var organDiction = Dictionary<String, SKSpriteNode>()
    var organList = ["brain", "kidney", "heart", "liver", "lung"]
    let sceneEdgeGroup : UInt32 = 0b101
    let organGroup : UInt32 = 0b001
    let liverShape = SKShapeNode()
    
    override func didMove(to view: SKView) {
        let borderBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: size.width, height: 1))
        self.physicsBody = borderBody
        self.physicsBody?.categoryBitMask = sceneEdgeGroup
        self.physicsBody?.friction = 0.7
        
        let wait = SKAction.wait(forDuration: 3, withRange: 2)
        let spawn = SKAction.run {
            let random = arc4random_uniform(5)
            let newOrgan = SKSpriteNode(imageNamed: self.organList[Int(random)])
            
            newOrgan.position = CGPoint(x: 0, y: self.size.height/2)
            newOrgan.physicsBody = SKPhysicsBody(circleOfRadius: 20)
            newOrgan.physicsBody?.categoryBitMask = self.organGroup
            newOrgan.physicsBody?.friction = 8
            newOrgan.physicsBody?.angularDamping = 10
            newOrgan.physicsBody?.restitution = 0.3
            newOrgan.physicsBody?.velocity = CGVector(dx: 200, dy: 500)
            newOrgan.physicsBody?.affectedByGravity = true
            
            self.addChild(newOrgan)
            
        }
        
        let sequence = SKAction.sequence([wait, spawn])
        self.run(SKAction.repeatForever(sequence))
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
            if organDiction[body.node!.name!] != nil {
                print("Began touch on organ")
                isFingerOnOrgan = true
            }
            
        }
        /*if let body = physicsWorld.body(at: touchLocation) {
            if body.node!.name == "organ" {
                    print("Began touch on organ")
                isFingerOnOrgan = true
            }
        
        }*/
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
