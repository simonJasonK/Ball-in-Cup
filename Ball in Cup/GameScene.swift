//
//  GameScene.swift
//  Ball in Cup
//
//  Created by Jason Simon on 7/17/16.
//  Copyright (c) 2016 Jason Simon. All rights reserved.
//

import SpriteKit
import CoreMotion

/** This class represents the core gameplay of the cup-and-ball game */
class GameScene: SKScene, SKPhysicsContactDelegate {

    fileprivate var gameMode: GameMode = GameMode.none
    fileprivate var gameStyle: GameStyle = GameStyle.none
    fileprivate var ball: SKSpriteNode!
    fileprivate var cup: SKSpriteNode!
    fileprivate var End: Button!
    fileprivate var EndPressed: SKTexture!
    fileprivate var won = false
    fileprivate var rope: Rope!
    fileprivate var timeKeeper: Stopwatch!
    fileprivate var timerLabel: SKLabelNode!
    fileprivate var catchesLabel: SKLabelNode!
    fileprivate var stringBreaksLabel: SKLabelNode!
    fileprivate var controlLabel: SKLabelNode!
    fileprivate var countdownLabel: SKLabelNode!
    fileprivate var statusLabel: SKLabelNode!
    fileprivate var statusFrames: UInt8!
    fileprivate var frameCount: UInt8!
    fileprivate var successFrames: UInt8!
    fileprivate var numCatches: UInt!
    fileprivate var numBreaks: UInt!
    fileprivate var initialFrames: UInt!
    var motionManager = CMMotionManager()
    // var destY:CGFloat = 395 // initial y-value (for accelerometer functionality)
    fileprivate var EndButtonImage: String!
    fileprivate var EndPressedImage: String!
    fileprivate var CupImage: String!
    fileprivate var BallImage: String!
    fileprivate var cameFromMenu: Bool = false // default, to be changed
    fileprivate var isMuted: Bool = UserDefaults.standard.bool(forKey: "muted")
    fileprivate var Done: Bool = false
    
