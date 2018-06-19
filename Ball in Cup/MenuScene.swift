//
//  MenuScene.swift
//  Ball in Cup
//
//  Created by Jason Simon on 8/2/16.
//  Copyright © 2016 Jason Simon. All rights reserved.
//

import UIKit
import SpriteKit
import Social
import AVFoundation

private var backgroundMusicPlayer: AVAudioPlayer!

class MenuScene: SKScene {

    // UI elements
    fileprivate var Hero: SKSpriteNode!
    fileprivate var Simple: Button!
    fileprivate var SimplePressed: SKTexture!
    fileprivate var Go: Button!
    fileprivate var GoPressed: SKTexture!
    fileprivate var Records: Button!
    fileprivate var RecordsPressed: SKTexture!
    fileprivate var Style: SKSpriteNode!
    fileprivate var ToggleJPN: SKTexture!
    fileprivate var copywrightLabel: SKLabelNode!
    fileprivate var descriptionLabel: SKLabelNode!
    fileprivate var styleLabel: SKLabelNode!
    fileprivate var gameStyle: GameStyle = GameStyle.none
    fileprivate var SimpleButtonImage: String!
    fileprivate var SimplePressedImage: String!
    fileprivate var GoButtonImage: String!
    fileprivate var GoPressedImage: String!
    fileprivate var Sound: SKSpriteNode!
    fileprivate var ToggleLoud: SKTexture!
    fileprivate var ToggleMute: SKTexture!
    fileprivate var justLoaded: Bool = false
    fileprivate var codeGameStyle: Int = UserDefaults.standard.integer(forKey: "style")
    fileprivate var isMuted: Bool = UserDefaults.standard.bool(forKey: "muted")
    
    // Achievement records for notification purposes
    fileprivate var RedDone: Bool = UserDefaults.standard.bool(forKey: "C1")
    fileprivate var OrangeDone: Bool = UserDefaults.standard.bool(forKey: "C2")
    fileprivate var YellowDone: Bool = UserDefaults.standard.bool(forKey: "C3")
    fileprivate var GreenDone: Bool = UserDefaults.standard.bool(forKey: "C4")
    fileprivate var BlueDone: Bool = UserDefaults.standard.bool(forKey: "C5")
    fileprivate var IndigoDone: Bool = UserDefaults.standard.bool(forKey: "C6")
    fileprivate var VioletDone: Bool = UserDefaults.standard.bool(forKey: "C7")
    fileprivate var AllChallengesDone: Bool = UserDefaults.standard.bool(forKey: "All Done")
    
    // populate menu select
    override func didMove(to view: SKView) {
        UIApplication.shared.isIdleTimerDisabled = false
        // Current version of AdMob only works on iOS 9.0 or higher
        if #available(iOS 9.0, *) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "showMenuBanner"), object: nil)
        }
        
        self.scene?.backgroundColor = MagentaColor

        if UserDefaults.standard.integer(forKey: "started") == 0 {
            UserDefaults.standard.set(1, forKey:"started")
            UserDefaults.standard.synchronize()
            initRecords()
        }
        
        UserDefaults.standard.set(0, forKey:"consecutive")
        UserDefaults.standard.synchronize()
        
        if codeGameStyle == 0 {
            gameStyle = GameStyle.latin
        } else if codeGameStyle == 1 {
            gameStyle = GameStyle.japan
        }
        
        switch (gameStyle) {
            case GameStyle.latin:
                SimpleButtonImage = Balero.SimpleButtonImage
                SimplePressedImage = Balero.SimplePressedImage
                GoButtonImage = Balero.GoButtonImage
                GoPressedImage = Balero.GoPressedImage
                break
            case GameStyle.japan:
                SimpleButtonImage = Kendama.SimpleButtonImage
                SimplePressedImage = Kendama.SimplePressedImage
                GoButtonImage = Kendama.GoButtonImage
                GoPressedImage = Kendama.GoPressedImage
                break
            default: break
        }
        
        
        Hero = SKSpriteNode(imageNamed: LogoText)
        
