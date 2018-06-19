//
//  RecordsScene.swift
//  Ball in Cup
//
//  Created by Jason Simon on 8/4/16.
//  Copyright © 2016 Jason Simon. All rights reserved.
//

import UIKit
import SpriteKit

class RecordsScene: SKScene {
    
    fileprivate var SimpleTimer: Stopwatch!
    fileprivate var IntenseTimer: Stopwatch!
    fileprivate var Menu: Button!
    fileprivate var MenuPressed: SKTexture!
    fileprivate var MenuButtonImage: String = ""
    fileprivate var MenuPressedImage: String = ""
    fileprivate var Hero: SKSpriteNode!
    fileprivate var Completed: SKSpriteNode!
    fileprivate var parentStyle: GameStyle = GameStyle.none
    
    fileprivate var isMuted: Bool = UserDefaults.standard.bool(forKey: "muted")
    
    fileprivate var SimpleBestLabel: SKLabelNode!
    fileprivate var Go2BestLabel: SKLabelNode!
    fileprivate var IntenseBestLabel: SKLabelNode!
    fileprivate var Go5BestLabel: SKLabelNode!
    fileprivate var RoundsPlayedLabel: SKLabelNode!
    fileprivate var ClassicsMadeLabel: SKLabelNode!
    fileprivate var KendamasMadeLabel: SKLabelNode!
    fileprivate var StringsBrokenLabel: SKLabelNode!
    fileprivate var ConsecutiveRoundsLabel: SKLabelNode!
    fileprivate var DateBeganLabel: SKLabelNode!
    
    fileprivate var ChallengesLabel: SKLabelNode!
    
    fileprivate var RedTarget: Button!
    fileprivate var OrangeTarget: Button!
    fileprivate var YellowTarget: Button!
    fileprivate var GreenTarget: Button!
    fileprivate var BlueTarget: Button!
    fileprivate var IndigoTarget: Button!
    fileprivate var VioletTarget: Button!
    
    fileprivate var RedTargetFill: SKTexture!
    fileprivate var OrangeTargetFill: SKTexture!
    fileprivate var YellowTargetFill: SKTexture!
    fileprivate var GreenTargetFill: SKTexture!
    fileprivate var BlueTargetFill: SKTexture!
    fileprivate var IndigoTargetFill: SKTexture!
    fileprivate var VioletTargetFill: SKTexture!
    
    fileprivate var RainbowRope: SKSpriteNode!
    fileprivate var RainbowLabel: SKLabelNode!
    
    fileprivate var RedDone: Bool = UserDefaults.standard.bool(forKey: "C1")
    fileprivate var OrangeDone: Bool = UserDefaults.standard.bool(forKey: "C2")
    fileprivate var YellowDone: Bool = UserDefaults.standard.bool(forKey: "C3")
    fileprivate var GreenDone: Bool = UserDefaults.standard.bool(forKey: "C4")
    fileprivate var BlueDone: Bool = UserDefaults.standard.bool(forKey: "C5")
    fileprivate var IndigoDone: Bool = UserDefaults.standard.bool(forKey: "C6")
    fileprivate var VioletDone: Bool = UserDefaults.standard.bool(forKey: "C7")
    fileprivate var AllChallengesDone: Bool = UserDefaults.standard.bool(forKey: "All Done")
    fileprivate var RainbowEnabled: Bool = UserDefaults.standard.bool(forKey: "Rainbow Rope")
    
    // defaults for 6, beyond
    var vertOffset : CGFloat = 107
    var horiOffset : CGFloat = 12
    var XOffset : CGFloat = 30 // offset for iPhone X (VER 1.0.3)
    var fontSize : CGFloat = 14