    init(size: CGSize, mode: GameMode, style: GameStyle, fromMenu: Bool) {
        super.init(size: size)
        gameMode = mode
        gameStyle = style
        cameFromMenu = fromMenu
        
        switch (gameStyle) {
            case GameStyle.latin:
                EndButtonImage = Balero.EndButtonImage
                EndPressedImage = Balero.EndPressedImage
                BallImage = Balero.BallImage
                CupImage = Balero.CupImage
                break
            case GameStyle.japan:
                EndButtonImage = Kendama.EndButtonImage
                EndPressedImage = Kendama.EndPressedImage
                BallImage = Kendama.BallImage
                CupImage = Kendama.CupImage
                break
            default: break
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // perform all initializations needed for game
    override func didMove(to view: SKView) {
        UIApplication.shared.isIdleTimerDisabled = true
        initDisplay()
        initPhysics()
        initBall()
        initCup()
        initRope()
        initAccelerometer()
        
        if !cameFromMenu {
            initHUD()
            if #available(iOS 9.0, *) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "hideMenuBanner"), object: nil)
            }
            
        } else {
            enumerateChildNodes(withName: "//*", using:
                { (node, stop) -> Void in
                    node.alpha = 0.25
            })
            
            initTutorial()
        }
        
    }
    
    fileprivate func initDisplay() {
        self.scene?.backgroundColor = MagentaColor
        frameCount = 0
        successFrames = 0
        initialFrames = 0
        statusFrames = 0
        numBreaks = 0
        numCatches = 0
        
        End = Button(imageNamed: EndButtonImage)
        EndPressed = SKTexture(imageNamed: EndPressedImage)
        
        if IS_IPHONE_35 || IS_IPHONE_40 {
            End.setScale(0.35)
            End.position = CGPoint(x: self.frame.maxX - 40, y: self.frame.maxY - 20)
        } else if IS_IPHONE_X {
            End.setScale(0.35)
            End.position = CGPoint(x: self.frame.maxX - 48, y: self.frame.maxY - 25)
        } else {
            End.setScale(0.5)
            End.position = CGPoint(x: self.frame.maxX - 55, y: self.frame.maxY - 25)
        }
        
        End.name = "EndButton"
        End.alpha = 0.75
        End.zPosition = 5
        self.addChild(End)
        
        EndPressed = SKTexture(imageNamed: EndPressedImage)
        
    }
    
    fileprivate func initHUD() {

        switch (gameMode) {
            case GameMode.simple:
                timeKeeper = Stopwatch(time: 0)
                break
            case GameMode.go:
                if gameStyle == GameStyle.latin {
                    timeKeeper = Stopwatch(time: 1209)
                } else if gameStyle == GameStyle.japan {
                    timeKeeper = Stopwatch(time: 3009)
                }
                
                catchesLabel = SKLabelNode(fontNamed:"Avenir")
                catchesLabel.fontColor = CreamColor
                
                catchesLabel.name = "catches"
                catchesLabel.text = "Catches: 0   " //timeKeeper.timeStamp()
                catchesLabel.fontSize = 18
                catchesLabel.position = CGPoint(x:self.frame.minX + 60, y:self.frame.minY + 20)
                catchesLabel.zPosition = 5
                
                self.addChild(catchesLabel)
                
                stringBreaksLabel = SKLabelNode(fontNamed:"Avenir")
                stringBreaksLabel.fontColor = CreamColor
                
                stringBreaksLabel.name = "breaks"
                stringBreaksLabel.text = "Breaks: 0   " //timeKeeper.timeStamp()
                stringBreaksLabel.fontSize = 18
                stringBreaksLabel.position = CGPoint(x:self.frame.maxX - 90, y:self.frame.minY + 20)
                stringBreaksLabel.zPosition = 5
                
                self.addChild(stringBreaksLabel)
                
                statusLabel = SKLabelNode(fontNamed:"Avenir")
                statusLabel.fontColor = UIColor(red: 0, green: 1.00,
                                                      blue: 0, alpha: 1.0)
                
                statusLabel.name = "status"
                statusLabel.text = "+1" //timeKeeper.timeStamp()
                statusLabel.fontSize = 48
                statusLabel.position = CGPoint(x:self.frame.minX + 60, y:self.frame.minY + 50)
                statusLabel.zPosition = 5
                statusLabel.isHidden = true
                
                self.addChild(statusLabel)
                break
            default:
                break
        }
        timerLabel = SKLabelNode(fontNamed:"Avenir")
        timerLabel.fontColor = CreamColor
        
        timerLabel.name = "time"
        timerLabel.text = timeKeeper.timeStamp()
        
        if IS_IPHONE_35 || IS_IPHONE_40 {
            timerLabel.fontSize = 36
            timerLabel.position = CGPoint(x:self.frame.midX, y:self.frame.maxY - 35)
        } else {
            timerLabel.fontSize = 45
            timerLabel.position = CGPoint(x:self.frame.midX, y:self.frame.maxY - 50)
            if IS_IPHONE_X {
                timerLabel.position = CGPoint(x:self.frame.midX, y:self.frame.maxY - 80)
            }
        }
        
        timerLabel.zPosition = 5
        
        self.addChild(timerLabel)
    }
    
    // initialize the game physics
    fileprivate func initPhysics() {
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0,dy: -9.8)
        physicsWorld.speed = 1.0
    }
    
