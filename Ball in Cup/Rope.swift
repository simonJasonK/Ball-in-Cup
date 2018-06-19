//
//  Rope.swift
//  Ball in Cup
//
//  Created by Jason Simon on 7/18/16.
//  Copyright (c) 2016 Jason Simon. The structure of this file is based on
//  an online tutorial, which I am electing to use under the MIT license, 
//  from Razeware LLC.
//

import SpriteKit
import UIKit

/** This class represents a Rope, which will have a length (i.e., number
 * of links), an array of said pieces, and a point to which the rope is
 * affixed to as a hinge (i.e., anchor)
 */
class Rope: SKNode {
    
    fileprivate let length: Int
    fileprivate let anchorPoint: CGPoint
    fileprivate var ropePieces: [SKNode] = []
    fileprivate var isRainbowRope: Bool
    fileprivate var ropeSeed: Int
    
    // implemented to satisfy NSCoding protocol
    required init?(coder aDecoder: NSCoder) {
        
        length = aDecoder.decodeInteger(forKey: "length")
        anchorPoint = aDecoder.decodeCGPoint(forKey: "anchorPoint")
        
        isRainbowRope = UserDefaults.standard.bool(forKey: "Rainbow Rope")
        ropeSeed = Int(arc4random_uniform(7) + 1)
        
        super.init(coder: aDecoder)
    }
    
    // constructor that actually gets used
    init(length: Int, anchorPoint: CGPoint, name: String) {
        
        self.length = length
        self.anchorPoint = anchorPoint
        
        isRainbowRope = UserDefaults.standard.bool(forKey: "Rainbow Rope")
        ropeSeed = Int(arc4random_uniform(7) + 1)
        
        super.init()
        
        self.name = name
    }
    
    // generates the links that will become the rope
    func generateRopeOnScene(_ scene: SKScene) {
        
        // add this object (what will be the rope) to the given scene
        scene.addChild(self)
        
        // create rope holder, which is a design element that signals the anchor
        let ropeHolder = SKSpriteNode(imageNamed: RopeHolderImage)
        ropeHolder.position = anchorPoint
        
        if IS_IPHONE_35 {
            ropeHolder.setScale(0.8)
        }
        
        ropePieces.append(ropeHolder)
        addChild(ropeHolder)
        
        ropeHolder.physicsBody = SKPhysicsBody(circleOfRadius: ropeHolder.size.width / 2)
        ropeHolder.physicsBody?.categoryBitMask = Category.RopeHolder
        ropeHolder.physicsBody?.collisionBitMask = 0
        ropeHolder.physicsBody?.contactTestBitMask = Category.Ball
        ropeHolder.physicsBody?.mass = CGFloat.greatestFiniteMagnitude
        ropeHolder.physicsBody?.isDynamic = false
        
        // generate all the length-many pieces of the rope
        for i in 0 ..< length {
            
            let ropePiece = SKSpriteNode(imageNamed: RopeTextureImage)
            
            if IS_IPHONE_35 || IS_IPHONE_40 {
                ropePiece.setScale(0.8)
            }
            
            let offset = ropePiece.size.height * CGFloat(i + 1)
            ropePiece.position = CGPoint(x: anchorPoint.x, y: anchorPoint.y - offset)
            ropePiece.name = name
            
            if isRainbowRope {
                switch (ropeSeed % 7) {
                    case 0:
                        ropePiece.texture = SKTexture(imageNamed: RedBoxImage)
                        break
                    case 1:
                        ropePiece.texture = SKTexture(imageNamed: OrangeBoxImage)
                        break
                    case 2:
                        ropePiece.texture = SKTexture(imageNamed: YellowBoxImage)
                        break
                    case 3:
                        ropePiece.texture = SKTexture(imageNamed: GreenBoxImage)
                        break
                    case 4:
                        ropePiece.texture = SKTexture(imageNamed: BlueBoxImage)
                        break
                    case 5:
                        ropePiece.texture = SKTexture(imageNamed: IndigoBoxImage)
                        break
                    case 6:
                        ropePiece.texture = SKTexture(imageNamed: VioletBoxImage)
                        break
                    default: break
                }
                
                ropeSeed += 1
            }
            
            ropePieces.append(ropePiece)
            addChild(ropePiece)
            
            ropePiece.physicsBody = SKPhysicsBody(rectangleOf: ropePiece.size)
                        ropePiece.physicsBody?.collisionBitMask = Category.RopeHolder
            ropePiece.physicsBody?.categoryBitMask = Category.Rope
            ropePiece.physicsBody?.contactTestBitMask = Category.Ball
            ropePiece.physicsBody?.density = 2
        }
        
        /* simulate actual rope movement using SKPhysics Joints to form links
           between rope pieces */
        for i in 1...length {
            
            let prev = ropePieces[i - 1]
            let next = ropePieces[i]
            let link = SKPhysicsJointPin.joint(withBodyA: prev.physicsBody!,
                            bodyB: next.physicsBody!,
                            anchor: CGPoint(x: prev.frame.midX,
                            y: prev.frame.minY))
            
            scene.physicsWorld.add(link)
        }
    }
    
    // attaches the hanging mass (i.e., non-anchor point) to the Rope
    func attachToBall(_ ball: SKSpriteNode) {
        
        // align last segment of rope with ball
        let lastNode = ropePieces.last!
        lastNode.position = CGPoint(x: ball.position.x,
                                        y: ball.position.y + ball.size.height * 0.1)
        
        // set up the final link
        let joint = SKPhysicsJointPin.joint(withBodyA: lastNode.physicsBody!,
                        bodyB: ball.physicsBody!, anchor: lastNode.position)
        
        ball.scene?.physicsWorld.add(joint)
    }
    
}