    init(size: CGSize, style: GameStyle) {
        super.init(size: size)
        parentStyle = style
        switch (parentStyle) {
            case GameStyle.latin:
                MenuButtonImage = Balero.MenuButtonImage
                MenuPressedImage = Balero.MenuPressedImage
                break
            case GameStyle.japan:
                MenuButtonImage = Kendama.MenuButtonImage
                MenuPressedImage = Kendama.MenuPressedImage
                break
            default: break
        }
        
        if IS_IPHONE_35 || IS_IPHONE_40 {
            vertOffset = 93
            horiOffset = 10
            fontSize = 12
        }
        
        if !IS_IPHONE_X {
            XOffset = 0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        if #available(iOS 9.0, *) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "hideMenuBanner"), object: nil)
        }
        
        self.scene?.backgroundColor = MagentaColor
        
        if UserDefaults.standard.integer(forKey: "Simple Best") == Int.max {
            SimpleTimer = Stopwatch(time: 0)
        } else {
            SimpleTimer = Stopwatch(time: UserDefaults.standard.integer(forKey: "Simple Best"))
        }
        
        if UserDefaults.standard.integer(forKey: "Intense Best") == Int.max {
            IntenseTimer = Stopwatch(time: 0)
        } else {
            IntenseTimer = Stopwatch(time: UserDefaults.standard.integer(forKey: "Intense Best"))
        }
        
        Hero = SKSpriteNode(imageNamed: RecordsHeaderText)
        Hero.position = CGPoint(x:self.frame.midX,
                                y:self.frame.maxY - 40 - XOffset)
        
        if IS_IPHONE_35 || IS_IPHONE_40 {
            Hero.setScale(0.65)
        } else {
            Hero.setScale(0.8)
        }
        
        self.addChild(Hero)
        
        Completed = SKSpriteNode(imageNamed: AllClearText)
        Completed.position = CGPoint(x:self.frame.midX,
                                           y:self.frame.maxY - CGFloat(vertOffset) - XOffset -
                                            0.4625 * self.view!.frame.size.height)
        
        if !AllChallengesDone {
            Completed.isHidden = true
        } else {
            Completed.run(SKAction.repeatForever(SKAction.sequence([FastFadeOut,
                FastFadeIn])), withKey: "Fade")
        }
        
        if IS_IPHONE_35 || IS_IPHONE_40 {
            Completed.setScale(0.8)
        }
        
        self.addChild(Completed)
      
        initLabels()
        addButtons()
        initChallenges()
    }
    
