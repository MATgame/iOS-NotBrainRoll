//
//  GameScene.swift
//  MATsurgery
//
//  Created by MAT on 2017-02-10.
//  Copyright © 2017 MattAmirTom. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    struct PhysicsCategory {
        static let None     : UInt32 = 0
        static let All      : UInt32 = UInt32.max
        static let Edge     : UInt32 = 0b1
        static let Hand     : UInt32 = 0b10
        static let Organ    : UInt32 = 0b100
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
    //545, 312   501.564, 289.835 132.871, 60.331
    let deleteLocation = CGPoint(x: 545, y: 312)
    var nodesToRemove = [SKNode]()
    var scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    let bg = SKSpriteNode(imageNamed: "bg")
    let hand = SKSpriteNode(imageNamed: "hands")
    var organTouchPlayer = AVAudioPlayer()
    var organDiePlayer = AVAudioPlayer()
    var organTouchSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "organTouch", ofType: "wav")!)
    var organDieSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "organDie", ofType: "wav")!)
    var organTouchTempo: Float!
    var organTouchVolume: Float!
    var positionToCompare: Int = 1
    var initTouchLocation = CGPoint()
    
    
    override func didMove(to view: SKView) {
        scoreLabel.text = String(score)
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = SKColor.red
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height-30)
        scoreLabel.zPosition = 1
        addChild(scoreLabel)
        
        bg.name = "background"
        bg.position = CGPoint(x: size.width/2, y: size.height/2)
        bg.zPosition = -3
        bg.size = CGSize(width: size.width, height: size.height)
        bg.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 132.871, height: 60.331))
        bg.physicsBody?.categoryBitMask = PhysicsCategory.None
        bg.physicsBody?.contactTestBitMask = PhysicsCategory.None
        bg.physicsBody?.collisionBitMask = PhysicsCategory.None
        bg.physicsBody?.affectedByGravity = false
        addChild(bg)
        
        hand.name = "Hand"
        hand.position = CGPoint(x: 501.564, y: 289.835)
        hand.size = CGSize(width: 132.871, height: 60.331)
        hand.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 132.871, height: 60.331))
        hand.physicsBody?.categoryBitMask = PhysicsCategory.Hand
        hand.physicsBody?.contactTestBitMask = PhysicsCategory.Organ
        hand.physicsBody?.collisionBitMask = PhysicsCategory.None
        hand.physicsBody?.affectedByGravity = false
        addChild(hand)
        
        score = 0
        
        physicsWorld.contactDelegate = self
        let borderBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: -100, y: 0, width: size.width+400, height: size.height+450))
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
            newOrgan.physicsBody?.contactTestBitMask = PhysicsCategory.Edge | PhysicsCategory.Hand
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
        
        do {
            try organTouchPlayer = AVAudioPlayer(contentsOf: organTouchSound as URL, fileTypeHint: "wav")
            organTouchPlayer.enableRate = true
            organTouchTempo = organTouchPlayer.rate
            organTouchVolume = organTouchPlayer.volume
            organTouchPlayer.prepareToPlay()
        } catch {
            print("error in preparing organ touched sound")
        }
        
        do {
            try organDiePlayer = AVAudioPlayer(contentsOf: organDieSound as URL, fileTypeHint: "wav")
            organDiePlayer.volume = organDiePlayer.volume / 3.5
            organTouchPlayer.prepareToPlay()
        } catch {
            print("error in preparing organ death sound")
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
        
        if((firstBody.categoryBitMask & PhysicsCategory.Hand != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Organ != 0)) {
            if  let possibleHand = firstBody.node as? SKSpriteNode,
                let organToSave = secondBody.node as? SKSpriteNode {
                saveOrgan(possibleHand: possibleHand, organ: organToSave)
            }
        }
        
        if((firstBody.categoryBitMask & PhysicsCategory.Edge != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Organ != 0)) {
            if let organToKill = secondBody.node as? SKSpriteNode {
                killOrgan(organ: organToKill)
            }
        }
        
    }
    
    func saveOrgan(possibleHand: SKSpriteNode, organ: SKSpriteNode) {
        
        if possibleHand.name == "Hand", organ.name == "Organ" {
            organTouchPlayer.rate = organTouchTempo / 2
            organTouchPlayer.volume = organTouchVolume * 3.5
            organTouchPlayer.play()
            isFingerOnOrgan = false
            organ.name = "DeliveredOrgan"
            run(SKAction.sequence([
                SKAction.run() {
                    organ.position = CGPoint(x: 511.564, y: 270.835)
                    organ.zPosition = 1
                    organ.physicsBody?.affectedByGravity = false
                    organ.physicsBody?.angularDamping = 0
                    organ.physicsBody?.velocity = CGVector(dx: 400, dy: 0)
                    possibleHand.physicsBody?.velocity = CGVector(dx: 400, dy: 0)
                    self.score += 1
                    print("score: " + String(self.score))
                    self.scoreLabel.text = String(self.score)
                },
                SKAction.wait(forDuration: 0.375),
                SKAction.run() {
                    possibleHand.physicsBody?.velocity = CGVector.zero
                    possibleHand.physicsBody?.velocity = CGVector(dx: -400, dy: 0)
                },
                SKAction.wait(forDuration: 0.375),
                SKAction.run() {
                    organ.removeFromParent() // change the image to an explosion of blood instead
                    possibleHand.physicsBody?.velocity = CGVector.zero
                    possibleHand.position = CGPoint(x: 501.564, y: 289.835)
                }
            ]))
        }
        
    }
    
    func killOrgan(organ: SKSpriteNode) {
        if organ.name == "Organ" {
            organDiePlayer.play()
            isFingerOnOrgan = false
            gameOngoing = false
            self.spawnPieces(organ: organ)
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
                SKAction.wait(forDuration: 0.15),
                SKAction.run() {
                    organ.texture = SKTexture(imageNamed: "blood2")
                    organ.size = CGSize(width: 200, height: 200)
                },
                SKAction.wait(forDuration: 1.85),
                SKAction.run() {
                    organ.removeFromParent() // change the image to an explosion of blood instead
                    let reveal = SKTransition.fade(with: UIColor.red, duration: 0.75)
                    let gameOverScene = GameOverScene(size: self.size, score: self.score)
                    self.view?.presentScene(gameOverScene, transition: reveal)
                }
            ]))
        }
    }
    
    func spawnPieces(organ: SKSpriteNode) {
        
        let piece1 = SKSpriteNode(imageNamed: "p1")
        piece1.name = "Piece"
        piece1.position = organ.position
        piece1.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(15))
        piece1.physicsBody?.categoryBitMask = PhysicsCategory.Organ
        piece1.physicsBody?.contactTestBitMask = PhysicsCategory.Edge | PhysicsCategory.Hand
        piece1.physicsBody?.collisionBitMask = PhysicsCategory.Edge
        piece1.physicsBody?.friction = 0.05
        piece1.physicsBody?.angularDamping = 0.3
        piece1.physicsBody?.restitution = 0.2
        piece1.physicsBody?.velocity = CGVector(dx: 250, dy: 350)
        piece1.physicsBody?.affectedByGravity = true
        
        let piece2 = SKSpriteNode(imageNamed: "p2")
        piece2.name = "Piece"
        piece2.position = organ.position
        piece2.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(12))
        piece2.physicsBody?.categoryBitMask = PhysicsCategory.Organ
        piece2.physicsBody?.contactTestBitMask = PhysicsCategory.Edge | PhysicsCategory.Hand
        piece2.physicsBody?.collisionBitMask = PhysicsCategory.Edge
        piece2.physicsBody?.friction = 0.05
        piece2.physicsBody?.angularDamping = 0.3
        piece2.physicsBody?.restitution = 0.2
        piece2.physicsBody?.velocity = CGVector(dx: 150, dy: 300)
        piece2.physicsBody?.affectedByGravity = true
        
        let piece3 = SKSpriteNode(imageNamed: "p3")
        piece3.name = "Piece"
        piece3.position = organ.position
        piece3.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(8))
        piece3.physicsBody?.categoryBitMask = PhysicsCategory.Organ
        piece3.physicsBody?.contactTestBitMask = PhysicsCategory.Edge | PhysicsCategory.Hand
        piece3.physicsBody?.collisionBitMask = PhysicsCategory.Edge
        piece3.physicsBody?.friction = 0.05
        piece3.physicsBody?.angularDamping = 0.3
        piece3.physicsBody?.restitution = 0.2
        piece3.physicsBody?.velocity = CGVector(dx: -100, dy: 450)
        piece3.physicsBody?.affectedByGravity = true
        
        addChild(piece1)
        addChild(piece2)
        addChild(piece3)
    }
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameOngoing {
            if !isFingerOnOrgan {
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
                    organTouchPlayer.rate = organTouchTempo / 1.5
                    organTouchPlayer.volume = organTouchVolume
                    organTouchPlayer.play()
                    numOrgans = touchedOrgans.count
                    if touchedOrgans[numOrgans - 1].name == "Organ" {
                        isFingerOnOrgan = true
                        touchedOrgans[numOrgans-1].removeAction(forKey: "rotateOrgan")
                    }
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
            
            let dt:CGFloat = 3.6/50
            let distance = CGVector(dx: touches.first!.location(in: self).x - initTouchLocation.x, dy: touches.first!.location(in: self).y - initTouchLocation.y)
            let velocity = CGVector(dx: distance.dx/dt, dy: distance.dy/dt)
            
            touchedOrgans[numOrgans - 1].physicsBody?.velocity = velocity
            
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
            /*
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
            */
            // Called before each frame is rendered
            if isFingerOnOrgan {
                touchedOrgans[numOrgans - 1].physicsBody?.affectedByGravity = false
                touchedOrgans[numOrgans - 1].physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                touchedOrgans[numOrgans - 1].position = CGPoint(x: touchLocation.x, y: touchLocation.y)
                
                if positionToCompare == 2
                {
                    positionToCompare = 1
                }
                if positionToCompare == 1
                {
                    initTouchLocation = touchLocation
                    positionToCompare = positionToCompare + 1
                }
                /*for organ in touchedOrgans {
                    organ.position = CGPoint(x: touchLocation.x, y: touchLocation.y)
                }*/
                //let organ = childNode(withName: "organ") as! SKSpriteNode
                //organ.position = CGPoint(x: touchLocation.x, y: touchLocation.y)
            }
        }
    }
}
