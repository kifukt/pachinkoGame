//
//  GameScene.swift
//  project11Pachinko
//
//  Created by Alexey Furman on 22/09/2017.
//  Copyright © 2017 furman. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ballCounter = 0
    
    var scoreLabel: SKLabelNode!
    
    var score = 0 {
        didSet {
            if score < 0  {
                score = 0
            }
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var editLabel: SKLabelNode!
    
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    let balls = ["ballRed", "ballCyan", "ballBlue", "ballGrey", "ballGreen", "ballPurple", "ballYellow"]
    
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.position = CGPoint(x: 80, y: 700)
        editLabel.text = "Edit"
        addChild(editLabel)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            let objects = nodes(at: location)
            if objects.contains(editLabel) {
                editingMode = !editingMode
            } else {
                if editingMode {
                    let objects = nodes(at: location)
                    for object in objects {
                        if object.name == "box" {
                            object.removeFromParent()
                            return
                        }
                    }
                    let size = CGSize(width: GKRandomDistribution(lowestValue: 16, highestValue: 128).nextInt() , height: 16)
                    let box = SKSpriteNode(color: RandomColor(), size: size)
                    box.zRotation = RandomCGFloat(min: 0, max: 3)
                    box.position = location
                    box.name = "box"
                    
                    box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                    box.physicsBody?.isDynamic = false
                    
                    addChild(box)
                } else {
                    let randomInt = GKRandomDistribution(lowestValue: 0, highestValue: 6).nextInt()
                    let ball = SKSpriteNode(imageNamed: balls[randomInt])
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                    ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                    ball.physicsBody!.restitution = 0.4
                    ball.position = CGPoint(x: location.x, y: 700)
                    ball.name = "ball"
                    ballCounter += 1
                    if ballCounter <= 5{
                        addChild(ball)
                    } else {
                        scene?.enumerateChildNodes(withName: "box") { (node, _) in
                            node.removeFromParent()
                        }
                        ballCounter = 0
                    }
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if contact.bodyA.node?.name == "ball" {
            collisionBetween(ball: nodeA, object: nodeB)
        } else if contact.bodyB.node!.name == "ball" {
            collisionBetween(ball: nodeB, object: nodeA)
        }
    }
    
    func makeBouncer(at point: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = point
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody!.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        slotBase.position = position
        slotGlow.position = position
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody!.isDynamic = false
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: CGFloat.pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collisionBetween(ball: SKNode, object: SKNode) {
        
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
            ballCounter -= 1
        } else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
        }
    }
    
    func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        
        ball.removeFromParent()
    }
}