    fileprivate func initLabels() {
        RainbowLabel = SKLabelNode(fontNamed:"Avenir")
        RainbowLabel.fontColor = CreamColor
        RainbowLabel.name = "rainbow"
        
        if RainbowEnabled {
            RainbowLabel.text = "Rainbow Rope On"
        } else {
            RainbowLabel.text = "Rainbow Rope Off"
        }
        
        if IS_IPHONE_35 {
            RainbowLabel.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 65)
            RainbowLabel.fontSize = 12
        } else if IS_IPHONE_40 {
            RainbowLabel.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 72)
            RainbowLabel.fontSize = 12
        } else {
            RainbowLabel.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 85 + XOffset)
            RainbowLabel.fontSize = 14
        }
        
        if !AllChallengesDone {
            RainbowLabel.isHidden = true
        }
        
        self.addChild(RainbowLabel)
        
        ChallengesLabel = SKLabelNode(fontNamed:"AvenirNext-Bold")
        ChallengesLabel.fontColor = CreamColor
        
        if IS_IPHONE_35 || IS_IPHONE_40 {
            ChallengesLabel.fontSize = 28
        } else {
            ChallengesLabel.fontSize = 32

        }
        
        ChallengesLabel.text = "Challenge Boxes"
        
        ChallengesLabel.position = CGPoint(x:self.frame.midX,
                                          y:self.frame.maxY - CGFloat(vertOffset) -
                                            CGFloat(XOffset) -
                                            0.4625 * self.view!.frame.size.height)
        
        self.addChild(ChallengesLabel)
        
        if AllChallengesDone {
            ChallengesLabel.isHidden = true
        }
        
        SimpleBestLabel = SKLabelNode(fontNamed:"Avenir")
        SimpleBestLabel.fontColor = CreamColor
        
        SimpleBestLabel.fontSize = fontSize
        
        Go2BestLabel = SKLabelNode(fontNamed:"Avenir")
        Go2BestLabel.fontColor = CreamColor
        Go2BestLabel.fontSize = fontSize
        
        IntenseBestLabel = SKLabelNode(fontNamed:"Avenir")
        IntenseBestLabel.fontColor = CreamColor
        IntenseBestLabel.fontSize = fontSize
        
        Go5BestLabel = SKLabelNode(fontNamed:"Avenir")
        Go5BestLabel.fontColor = CreamColor
        Go5BestLabel.fontSize = fontSize
        
        RoundsPlayedLabel = SKLabelNode(fontNamed:"Avenir")
        RoundsPlayedLabel.fontColor = CreamColor
        RoundsPlayedLabel.fontSize = fontSize
        
        ClassicsMadeLabel = SKLabelNode(fontNamed:"Avenir")
        ClassicsMadeLabel.fontColor = CreamColor
        ClassicsMadeLabel.fontSize = fontSize
        
        KendamasMadeLabel = SKLabelNode(fontNamed:"Avenir")
        KendamasMadeLabel.fontColor = CreamColor
        KendamasMadeLabel.fontSize = fontSize
        
        StringsBrokenLabel = SKLabelNode(fontNamed:"Avenir")
        StringsBrokenLabel.fontColor = CreamColor
        StringsBrokenLabel.fontSize = fontSize
        
        ConsecutiveRoundsLabel = SKLabelNode(fontNamed:"Avenir")
        ConsecutiveRoundsLabel.fontColor = CreamColor
        ConsecutiveRoundsLabel.fontSize = fontSize
        
        DateBeganLabel = SKLabelNode(fontNamed:"Avenir")
        DateBeganLabel.fontColor = CreamColor
        DateBeganLabel.fontSize = fontSize
        
        SimpleBestLabel.text = "\"Simple\" Best Time: " + SimpleTimer.timeStamp()
        
        if SimpleTimer.timeStamp().range(of: ":") == nil {
            SimpleBestLabel.text = SimpleBestLabel.text! + " s"
        }
        
        if SimpleTimer.timeStamp() == "0.0" {
            SimpleBestLabel.text = "\"Simple\" Best Time: N/A"
        }
        
        SimpleBestLabel.text = SimpleBestLabel.text! + " (Orange: ≤1.2 s)"
        
        IntenseBestLabel.text = "\"Intense\" Best Time: " + IntenseTimer.timeStamp()
        
        if IntenseTimer.timeStamp().range(of: ":") == nil {
            IntenseBestLabel.text = IntenseBestLabel.text! + " s"
        }
        
        if IntenseTimer.timeStamp() == "0.0" {
            IntenseBestLabel.text = "\"Intense\" Best Time: N/A"
        }
        
        IntenseBestLabel.text = IntenseBestLabel.text! + " (Green: ≤3.0 s)"
        
        Go2BestLabel.text = "\"Go! 2:00\" High Score: " + String(UserDefaults.standard.integer(forKey: "Go2 High")) + " (Yellow: ≥900)"
        ClassicsMadeLabel.text = "Catches Made in Green Modes: " + String(UserDefaults.standard.integer(forKey: "Classic Catches Made"))
        Go5BestLabel.text = "\"Go! 5:00\" High Score: " + String(UserDefaults.standard.integer(forKey: "Go5 High")) + " (Blue: ≥180)"
        KendamasMadeLabel.text = "Catches Made in Red Modes: " + String(UserDefaults.standard.integer(forKey: "Kendama Catches Made"))
        RoundsPlayedLabel.text = "Full Rounds Completed: " + String(UserDefaults.standard.integer(forKey: "Rounds Played")) + " (Violet: ≥150)"
        ConsecutiveRoundsLabel.text = "Longest \"Again!\" Streak, Full Rounds: " + String(UserDefaults.standard.integer(forKey: "Most Consecutive Rounds")) + " (Indigo: ≥15)"
        StringsBrokenLabel.text = "Total Strings Broken: " + String(UserDefaults.standard.integer(forKey: "Strings Broken"))
        
        if UserDefaults.standard.string(forKey: "Date Began")! == "" {
            DateBeganLabel.text = "First Time Played: Play a round! (for Red Challenge Box)"
        } else {
            DateBeganLabel.text = "First Time Played: " + UserDefaults.standard.string(forKey: "Date Began")! + " (Red)"
        }
        
        SimpleBestLabel.position = CGPoint(x:self.frame.minX + horiOffset,
                                y:self.frame.maxY - vertOffset - XOffset)
        Go2BestLabel.position = CGPoint(x:self.frame.minX + horiOffset,
                                           y:self.frame.maxY - vertOffset - XOffset -
                                            0.035 * self.view!.frame.size.height)
        IntenseBestLabel.position = CGPoint(x:self.frame.minX + horiOffset,
                                        y:self.frame.maxY - vertOffset - XOffset -
                                            0.07 * self.view!.frame.size.height)
        Go5BestLabel.position = CGPoint(x:self.frame.minX + horiOffset,
                                        y:self.frame.maxY - vertOffset - XOffset -
                                            0.105 * self.view!.frame.size.height)
        
        
        ClassicsMadeLabel.position = CGPoint(x:self.frame.minX + horiOffset,
                                        y:self.frame.maxY - vertOffset - XOffset -
                                            0.175 * self.view!.frame.size.height)
        KendamasMadeLabel.position = CGPoint(x:self.frame.minX + horiOffset,
                                        y:self.frame.maxY - vertOffset - XOffset -
                                            0.210 * self.view!.frame.size.height)
        StringsBrokenLabel.position = CGPoint(x:self.frame.minX + horiOffset,
                                             y:self.frame.maxY - vertOffset - XOffset -
                                                0.245 * self.view!.frame.size.height)
        ConsecutiveRoundsLabel.position = CGPoint(x:self.frame.minX + horiOffset,
                                             y:self.frame.maxY - vertOffset - XOffset -
                                                0.315 * self.view!.frame.size.height)
        RoundsPlayedLabel.position = CGPoint(x:self.frame.minX + horiOffset,
                                             y:self.frame.maxY - vertOffset - XOffset -
                                                0.350 * self.view!.frame.size.height)
        DateBeganLabel.position = CGPoint(x:self.frame.minX + horiOffset,
                                              y:self.frame.maxY - vertOffset - XOffset -
                                                0.385 * self.view!.frame.size.height)
        
        SimpleBestLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        Go2BestLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        ClassicsMadeLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        IntenseBestLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        Go5BestLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        KendamasMadeLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        RoundsPlayedLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        ConsecutiveRoundsLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        StringsBrokenLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        DateBeganLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        self.addChild(SimpleBestLabel)
        self.addChild(Go2BestLabel)
        self.addChild(ClassicsMadeLabel)
        self.addChild(IntenseBestLabel)
        self.addChild(Go5BestLabel)
        self.addChild(KendamasMadeLabel)
        self.addChild(RoundsPlayedLabel)
        self.addChild(ConsecutiveRoundsLabel)
        self.addChild(StringsBrokenLabel)
        self.addChild(DateBeganLabel)
        
        if !RedDone {
            IntenseBestLabel.isHidden = true
            Go5BestLabel.isHidden = true
            KendamasMadeLabel.isHidden = true
        }
        
    }
    
    fileprivate func addButtons() {
        
        Menu = Button(imageNamed: MenuButtonImage)
        MenuPressed = SKTexture(imageNamed: MenuPressedImage)
        Menu.name = "MenuButton"
        
        if IS_IPHONE_35 || IS_IPHONE_40 {
            Menu.setScale(0.5)
            Menu.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 36)
        } else {
            Menu.setScale(0.8)
            Menu.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 45 + (XOffset * 0.75))
        }
        
        self.addChild(Menu)
        
        RainbowRope = SKSpriteNode(imageNamed: RainbowButtonImage)
        
        if !RainbowEnabled {
            RainbowRope.alpha = 0.5
        }
        
        if IS_IPHONE_35 {
            RainbowRope.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 95)
            RainbowRope.setScale(0.5)
        } else if IS_IPHONE_40 {
            RainbowRope.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 110)
            RainbowRope.setScale(0.5)
        } else {
            RainbowRope.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 130 + XOffset)
            RainbowRope.setScale(0.65)
        }
        
        RainbowRope.name = "RainbowSelector"
        
        if !AllChallengesDone {
            RainbowRope.isHidden = true
        }
        
        addChild(RainbowRope)
    }
    
    fileprivate func initChallenges () {
        
        var boxOffset : CGFloat = 190
        
        if IS_IPHONE_35 {
            boxOffset = 135
        } else if IS_IPHONE_40 {
            boxOffset = 167
        } else if IS_IPHONE_X {
            boxOffset = 230
        }
        
        RedTarget = Button(imageNamed: GrayBoxImage)
        RedTargetFill = SKTexture(imageNamed: RedBoxImage)
        RedTarget.position = CGPoint(x: self.frame.minX + 0.2 * self.view!.frame.size.width, y: self.frame.minY + boxOffset)
        RedTarget.setScale(0.6)
        RedTarget.name = "red"
        addChild(RedTarget)
        
        OrangeTarget = Button(imageNamed: GrayBoxImage)
        OrangeTargetFill = SKTexture(imageNamed: OrangeBoxImage)
        OrangeTarget.position = CGPoint(x: self.frame.minX + 0.3 * self.view!.frame.size.width, y: self.frame.minY + boxOffset)
        OrangeTarget.setScale(0.6)
        OrangeTarget.name = "orange"
        addChild(OrangeTarget)
        
        YellowTarget = Button(imageNamed: GrayBoxImage)
        YellowTargetFill = SKTexture(imageNamed: YellowBoxImage)
        YellowTarget.position = CGPoint(x: self.frame.minX + 0.4 * self.view!.frame.size.width, y: self.frame.minY + boxOffset)
        YellowTarget.setScale(0.6)
        YellowTarget.name = "yellow"
        addChild(YellowTarget)
        
        GreenTarget = Button(imageNamed: GrayBoxImage)
        GreenTargetFill = SKTexture(imageNamed: GreenBoxImage)
        GreenTarget.position = CGPoint(x: self.frame.minX + 0.5 * self.view!.frame.size.width, y: self.frame.minY + boxOffset)
        GreenTarget.setScale(0.6)
        GreenTarget.name = "green"
        addChild(GreenTarget)
        
        BlueTarget = Button(imageNamed: GrayBoxImage)
        BlueTargetFill = SKTexture(imageNamed: BlueBoxImage)
        BlueTarget.position = CGPoint(x: self.frame.minX + 0.6 * self.view!.frame.size.width, y: self.frame.minY + boxOffset)
        BlueTarget.setScale(0.6)
        BlueTarget.name = "blue"
        addChild(BlueTarget)
        
        IndigoTarget = Button(imageNamed: GrayBoxImage)
        IndigoTargetFill = SKTexture(imageNamed: IndigoBoxImage)
        IndigoTarget.position = CGPoint(x: self.frame.minX + 0.7 * self.view!.frame.size.width, y: self.frame.minY + boxOffset)
        IndigoTarget.setScale(0.6)
        IndigoTarget.name = "indigo"
        addChild(IndigoTarget)
        
        VioletTarget = Button(imageNamed: GrayBoxImage)
        VioletTargetFill = SKTexture(imageNamed: VioletBoxImage)
        VioletTarget.position = CGPoint(x: self.frame.minX + 0.8 * self.view!.frame.size.width, y: self.frame.minY + boxOffset)
        VioletTarget.setScale(0.6)
        VioletTarget.name = "violet"
        addChild(VioletTarget)
        
        
        if RedDone {
            RedTarget.texture = RedTargetFill
            RedTarget.alpha = 1.0
        }
        
        if OrangeDone {
            OrangeTarget.texture = OrangeTargetFill
        }
        
        if YellowDone {
            YellowTarget.texture = YellowTargetFill
        }
        
        if GreenDone {
            GreenTarget.texture = GreenTargetFill
        }
        
        if BlueDone {
            BlueTarget.texture = BlueTargetFill
        }
        
        if IndigoDone {
            IndigoTarget.texture = IndigoTargetFill
        }
        
        if VioletDone {
            VioletTarget.texture = VioletTargetFill
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var node : SKNode
        var touch : UITouch
        
        touch = touches.first!
        node = self.atPoint(touch.location(in: self))
        
        if node.name == "RainbowSelector" && !RainbowRope.isHidden {
            if !isMuted {
                self.run(ToggleSoundAction)
            }
            
            if RainbowEnabled {
                RainbowEnabled = false
                UserDefaults.standard.set(false, forKey:"Rainbow Rope")
                RainbowRope.alpha = 0.5
                RainbowLabel.text = "Rainbow Rope Off"
            } else {
                RainbowEnabled = true
                UserDefaults.standard.set(true, forKey:"Rainbow Rope")
                RainbowRope.alpha = 1
                RainbowLabel.text = "Rainbow Rope On"
            }
            
            UserDefaults.standard.synchronize()
        }
        
        if node.name == "MenuButton" {
            if !isMuted {
                self.run(PressSoundAction)
            }
            
            Menu.pressed = true
            Menu.texture = MenuPressed
        }
        
        if RedDone && node.name == "red" && !isMuted {
            if !isMuted {
                self.run(AchievementSoundAction)
            }
        }
        
        if OrangeDone && node.name == "orange" && !isMuted {
            if !isMuted {
                self.run(AchievementSoundAction)
            }
        }
        
        if YellowDone && node.name == "yellow" && !isMuted {
            if !isMuted {
                self.run(AchievementSoundAction)
            }
        }
        
        if GreenDone && node.name == "green" && !isMuted {
            if !isMuted {
                self.run(AchievementSoundAction)
            }
        }
        
        if BlueDone && node.name == "blue" && !isMuted {
            if !isMuted {
                self.run(AchievementSoundAction)
            }
        }
        
        if IndigoDone && node.name == "indigo" && !isMuted{
            if !isMuted {
                self.run(AchievementSoundAction)
            }
        }
        
        if VioletDone && node.name == "violet" && !isMuted {
            if !isMuted {
                self.run(AchievementSoundAction)
            }
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        var node : SKNode
        var touch : UITouch
        
        touch = touches.first!
        node = self.atPoint(touch.location(in: self))
        
        if Menu.pressed {
            
            Menu.pressed = false
            
            if node.name == "MenuButton" {
                toMenu()
            } else {
                Menu.texture = SKTexture(imageNamed: MenuButtonImage)
            }
        }
    }
    
    fileprivate func toMenu() {
        
        let menuScene = MenuScene(fileNamed:"MenuScene")
        menuScene?.scaleMode = .aspectFill
        self.view!.presentScene(menuScene)
        
    }
}
