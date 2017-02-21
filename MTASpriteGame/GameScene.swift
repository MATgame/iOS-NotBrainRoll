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
    var organList = ["heart", "kidney", "liver", "brain", "lung"]
    var random = Int()
    var shape = SKPhysicsBody()
    var touchedOrgans = [SKNode]()
    var numOrgans = Int()
    var gravityOn = true
    //545, 312
    let deleteLocation = CGPoint(x: 545, y: 312)
    var nodesToRemove = [SKNode]()
    
    override func didMove(to view: SKView) {
        let borderBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: -30, y: 0, width: size.width+80, height: size.height+150))
        self.physicsBody = borderBody
        self.physicsBody?.friction = 0.3
        
        let wait = SKAction.wait(forDuration: 3, withRange: 2)
        let spawn = SKAction.run {
            self.random = Int(arc4random_uniform(5))
            let radius = 30 - (5-self.random)
            let newOrgan = SKSpriteNode(imageNamed: self.organList[self.random])
            newOrgan.position = CGPoint(x: -20, y: self.size.height/2+20)
            newOrgan.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(radius))
            newOrgan.physicsBody?.friction = 0.05
            newOrgan.physicsBody?.angularDamping = 0.3
            newOrgan.physicsBody?.restitution = 0.2
            newOrgan.physicsBody?.velocity = CGVector(dx: CGFloat(arc4random_uniform(300)+200), dy: CGFloat(arc4random_uniform(200)+400))
            newOrgan.physicsBody?.affectedByGravity = true
            
            let spawnRotation = SKAction.rotate(byAngle:CGFloat(-M_PI/2), duration:Double(arc4random_uniform(100)+100)/100.0)
            let repeatRotation = SKAction.repeat(spawnRotation, count: 2)
            newOrgan.run(repeatRotation, withKey:"rotateOrgan")
            
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
        touchedOrgans = self.nodes(at: touchLocation)
        if touchedOrgans.count > 0 {
            numOrgans = touchedOrgans.count
            if touchedOrgans[numOrgans - 1].name == "background" {
                print(touchedOrgans.popLast()?.name ?? "none")
            }
        }
        if touchedOrgans.count > 0 {
            numOrgans = touchedOrgans.count
            if touchedOrgans[numOrgans - 1].name == "hand" {
                print(touchedOrgans.popLast()?.name ?? "none")
            }
        }
        if touchedOrgans.count > 0 {
            numOrgans = touchedOrgans.count
            if touchedOrgans[numOrgans - 1].name == nil {
                isFingerOnOrgan = true
                touchedOrgans[numOrgans-1].removeAction(forKey: "rotateOrgan")
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
        if isFingerOnOrgan {
            isFingerOnOrgan = false
            touchedOrgans[numOrgans - 1].physicsBody?.affectedByGravity = true
        }
        /*for organ in touchedOrgans {
            organ.physicsBody?.affectedByGravity = true
        }*/
        
        //childNode(withName: "organ")!.physicsBody?.affectedByGravity = true
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    override func update(_ currentTime: CFTimeInterval) {
        nodesToRemove = self.nodes(at: deleteLocation)
        if nodesToRemove.count > 0 {
            for node in nodesToRemove {
                if node.name == nil {
                    node.removeFromParent()
                }
            }
        }
        // Called before each frame is rendered
        if isFingerOnOrgan {
            if gravityOn
            {
                touchedOrgans[numOrgans - 1].physicsBody?.affectedByGravity = false
                touchedOrgans[numOrgans - 1].physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                gravityOn = false
                /*for organ in touchedOrgans {
                    organ.physicsBody?.affectedByGravity = false
                }*/
                //childNode(withName: "organ")!.physicsBody?.affectedByGravity = false
                //childNode(withName: "organ")!.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            }
            let dt:CGFloat = 3.6/60.0
            let distance = CGVector(dx: touchLocation.x-touchedOrgans[numOrgans-1].position.x, dy: touchLocation.y-touchedOrgans[numOrgans-1].position.y)
            let velocity = CGVector(dx: distance.dx/dt, dy: distance.dy/dt)
            
            touchedOrgans[numOrgans - 1].position = CGPoint(x: touchLocation.x, y: touchLocation.y)
            
            touchedOrgans[numOrgans - 1].physicsBody?.velocity = velocity
            
            /*for organ in touchedOrgans {
                organ.position = CGPoint(x: touchLocation.x, y: touchLocation.y)
            }*/
            //let organ = childNode(withName: "organ") as! SKSpriteNode
            //organ.position = CGPoint(x: touchLocation.x, y: touchLocation.y)
        }
    }
}