        if IS_IPHONE_X {
            Hero.position = CGPoint(x:self.frame.midX,
                                    y:self.frame.maxY - 125)
        } else if #available(iOS 9.0, *) {
            Hero.position = CGPoint(x:self.frame.midX,
                                    y:self.frame.maxY - 110)
        } else {
            Hero.position = CGPoint(x:self.frame.midX,
                                    y:self.frame.maxY - 45)
        }
        
        
        self.addChild(Hero)
        
        descriptionLabel = SKLabelNode(fontNamed:"Avenir")
        descriptionLabel.fontColor = CreamColor
        descriptionLabel.name = "description"
        descriptionLabel.fontSize = 28
       
        if IS_IPHONE_X {
            descriptionLabel.fontSize = 24
        }
        
        descriptionLabel.text = "Touch to Start, Hold for Details!"
        
        if IS_IPHONE_35 || IS_IPHONE_40 {
            descriptionLabel.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - 180)
        } else if IS_IPHONE_X {
             descriptionLabel.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - 186)
        } else {
            descriptionLabel.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - 183)
        }
        
        self.addChild(descriptionLabel)
        
        copywrightLabel = SKLabelNode(fontNamed:"Avenir")
        copywrightLabel.fontColor = UIColor(red: 1.00, green: 0.99,
                                       blue: 0.81, alpha: 1.0)
        copywrightLabel.name = "copywright"
        copywrightLabel.fontSize = 16
        copywrightLabel.text = "©2016 Jason Simon. All Rights Reserved."
        copywrightLabel.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 15)
        if IS_IPHONE_X {
            copywrightLabel.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 25)
        }
        self.addChild(copywrightLabel)

        styleLabel = SKLabelNode(fontNamed:"Avenir")
        styleLabel.fontColor = CreamColor
        styleLabel.name = "style"
        styleLabel.fontSize = 18
        styleLabel.text = "Switch Modes"
        styleLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 233)
        self.addChild(styleLabel)
        
        if !RedDone {
            styleLabel.isHidden = true
        }
        
        physicsWorld.gravity = CGVector(dx: 0.0,dy: 0.0)
        addButtons()
        setUpAudio()
        
        justLoaded = true
    }
    
    fileprivate func setUpAudio() {
        
        if (backgroundMusicPlayer == nil) {
            
            let backgroundMusicURL = Bundle.main.url(forResource: BackgroundMusicSound, withExtension: nil)
            backgroundMusicPlayer = try? AVAudioPlayer(contentsOf: backgroundMusicURL!)
            backgroundMusicPlayer.numberOfLoops = -1
        }
        
        if (!backgroundMusicPlayer.isPlaying) {
            
            backgroundMusicPlayer.play()
        }
        
        if isMuted {
            backgroundMusicPlayer.pause()
        }
    }
    
    fileprivate func initRecords() {
        
        UserDefaults.standard.set(0, forKey: "Rounds Played")
        UserDefaults.standard.set(Int.max, forKey: "Simple Best")
        UserDefaults.standard.set(0, forKey: "Go2 High")
        UserDefaults.standard.set(Int.max, forKey: "Intense Best")
        UserDefaults.standard.set(0, forKey: "Go5 High")
        UserDefaults.standard.set(0, forKey: "Classic Catches Made")
        UserDefaults.standard.set(0, forKey: "Kendama Catches Made")
        UserDefaults.standard.set(0, forKey: "Strings Broken")
        UserDefaults.standard.set(0, forKey: "Most Consecutive Rounds")
        UserDefaults.standard.set(false, forKey: "C1")
        UserDefaults.standard.set(false, forKey: "C2")
        UserDefaults.standard.set(false, forKey: "C3")
        UserDefaults.standard.set(false, forKey: "C4")
        UserDefaults.standard.set(false, forKey: "C5")
        UserDefaults.standard.set(false, forKey: "C6")
        UserDefaults.standard.set(false, forKey: "C7")
        UserDefaults.standard.set("", forKey: "Date Began")
        UserDefaults.standard.set(false, forKey: "All Done")
        UserDefaults.standard.set(false, forKey: "Rainbow Rope")

        UserDefaults.standard.synchronize()
    }
    
    fileprivate func addButtons() {
        
        Simple = Button(imageNamed: SimpleButtonImage)
        SimplePressed = SKTexture(imageNamed: SimplePressedImage)
        Simple.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 105)
        Simple.name = "SimpleButton"
        addChild(Simple)
        Simple.run(SKAction.repeatForever(SKAction.sequence([FadeOut,
            FadeIn])), withKey: "Fade")
        
        Go = Button(imageNamed: GoButtonImage)
        GoPressed = SKTexture(imageNamed: GoPressedImage)
        Go.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 50)
        Go.name = "GoButton"
        addChild(Go)
        Go.run(SKAction.repeatForever(SKAction.sequence([FadeIn,
            FadeOut])), withKey: "Fade")
        
        Records = Button(imageNamed: RecordsButtonImage)
        RecordsPressed = SKTexture(imageNamed: RecordsPressedImage)
        Records.position = CGPoint(x: self.frame.midX - 30, y: self.frame.minY + 85)
        Records.name = "RecordsButton"
        Records.setScale(0.90)
        if IS_IPHONE_X {
            Records.setScale(0.75)
        }
        addChild(Records)
        
        Style = SKSpriteNode(imageNamed: ToggleLATImage)
        ToggleJPN = SKTexture(imageNamed: ToggleJPNImage)
        
        if gameStyle == GameStyle.japan {
            Style.texture = ToggleJPN
        }
        
        Style.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 185)
        Style.name = "StyleSelector"
        Style.setScale(0.85)
        addChild(Style)
        
        if !RedDone {
            Style.isHidden = true
        }
        
        ToggleLoud = SKTexture(imageNamed: LoudSpeakerImage)
        ToggleMute = SKTexture(imageNamed: MuteSpeakerImage)
        
        if !isMuted {
            Sound = Button(imageNamed: LoudSpeakerImage)
        } else {
            Sound = Button(imageNamed: MuteSpeakerImage)
            Sound.alpha = 0.65
        }
        
        Sound.position = CGPoint(x: self.frame.midX + 167, y: self.frame.minY + 85)
        
        if IS_IPHONE_X {
            Sound.setScale(0.90)
            Sound.position = CGPoint(x: self.frame.midX + 142, y: self.frame.minY + 85)
        }
        
        Sound.name = "SoundSelector"
        addChild(Sound)
    }
    
    // Display details of a given game mode when its button is held down
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var node : SKNode
        var touch : UITouch
        
        touch = touches.first!
        node = self.atPoint(touch.location(in: self))
        
        if node.name == "SimpleButton" && !Go.pressed && !Records.pressed {
            Simple.pressed = true
            Simple.texture = SimplePressed
            Simple.removeAction(forKey: "Fade")
            Simple.run(SKAction.fadeAlpha(to: 1, duration: 0.5))
            descriptionLabel.fontSize = 18
            
            if IS_IPHONE_35 {
                descriptionLabel.fontSize = 21
            } else if IS_IPHONE_X {
                descriptionLabel.fontSize = 15
            }
            
            switch (gameStyle) {
                case GameStyle.latin:
                    descriptionLabel.text = "Simple: Get the ball in the cup as fast as you can!"
                    break
                case GameStyle.japan:
                    descriptionLabel.text = "Intense: Get the ball on the peg as fast as you can!"
                    break
                default: break
            }
            
            if !isMuted {
                self.run(PressSoundAction)
            }
            
        }
        
        if node.name == "GoButton" && !Simple.pressed && !Records.pressed {
            Go.pressed = true
            Go.texture = GoPressed
            Go.removeAction(forKey: "Fade")
            Go.run(SKAction.fadeAlpha(to: 1, duration: 0.5))
            descriptionLabel.fontSize = 18
            
            if IS_IPHONE_35 {
                descriptionLabel.fontSize = 21
            } else if IS_IPHONE_X {
                descriptionLabel.fontSize = 15
            }
            
            switch (gameStyle) {
                case GameStyle.latin:
                    descriptionLabel.text = "Go!: Make as many catches as you can in 2 minutes."
                    break
                case GameStyle.japan:
                    descriptionLabel.text = "Go!: Make as many catches as you can in 5 minutes."
                    break
                default: break
            }
            
            if !isMuted {
                self.run(PressSoundAction)
            }
            
        }
        
        if node.name == "RecordsButton" && !Simple.pressed && !Go.pressed {
            Records.pressed = true
            Records.texture = RecordsPressed
            descriptionLabel.fontSize = 18
            if IS_IPHONE_X {
                descriptionLabel.fontSize = 15
            }
            
            descriptionLabel.text = "Records: High scores, challenges, and more!"
            
            if !isMuted {
                self.run(PressSoundAction)
            }
            
        }
        
        // toggle game style (balero or kendama)
        if node.name == "StyleSelector" && !Style.isHidden && gameStyle == GameStyle.latin {
            Style.texture = ToggleJPN
            gameStyle = GameStyle.japan
        } else if node.name == "StyleSelector" && gameStyle == GameStyle.japan {
            Style.texture = SKTexture(imageNamed: ToggleLATImage)
            gameStyle = GameStyle.latin
        }
        
        if node.name == "StyleSelector" && !Style.isHidden {
            if !isMuted {
                self.run(ToggleSoundAction)
            }
            
            switchStyle()
        }
        
        if node.name == "SoundSelector" && isMuted == false {
            isMuted = true
            UserDefaults.standard.set(true, forKey:"muted")
            UserDefaults.standard.synchronize()
            
            if backgroundMusicPlayer.isPlaying {
                backgroundMusicPlayer.pause()
            }
            
            Sound.texture = ToggleMute
            Sound.alpha = 0.65
        } else if node.name == "SoundSelector" && isMuted == true {
            isMuted = false
            UserDefaults.standard.set(false, forKey:"muted")
            UserDefaults.standard.synchronize()
            
            if !backgroundMusicPlayer.isPlaying {
                backgroundMusicPlayer.play()
            }
            
            Sound.texture = ToggleLoud
            Sound.alpha = 1.0
        }
    }
    
    // go to the desired mode
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        var node : SKNode
        var touch : UITouch
        
        touch = touches.first!
        node = self.atPoint(touch.location(in: self))
        
        if Simple.pressed && !Go.pressed && !Records.pressed {
            
            Simple.pressed = false
            
            if node.name == "SimpleButton" {
                startGame(GameMode.simple)
            } else {
                Simple.texture = SKTexture(imageNamed: SimpleButtonImage)
                Simple.run(SKAction.fadeAlpha(to: 1, duration: 0.5))
                descriptionLabel.fontSize = 28
                if IS_IPHONE_X {
                    descriptionLabel.fontSize = 24
                }
                descriptionLabel.text = "Touch to Start, Hold for Details!"
                Simple.run(SKAction.repeatForever(SKAction.sequence([FadeOut,
                    FadeIn])), withKey: "Fade")
            }
        }
        
        if Go.pressed && !Simple.pressed && !Records.pressed {
            
            Go.pressed = false
            
            if node.name == "GoButton" {
                startGame(GameMode.go)
            } else {
                Go.removeAction(forKey: "Fade")
                Go.run(SKAction.fadeAlpha(to: 1, duration: 0.5))
                Go.texture = SKTexture(imageNamed: GoButtonImage)
                descriptionLabel.fontSize = 28
                if IS_IPHONE_X {
                    descriptionLabel.fontSize = 24
                }
                descriptionLabel.text = "Touch to Start, Hold for Details!"
                Go.run(SKAction.repeatForever(SKAction.sequence([FadeIn,
                    FadeOut])), withKey: "Fade")
            }
        }
        
        if Records.pressed && !Simple.pressed && !Go.pressed {
            
            Records.pressed = false
            
            if node.name == "RecordsButton" {
                toRecords()
            } else {
                Records.removeAction(forKey: "Fade")
                Records.texture = SKTexture(imageNamed: RecordsButtonImage)
                descriptionLabel.fontSize = 28
                if IS_IPHONE_X {
                    descriptionLabel.fontSize = 24
                }
                descriptionLabel.text = "Touch to Start, Hold for Details!"
            }
        }
        
        if Simple.pressed {
            Simple.pressed = false
            Simple.texture = SKTexture(imageNamed: SimpleButtonImage)
            
        }
        
        if Go.pressed {
            Go.pressed = false
            Go.texture = SKTexture(imageNamed: GoButtonImage)
        }
        
        if Records.pressed {
            Records.pressed = false
            Records.texture = SKTexture(imageNamed: RecordsButtonImage)
        }
        
        descriptionLabel.fontSize = 28
        if IS_IPHONE_X {
            descriptionLabel.fontSize = 24
        }
        descriptionLabel.text = "Touch to Start, Hold for Details!"
    }
    
    fileprivate func startGame(_ thisMode: GameMode) {
        
        if backgroundMusicPlayer.isPlaying {
            backgroundMusicPlayer.pause()
        }
        
        let gameScene = GameScene(size: self.view!.bounds.size, mode: thisMode,
                                  style: gameStyle, fromMenu: true)
        self.view!.presentScene(gameScene)

    }
    
    fileprivate func toRecords() {
        let recordsScene = RecordsScene(size: self.view!.bounds.size, style: gameStyle)
        self.view!.presentScene(recordsScene)
    }
    
    func switchStyle () {
        switch (gameStyle) {
            case GameStyle.latin:
                SimpleButtonImage = Balero.SimpleButtonImage
                SimplePressedImage = Balero.SimplePressedImage
                GoButtonImage = Balero.GoButtonImage
                GoPressedImage = Balero.GoPressedImage
                UserDefaults.standard.set(0, forKey:"style")
                UserDefaults.standard.synchronize()
                //styleLabel.text = "Classic Style"
                break
            case GameStyle.japan:
                SimpleButtonImage = Kendama.SimpleButtonImage
                SimplePressedImage = Kendama.SimplePressedImage
                GoButtonImage = Kendama.GoButtonImage
                GoPressedImage = Kendama.GoPressedImage
                UserDefaults.standard.set(1, forKey:"style")
                UserDefaults.standard.synchronize()
                //styleLabel.text = "Kendama Style"
                break
            default: break
        }
        
        Simple.texture = SKTexture(imageNamed: SimpleButtonImage)
        Go.texture = SKTexture(imageNamed: GoButtonImage)
        Records.texture = SKTexture(imageNamed: RecordsButtonImage)
        SimplePressed = SKTexture(imageNamed: SimplePressedImage)
        GoPressed = SKTexture(imageNamed: GoPressedImage)
        RecordsPressed = SKTexture(imageNamed: RecordsPressedImage)
    }
    
    // social integration
    func sendTweet(_ content : String)
    {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter){
            let twitterController:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitterController.setInitialText(content)
            twitterController.add(CompleteImage)
            twitterController.add(URL(string: "www.jajse.com/ballincup"))
            UIApplication.shared.keyWindow?.rootViewController!.present(twitterController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Twitter Account", message: "Please login to your Twitter account.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController!.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func postToFB(_ content : String) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook){
            let facebookController:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookController.add(CompleteImage)
            UIApplication.shared.keyWindow?.rootViewController!.present(facebookController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Facebook Account", message: "Please login to your Facebook account.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController!.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func notifyUser(_ title: String, message: String, socialText: String) {
        
        if !isMuted {
            if (backgroundMusicPlayer.isPlaying) {
                backgroundMusicPlayer.pause()
            }
            
            self.run(AchievementSoundAction)
            backgroundMusicPlayer.play()
        }
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Tweet About It!", style: .default, handler: { action in self.actionHandler(action, socialText: socialText) }))
        alert.addAction(UIAlertAction(title: "Post to Facebook!", style: .default, handler: { action in self.actionHandler(action, socialText: socialText) }))
        alert.addAction(UIAlertAction(title: "Save Celebratory Photo!", style: .default, handler: { action in self.actionHandler(action, socialText: socialText) }))
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in self.actionHandler(action, socialText: socialText) }))
        
        UIApplication.shared.keyWindow?.rootViewController!.present(alert, animated: true,
                                                                                               completion: nil)
    }
    
    func actionHandler(_ action : UIAlertAction, socialText: String) {
        switch action.style{
        case .default:
            if action.title == "Tweet About It!" {
                sendTweet(socialText)
            } else if action.title == "Post to Facebook!" {
                postToFB(socialText)
            } else if CompleteImage != nil && action.title == "Save Celebratory Photo!" {
                UIImageWriteToSavedPhotosAlbum(CompleteImage!, nil, nil, nil)
            }
            
            break
            
        case .cancel:
            break
            
        default: break
            
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if justLoaded && !AllChallengesDone && VioletDone && IndigoDone && BlueDone && GreenDone && YellowDone && OrangeDone && RedDone {
            AllChallengesDone = true
            justLoaded = false
            UserDefaults.standard.set(true, forKey:"All Done")
            UserDefaults.standard.set(true, forKey: "Rainbow Rope")
            UserDefaults.standard.synchronize()
            notifyUser("ALL CHALLENGES CLEARED!",
                       message: "Wow, incredible! You are a Ball in Cup master, which earns you the power of Rainbow Rope!!! Go to Records if you want to switch between Rope styles!",
                       socialText: "I am a master of @BallinCup; cleared every challenge! #BallinCup #AppStore ")
        }
    }
    
}
