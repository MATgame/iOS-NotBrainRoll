//
//  GameScene.swift
//  MATsurgery
//
//  Created by MAT on 2017-02-10.
//  Copyright © 2017 MattAmirTom. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    struct PhysicsCategory {
        static let None     : UInt32 = 0
        static let All      : UInt32 = UInt32.max
        static let Edge     : UInt32 = 0b1
        static let Organ     : UInt32 = 0b10
    }
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    var isFingerOnOrgan = false
    var gameOngoing = true
    var touchLocation = CGPoint()
    var organList = ["heart", "kidney", "liver", "brain", "lung"]
    var random = Int()
    var shape = SKPhysicsBody()
    var touchedOrgans = [SKNode]()
    var score = Int()
    var numOrgans = Int()
    var gravityOn = true
    //545, 312   501.564, 289.835 132.871, 60.331
    let deleteLocation = CGPoint(x: 545, y: 312)
    var nodesToRemove = [SKNode]()
    var scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    let hand = SKSpriteNode(imageNamed: "hands")
    
    override func didMove(to view: SKView) {
        scoreLabel.text = String(score)
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height-30)
        scoreLabel.zPosition = 1
        addChild(scoreLabel)
        
        hand.position = CGPoint(x: 501.564, y: 289.835)
        hand.size = CGSize(width: 132.871, height: 60.331)
        addChild(hand)
        
        score = 0
        
        physicsWorld.contactDelegate = self
        let borderBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: -100, y: 0, width: size.width+100, height: size.height+250))
        borderBody.categoryBitMask = PhysicsCategory.Edge
        borderBody.contactTestBitMask = PhysicsCategory.Organ
        borderBody.collisionBitMask = PhysicsCategory.None
        self.physicsBody = borderBody
        self.physicsBody?.friction = 0.3
        
        let wait = SKAction.wait(forDuration: 3, withRange: 2)
        let spawn = SKAction.run {
            self.random = Int(arc4random_uniform(5))
            let radius = 30 - (5-self.random)
            let newOrgan = SKSpriteNode(imageNamed: self.organList[self.random])
            newOrgan.name = "Organ"
            newOrgan.position = CGPoint(x: -20, y: self.size.height/2+20)
            newOrgan.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(radius))
            newOrgan.physicsBody?.categoryBitMask = PhysicsCategory.Organ
            newOrgan.physicsBody?.contactTestBitMask = PhysicsCategory.Edge
            newOrgan.physicsBody?.collisionBitMask = PhysicsCategory.None
            newOrgan.physicsBody?.usesPreciseCollisionDetection = true
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
        self.run(SKAction.repeatForever(sequence), withKey: "spawnOrgans")
    }
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if((firstBody.categoryBitMask & PhysicsCategory.Edge != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Organ != 0)) {
            if let organ = secondBody.node as? SKSpriteNode {
                killOrgan(organ: organ)
            }
        }
    }
    
    func killOrgan(organ: SKSpriteNode) {
        isFingerOnOrgan = false
        gameOngoing = false
        //end current game - show score/ restart button
        run(SKAction.sequence([
            SKAction.run() {
                print("organ-edge contact")
                self.removeAction(forKey: "spawnOrgans")
                organ.texture = SKTexture(imageNamed: "blood")
                organ.size = CGSize(width: 200, height: 200)
                organ.removeAction(forKey: "rotateOrgan")
                organ.physicsBody?.angularVelocity = 0
                organ.physicsBody?.allowsRotation = false
                organ.zRotation = 0
                organ.physicsBody?.velocity = CGVector.zero
                organ.physicsBody?.affectedByGravity = false
            },
            SKAction.wait(forDuration: 3.0),
            SKAction.run() {
                organ.removeFromParent() // change the image to an explosion of blood instead
                let reveal = SKTransition.doorsCloseHorizontal(withDuration: 0.75)
                let gameOverScene = GameOverScene(size: self.size, score: self.score)
                self.view?.presentScene(gameOverScene, transition: reveal)
            }
            ]))
        
    }
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameOngoing {
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
                if touchedOrgans[numOrgans - 1].name == "Organ" {
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
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isFingerOnOrgan && gameOngoing {
            let touch = touches.first
            touchLocation = touch!.location(in: self)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isFingerOnOrgan && gameOngoing {
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
        if gameOngoing {
            nodesToRemove = self.nodes(at: deleteLocation)
            if nodesToRemove.count > 0 {
                for node in nodesToRemove {
                    if node.name == "Organ" {
                        node.removeFromParent()
                        score += 1
                        print("score: " + String(score))
                        scoreLabel.text = String(score)
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
}