    // initialize the ball
    fileprivate func initBall() {
        
        ball = SKSpriteNode(imageNamed: BallImage)
        
        if IS_IPHONE_35 || IS_IPHONE_40 {
            ball.setScale(0.8)
        }
        
        ball.position = CGPoint(x: 50, y: 100)
        
        ball.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: BallImage),
                                         size: ball.size)
        ball.physicsBody?.categoryBitMask = Category.Ball
        ball.physicsBody?.collisionBitMask = 1
        ball.physicsBody?.contactTestBitMask = Category.Rope
        ball.physicsBody?.density = 0.2
        // ball.physicsBody?.linearDamping = 0.25
        //ball.physicsBody?.allowsRotation = false // debug
        ball.physicsBody?.isDynamic = true
   
        self.addChild(ball)
    }
    
    // initialize the cup
    fileprivate func initCup() {
        
        cup = SKSpriteNode(imageNamed: CupImage)
        
        if IS_IPHONE_35 || IS_IPHONE_40 {
            cup.setScale(0.8)
        }
        
        switch (gameStyle) {
            case GameStyle.latin:
                cup.position = CGPoint(x:self.frame.midX,
                                   y:self.frame.midY + 0.05 * self.view!.bounds.size.height)
                break
            case GameStyle.japan:
                cup.position = CGPoint(x:self.frame.midX,
                                   y:self.frame.midY)
                break
            default: break
        }
        
        cup.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: CupImage), size: cup.size)
        cup.physicsBody?.categoryBitMask = Category.Cup
        cup.physicsBody?.collisionBitMask = 0
        cup.physicsBody?.contactTestBitMask = Category.Ball
        cup.physicsBody?.isDynamic = false
        
        cup.name = "cup"

        self.addChild(cup)
        
    }
    
    // initialize a Rope; the anchor point is on the cup, and
    // the hanging mass is the ball
    fileprivate func initRope() {
        
        let length : Int
        // create rope
        switch (gameStyle) {
            case GameStyle.latin:
                length = 18 * Int(UIScreen.main.scale)
                break
            case GameStyle.japan:
                length = 16 * Int(UIScreen.main.scale)
                break
            default: length = 0
        }

        let anchorPoint = CGPoint(x: (cup.position.x + (0.0175 * self.view!.bounds.size.width)),
                                  y: (cup.position.y - (0.0 * self.view!.bounds.size.height)))
        rope = Rope(length: length, anchorPoint: anchorPoint, name: "MainRope")
        
        rope.zPosition = 1
        
        // add to scene
        rope.generateRopeOnScene(self)
            
        // connect the other end of the rope to the ball
        rope.attachToBall(ball)
    }
    
    // initialize the accelerometer functionality
    fileprivate func initAccelerometer() {
       
        if motionManager.isAccelerometerAvailable == true {
            
            motionManager.startAccelerometerUpdates()
            
        }
    }
    
    fileprivate func initTutorial() {
        controlLabel = SKLabelNode(fontNamed:"Avenir")
        controlLabel.fontColor = CreamColor
        
        controlLabel.name = "control"
        controlLabel.text = "Move your device to control!"
        
        controlLabel.fontSize = 24
        controlLabel.position = CGPoint(x:self.frame.midX, y:self.frame.midY + 150)
        
        controlLabel.zPosition = 5
        
        self.addChild(controlLabel)
        
        countdownLabel = SKLabelNode(fontNamed:"Avenir")
        countdownLabel.fontColor = CreamColor
        
        countdownLabel.name = "countdown"
        countdownLabel.text = "3"
        
        countdownLabel.fontSize = 144
        countdownLabel.position = CGPoint(x:self.frame.midX, y:self.frame.midY - 50)
        
        countdownLabel.zPosition = 5
        
        self.addChild(countdownLabel)
        
        if !isMuted {
            self.run(ChimeSoundAction)
        }
    }
    
    // for debugging purposes, control the ball by touch
    /* override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            ball.position = touch.location(in: self)
            print(touch.location(in: self))
        }
    } */
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // debug is commented
        /*for _ in touches {
        }*/
        
        var node : SKNode
        var touch : UITouch
        
        touch = touches.first!
        node = self.atPoint(touch.location(in: self))
        
        if node.name == "EndButton" {
            End.pressed = true
            End.alpha = 1.0
            End.texture = EndPressed
            
            if !isMuted {
                self.run(PressSoundAction)
            }
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        var node : SKNode
        var touch : UITouch
        
        touch = touches.first!
        node = self.atPoint(touch.location(in: self))
        
        // end game
        if End.pressed {
        
            End.pressed = false
        
            if node.name == "EndButton" {
                switch (gameMode) {
                    case GameMode.simple:
                        UserDefaults.standard.set("0", forKey:"consecutive")
                        UserDefaults.standard.synchronize()
                        toScore("Try Again!")
                    case GameMode.go:
                        UserDefaults.standard.set("0", forKey:"consecutive")
                        UserDefaults.standard.synchronize()
                        toScore("Try Again!")
                    default: break
                }
            } else {
                End.texture = SKTexture(imageNamed: EndButtonImage)
                End.alpha = 0.75
            }
        }
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if ((contact.bodyA.categoryBitMask == Category.Cup) &&
            (contact.bodyB.categoryBitMask == Category.Ball)) ||
            ((contact.bodyB.categoryBitMask == Category.Cup) &&
                (contact.bodyA.categoryBitMask == Category.Ball)){
            
            //ball.physicsBody!.applyForce(CGVectorMake(-ball.physicsBody!.velocity.dx,
//                -ball.physicsBody!.velocity.dy))

        }
    }
    
    /* Called before each frame is rendered */
    override func update(_ currentTime: TimeInterval) {
        if !Done {
        frameCount = frameCount + UInt8(1)
        
        if cameFromMenu && initialFrames < 181 {
            
            if initialFrames == 61 {
                if !isMuted {
                    self.run(ChimeSoundAction)
                }
                countdownLabel.text = "2"
            } else if initialFrames == 121 {
                if !isMuted {
                    self.run(ChimeSoundAction)
                }
                countdownLabel.text = "1"
            }
            
            initialFrames = initialFrames + UInt(1)
            return
            
        } else if cameFromMenu && initialFrames == 181 {
            controlLabel.removeFromParent()
            countdownLabel.removeFromParent()
            if #available(iOS 9.0, *) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "hideMenuBanner"), object: nil)
            }
            
            initHUD()
            
            enumerateChildNodes(withName: "//*", using:
                { (node, stop) -> Void in
                    node.alpha = 1.0
            })
            
            initialFrames = initialFrames + UInt(1)
        }
        
        if statusFrames != 0 {
            if statusFrames == 41 {
                statusFrames = 0
                statusLabel.isHidden = true
            } else {
                statusFrames = statusFrames + UInt8(1)
            }
        }
        
        if let accelerometerData = motionManager.accelerometerData {
            ball.physicsBody!.applyImpulse(CGVector(dx: CGFloat(accelerometerData.acceleration.x * 20),
                dy: CGFloat(accelerometerData.acceleration.y * 20)))
        }
        
        if frameCount % 6 == 0 {
            frameCount = 0
            switch (gameMode) {
                case GameMode.simple:
                    timeKeeper.incTime()
                    break
                case GameMode.go:
                    timeKeeper.decTime()
                    break
                default: break
            }
            timerLabel.text = timeKeeper.timeStamp()
        }
        
        
        // game over due to time limit test
        switch (gameMode) {
            case GameMode.simple:
                // 1 hour imposed limit test
                if timeKeeper.getTimePassed() == 36000 {
                    UserDefaults.standard.set("0", forKey:"consecutive")
                    UserDefaults.standard.synchronize()
                    toScore("Sorry, Time's Up!")
                }
                break
            case GameMode.go:
                if timeKeeper.getTimePassed() == -1 {
                    let numConsec = UserDefaults.standard.integer(forKey: "consecutive")
                    UserDefaults.standard.set(String(numConsec + 1), forKey:"consecutive")
                    let roundsPlayed = UserDefaults.standard.integer(forKey: "Rounds Played")
                    UserDefaults.standard.set(roundsPlayed + 1, forKey:"Rounds Played")
                    UserDefaults.standard.synchronize()
                    toScore(String(numCatches) + "|" + String(numBreaks))
                }
                break
            default: break
        }

        // win condition test
        if ballInCup() {
            successFrames = successFrames + UInt8(1)
        
            if (successFrames == 12 && gameStyle == GameStyle.latin) ||
                (successFrames == 9 && gameStyle == GameStyle.japan) {
                if !isMuted {
                    self.run(PositiveSoundAction)
                }
                successFrames = 0
                switch (gameMode) {
                    case GameMode.simple:
                        let numConsec = UserDefaults.standard.integer(forKey: "consecutive")
                        UserDefaults.standard.set(String(numConsec + 1), forKey:"consecutive")
                        let roundsPlayed = UserDefaults.standard.integer(forKey: "Rounds Played")
                        UserDefaults.standard.set(roundsPlayed + 1, forKey:"Rounds Played")
                        UserDefaults.standard.synchronize()
                        Done = true
                        toScore(String(timeKeeper.getTimePassed()) + "|" + timeKeeper.timeStamp())
                        break
                    case GameMode.go:
                        numCatches = numCatches + UInt(1)
                        statusFrames = statusFrames + UInt8(1)
                        statusLabel.fontColor = UIColor(red: 0, green: 1.00,
                                                        blue: 0, alpha: 1.0)
                        statusLabel.position = CGPoint(x:self.frame.minX + 60, y:self.frame.minY + 50)
                        statusLabel.isHidden = false
                        for child in self.children {
                            if child.name != "time" && child.name != "catches" && child.name != "breaks" &&
                               child.name != "status" && child.name != "EndButton" {
                                child.removeFromParent()
                            }
                        }
                        
                        if motionManager.isAccelerometerAvailable == true {
                            
                            motionManager.stopAccelerometerUpdates()
                            
                        }
                        
                        initBall()
                        initCup()
                        initRope()
                        initAccelerometer()
                        break
                    default: break
                }
            }
            
        } else {
            successFrames = 0
        }
        
        // "rope is broken" test
        if (abs(ball.position.x) > (5 * self.view!.bounds.size.width)
            || abs(ball.position.y) > (2 * self.view!.bounds.size.height)) {
            
            if !isMuted {
                self.run(NegativeSoundAction)
            }
            
            for child in self.children {
                if child.name != "time" && child.name != "catches" && child.name != "breaks" &&
                   child.name != "status" && child.name != "EndButton" {
                    child.removeFromParent()
                }
            }
            
            if motionManager.isAccelerometerAvailable == true {
                
                motionManager.stopAccelerometerUpdates()
                
            }
            
            switch (gameMode) {
                case GameMode.simple:
                    UserDefaults.standard.set("0", forKey:"consecutive")
                    UserDefaults.standard.synchronize()
                    Done = true
                    toScore("Your String Broke!")
                    break
                case GameMode.go:
                    numBreaks = numBreaks + UInt(1)
                    statusFrames = statusFrames + UInt8(1)
                    statusLabel.fontColor = UIColor(red: 1.00, green: 0,
                                                    blue: 0.0, alpha: 1.0)
                    
                    statusLabel.position = CGPoint(x:self.frame.maxX - 90, y:self.frame.minY + 50)
                    statusLabel.isHidden = false
                    initBall()
                    initCup()
                    initRope()
                    initAccelerometer()
                    break
                default: break
            }
            
        }}
        
        // Keep track of stats for the timed modes
        if (gameMode == GameMode.go) {
            let numCatches_st = String(numCatches)
            let numBreaks_st = String(numBreaks)
            catchesLabel.text = "Catches: " + numCatches_st + String(repeating: " ", count: (4-numCatches_st.characters.count))
            stringBreaksLabel.text = "Strings Broken: " + numBreaks_st + String(repeating: " ", count: (4-numBreaks_st.characters.count))

        }
    }
    
    // after game ends, transition to ScoreScene
    fileprivate func toScore(_ toSend : String) {
        let adNumConsec = UserDefaults.standard.integer(forKey: "adConsecutive")
        UserDefaults.standard.set((adNumConsec + 1) % 5, forKey:"adConsecutive")
        
        UserDefaults.standard.synchronize()
        
        let scoreScene = ScoreScene(size: self.view!.bounds.size,
                                    score: toSend, mode:gameMode, style: gameStyle)
        let transition = SKTransition.doorway(withDuration: 1.0)
        scene?.view?.presentScene(scoreScene, transition: transition)
    }
    
    // is the ball in the cup (and thus end game or increment counter)?
    fileprivate func ballInCup() -> Bool {
        switch (gameStyle) {
            case GameStyle.latin:
                if IS_IPHONE_47 {
                    if 172 ... 198 ~= ball.position.x && 546 ... 555 ~= ball.position.y {
                        return true
                    }
                } else if IS_IPHONE_35 {
                    if 148 ... 162 ~= ball.position.x && 402 ... 418 ~= ball.position.y {
                        return true
                    }
                } else if IS_IPHONE_40 {
                    if 148 ... 162 ~= ball.position.x && 452 ... 468 ~= ball.position.y {
                        return true
                    }
                } else if IS_IPHONE_55 {
                    if 196 ... 214 ~= ball.position.x && 576 ... 604 ~= ball.position.y {
                        return true
                    }
                } else if IS_IPHONE_X {
                    if 170 ... 190 ~= ball.position.x && 620 ... 640 ~= ball.position.y {
                        return true
                    }
                }
                break
            case GameStyle.japan:
                if IS_IPHONE_47 {
                    if 180 ... 190 ~= ball.position.x && 508 ... 518 ~= ball.position.y {
                        return true
                    }
                } else if IS_IPHONE_35 {
                    if 155 ... 165 ~= ball.position.x && 380 ... 388 ~= ball.position.y {
                        return true
                    }
                } else if IS_IPHONE_40 {
                    if 155 ... 165 ~= ball.position.x && 425 ... 435 ~= ball.position.y {
                        return true
                    }
                } else if IS_IPHONE_55 {
                    if 198 ... 212 ~= ball.position.x && 543 ... 557 ~= ball.position.y {
                        return true
                    }
                } else if IS_IPHONE_X {
                    if 170 ... 190 ~= ball.position.x && 570 ... 600 ~= ball.position.y {
                        return true
                    }
                }
                break
            default: break
        }
        
        return false

    }
    
}
