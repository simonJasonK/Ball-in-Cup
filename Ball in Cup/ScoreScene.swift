//
//  ScoreScene.swift
//  Ball in Cup
//
//  Created by Jason Simon on 8/4/16.
//  Copyright © 2016 Jason Simon. All rights reserved.
//

import UIKit
import SpriteKit
import Social

class ScoreScene: SKScene {
        
    fileprivate var realScore: Int!
    fileprivate var realScoreStr: String!
    fileprivate var highScoreLabel: SKLabelNode!
    fileprivate var scoreLabel: SKLabelNode!
    fileprivate var gameScore: String!
    fileprivate var catchesScore: SKLabelNode!
    fileprivate var breaksScore: SKLabelNode!
    fileprivate var catchesScoreStr: String!
    fileprivate var breaksScoreStr: String!
    fileprivate var Game: Button!
    fileprivate var GamePressed: SKTexture!
    fileprivate var Menu: Button!
    fileprivate var MenuPressed: SKTexture!
    fileprivate var Facebook: SKSpriteNode!
    fileprivate var Twitter: SKSpriteNode!
    fileprivate var Hero: SKSpriteNode!
    fileprivate var parentMode: GameMode = GameMode.none
    fileprivate var parentStyle: GameStyle = GameStyle.none
    fileprivate var GameButtonImage: String!
    fileprivate var GamePressedImage: String!
    fileprivate var MenuButtonImage: String!
    fileprivate var MenuPressedImage: String!
    
    fileprivate var socFlavorText: String!
        
    fileprivate var justLoaded: Bool = false
    fileprivate var isMuted: Bool = UserDefaults.standard.bool(forKey: "muted")
    
    fileprivate var RedDone: Bool = UserDefaults.standard.bool(forKey: "C1")
    fileprivate var OrangeDone: Bool = UserDefaults.standard.bool(forKey: "C2")
    fileprivate var YellowDone: Bool = UserDefaults.standard.bool(forKey: "C3")
    fileprivate var GreenDone: Bool = UserDefaults.standard.bool(forKey: "C4")
    fileprivate var BlueDone: Bool = UserDefaults.standard.bool(forKey: "C5")
    fileprivate var IndigoDone: Bool = UserDefaults.standard.bool(forKey: "C6")
    fileprivate var VioletDone: Bool = UserDefaults.standard.bool(forKey: "C7")
    
    init(size: CGSize, score: String, mode: GameMode, style: GameStyle) {
        super.init(size: size)
        gameScore = score
        parentMode = mode
        parentStyle = style
        socFlavorText = ""
        
        switch (parentStyle) {
            case GameStyle.latin:
                MenuButtonImage = Balero.MenuButtonImage
                MenuPressedImage = Balero.MenuPressedImage
                GameButtonImage = Balero.GameButtonImage
                GamePressedImage = Balero.GamePressedImage
                break
            case GameStyle.japan:
                MenuButtonImage = Kendama.MenuButtonImage
                MenuPressedImage = Kendama.MenuPressedImage
                GameButtonImage = Kendama.GameButtonImage
                GamePressedImage = Kendama.GamePressedImage
                break
            default: break
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // social integration
    func sendTweet(_ content : String) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter){
            let twitterController:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitterController.setInitialText(content)
            twitterController.add(AdvertImage)
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
            facebookController.add(AdvertImage)
            UIApplication.shared.keyWindow?.rootViewController!.present(facebookController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Facebook Account", message: "Please login to your Facebook account.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController!.present(alert, animated: true, completion: nil)
        }
        
    }
    
    // Achievement unlocked
    func notifyUser(_ title: String, message: String, socialText: String) {
        
        if !isMuted {
            self.run(AchievementSoundAction)
        }
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Tweet About It!", style: .default, handler: { action in self.actionHandler(action, socialText: socialText) }))
        alert.addAction(UIAlertAction(title: "Post to Facebook!", style: .default, handler: { action in self.actionHandler(action, socialText: socialText) }))
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in self.actionHandler(action, socialText: socialText) }))
        
        UIApplication.shared.keyWindow?.rootViewController!.present(alert, animated: true,
                                                                                               completion: nil)
    }
    
    func actionHandler(_ action : UIAlertAction, socialText: String) {
        switch action.style{
        case .default:
            if action.title == "Tweet About It!" {
                sendTweet(socialText)
            } else {
                postToFB(socialText)
            }
            
            break
            
        case .cancel:
            break
            
        default: break
            
        }
    }
    
    override func didMove(to view: SKView) {
        UIApplication.shared.isIdleTimerDisabled = true
        self.scene?.backgroundColor = MagentaColor
        if #available(iOS 9.0, *) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "showScoreBanner"), object: nil)
        }
        
        var pivoted: Bool = false // for parsing purposes
        
        let adNumConsec = UserDefaults.standard.integer(forKey: "adConsecutive")
        if RedDone && (adNumConsec % 5) == 4 {
            if #available(iOS 9.0, *) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "showInterstitial"), object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "initInterstitial"), object: nil)
            }
            
            UserDefaults.standard.set(0, forKey:"adConsecutive")
        }
        
        UserDefaults.standard.synchronize()
        
        Hero = SKSpriteNode(imageNamed: ScoreHeaderText)
        
        if IS_IPHONE_X {
            Hero.position = CGPoint(x:self.frame.midX,
                                   y:self.frame.maxY - 150)
        } else if #available(iOS 9.0, *) {
            Hero.position = CGPoint(x:self.frame.midX,
                                    y:self.frame.maxY - 100)
        } else {
            Hero.position = CGPoint(x:self.frame.midX,
                                    y:self.frame.maxY - 45)
        }
        
        self.addChild(Hero)
        
        catchesScore = SKLabelNode(fontNamed:"Avenir")
        catchesScore.fontColor = CreamColor
        catchesScore.name = "catches"
        
        breaksScore = SKLabelNode(fontNamed:"Avenir")
        breaksScore.fontColor = CreamColor
        breaksScore.name = "breaks"
        
        scoreLabel = SKLabelNode(fontNamed:"Avenir")
        scoreLabel.fontColor = CreamColor
        scoreLabel.name = "score"
        
        highScoreLabel = SKLabelNode(fontNamed:"Avenir")
        highScoreLabel.fontColor = CreamColor
        highScoreLabel.name = "high-score"
        highScoreLabel.fontSize = 16
        highScoreLabel.text = "High Score!"
        highScoreLabel.isHidden = true
        
        if IS_IPHONE_35 || IS_IPHONE_40 {
            catchesScore.fontSize = 18
            breaksScore.fontSize = 18
        } else {
            catchesScore.fontSize = 24
            breaksScore.fontSize = 24
        }
        
        if IS_IPHONE_35 || IS_IPHONE_40 {
            scoreLabel.fontSize = 28
        } else {
            scoreLabel.fontSize = 45
        }
        
        switch (parentMode) {
            /* Check high scores and update records (lots of redundancies here,
               due to the different game modes' having subtleties in how
               to update the records. */
            case GameMode.simple:
                if IS_IPHONE_35 || IS_IPHONE_40 {
                    scoreLabel.position = CGPoint(x:self.frame.midX, y:self.frame.midY + 60)
                    highScoreLabel.position = CGPoint(x:self.frame.midX, y:self.frame.midY + 40)
                } else {
                    scoreLabel.position = CGPoint(x:self.frame.midX, y:self.frame.midY + 95)
                    highScoreLabel.position = CGPoint(x:self.frame.midX, y:self.frame.midY + 70)
                }
                
                if (gameScore == "Sorry, Time's Up!" || gameScore == "Your String Broke!" ||
                    gameScore == "Try Again!") {
                    socFlavorText = "I'm having a blast playing @BallinCup! You try now! #BallinCup #AppStore"
                    if !isMuted {
                        self.run(GameOverSoundAction)
                    }
                    
                    if (gameScore == "Your String Broke!") {
                        let stringsBroken = UserDefaults.standard.integer(forKey: "Strings Broken")
                        UserDefaults.standard.set(stringsBroken + 1, forKey:"Strings Broken")

                    }
                    scoreLabel.fontSize = 36
                    
                    if IS_IPHONE_35 || IS_IPHONE_40 {
                        scoreLabel.fontSize = 24
                    }
                    
                    scoreLabel.text = gameScore
                } else {
                    scoreLabel.text = ""
                    realScoreStr = ""
                    for letter in gameScore.characters {
                        if letter == "|" {
                            pivoted = true
                        } else if !pivoted {
                            realScoreStr = realScoreStr + String(letter)
                        } else {
                            scoreLabel.text = scoreLabel.text! + String(letter)
                        }
                    }
                    realScore = Int(realScoreStr)
                    
                    if gameScore.range(of: ":") == nil {
                        scoreLabel.text = scoreLabel.text! + " s"
                    }
                    
                    socFlavorText = "Just got a time of " + scoreLabel.text! + " in @BallinCup! Try it! #BallinCup #AppStore"
                    
                    scoreLabel.text = "Time: " + scoreLabel.text!
                    
                    // high score checks
                    if parentStyle == GameStyle.latin {
                        let oldHighScore = UserDefaults.standard.integer(forKey: "Simple Best")
                        let catchesMade = UserDefaults.standard.integer(forKey: "Classic Catches Made")
                        UserDefaults.standard.set(catchesMade + 1, forKey:"Classic Catches Made")
                        
                        if oldHighScore > Int(realScore) {
                            socFlavorText = socFlavorText + " #highscore"
                            highScoreLabel.isHidden = false
                            highScoreLabel.run(SKAction.repeatForever(SKAction.sequence([FastFadeOut,
                                FastFadeIn])), withKey: "Fade")
                            UserDefaults.standard.set(Int(realScore), forKey:"Simple Best")

                        }
                    } else if parentStyle == GameStyle.japan {
                        let oldHighScore = UserDefaults.standard.integer(forKey: "Intense Best")
                        let catchesMade = UserDefaults.standard.integer(forKey: "Kendama Catches Made")
                        UserDefaults.standard.set(catchesMade + 1, forKey:"Kendama Catches Made")
                        
                        if oldHighScore > Int(realScore) {
                            socFlavorText = socFlavorText + " #highscore"
                            highScoreLabel.isHidden = false
                            highScoreLabel.run(SKAction.repeatForever(SKAction.sequence([FastFadeOut,
                                FastFadeIn])), withKey: "Fade")
                            UserDefaults.standard.set(Int(realScore), forKey:"Intense Best")
                            
                        }
                    }
                    
                    if UserDefaults.standard.integer(forKey: "played") == 0 {
                        UserDefaults.standard.set(1, forKey:"played")
                        
                        UserDefaults.standard.set(String(DateFormatter.localizedString(
                            from: Date(), dateStyle: .medium, timeStyle: .short)), forKey: "Date Began")
                        
                        UserDefaults.standard.set(true, forKey: "C1")
                        UserDefaults.standard.synchronize()
                    }
            
                }
                break
            case GameMode.go:
                if (gameScore == "Try Again!") {
                    if !isMuted {
                        self.run(GameOverSoundAction)
                    }
                    socFlavorText = "Having a blast playing the time attack mode of @BallinCup! #BallinCup #AppStore"
                    if IS_IPHONE_35 || IS_IPHONE_40 {
                        scoreLabel.fontSize = 24
                        scoreLabel.position = CGPoint(x:self.frame.midX, y:self.frame.midY + 60)
                    } else {
                        scoreLabel.fontSize = 36
                        scoreLabel.position = CGPoint(x:self.frame.midX, y:self.frame.midY + 95)
                    }
                    
                    scoreLabel.text = gameScore
                    break
                }
                
                if IS_IPHONE_35 || IS_IPHONE_40 {
                    catchesScore.position = CGPoint(x:self.frame.midX, y:self.frame.midY + 80)
                    breaksScore.position = CGPoint(x:self.frame.midX, y:self.frame.midY + 60)
                    scoreLabel.position = CGPoint(x:self.frame.midX, y:self.frame.midY + 15)
                    highScoreLabel.position = CGPoint(x:self.frame.midX, y:self.frame.midY - 15)
                } else {
                    catchesScore.position = CGPoint(x:self.frame.midX, y:self.frame.midY + 135)
                    breaksScore.position = CGPoint(x:self.frame.midX, y:self.frame.midY + 95)
                    scoreLabel.position = CGPoint(x:self.frame.midX, y:self.frame.midY + 20)
                    highScoreLabel.position = CGPoint(x:self.frame.midX, y:self.frame.midY - 10)

                }
                
                catchesScore.text = "Catches: "
                breaksScore.text = "Strings Broken: "
                catchesScoreStr = ""
                breaksScoreStr = ""
                for letter in gameScore.characters {
                    if letter == "|" {
                        pivoted = true
                    } else if !pivoted {
                        catchesScore.text = catchesScore.text! + String(letter)
                        catchesScoreStr = catchesScoreStr + String(letter)
                    } else {
                        breaksScore.text = breaksScore.text! + String(letter)
                        breaksScoreStr = breaksScoreStr + String(letter)
                    }
                }
                
                catchesScore.text = catchesScore.text! + " (*10)"
                breaksScore.text = breaksScore.text! + " (* -5)"
                realScore = max(0, 10 * Int(catchesScoreStr)! - 5 * Int(breaksScoreStr)!)
                realScoreStr = String(realScore)
                scoreLabel.text = "Score: " + realScoreStr
                
                socFlavorText = "Just got a score of " + realScoreStr + " in time attack mode of @BallinCup! #BallinCup #AppStore"
                
                let stringsBroken = UserDefaults.standard.integer(forKey: "Strings Broken")
                UserDefaults.standard.set(stringsBroken + Int(breaksScoreStr)!, forKey:"Strings Broken")
                
                // high score checks
                if parentStyle == GameStyle.latin {
                    let oldHighScore = UserDefaults.standard.integer(forKey: "Go2 High")
                    let catchesMade = UserDefaults.standard.integer(forKey: "Classic Catches Made")
                    UserDefaults.standard.set(catchesMade + Int(catchesScoreStr)!, forKey:"Classic Catches Made")
                    
                    if oldHighScore < Int(realScore) {
                        socFlavorText = socFlavorText + " #highscore"
                        highScoreLabel.isHidden = false
                        highScoreLabel.run(SKAction.repeatForever(SKAction.sequence([FastFadeOut,
                            FastFadeIn])), withKey: "Fade")
                        UserDefaults.standard.set(Int(realScore), forKey:"Go2 High")
                        
                    }
                } else if parentStyle == GameStyle.japan {
                    let oldHighScore = UserDefaults.standard.integer(forKey: "Go5 High")
                    let catchesMade = UserDefaults.standard.integer(forKey: "Kendama Catches Made")
                    UserDefaults.standard.set(catchesMade + Int(catchesScoreStr)!, forKey:"Kendama Catches Made")
                    
                    if oldHighScore < Int(realScore) {
                        socFlavorText = socFlavorText + " #highscore"
                        highScoreLabel.isHidden = false
                        highScoreLabel.run(SKAction.repeatForever(SKAction.sequence([FastFadeOut,
                            FastFadeIn])), withKey: "Fade")
                        UserDefaults.standard.set(Int(realScore), forKey:"Go5 High")
                        
                    }
                }
                
                if UserDefaults.standard.integer(forKey: "played") == 0 {
                    UserDefaults.standard.set(1, forKey:"played")
                    
                    UserDefaults.standard.set(DateFormatter.localizedString(
                        from: Date(), dateStyle: .medium, timeStyle: .short), forKey: "Date Began")
                    
                    UserDefaults.standard.set(true, forKey: "C1")
                    UserDefaults.standard.synchronize()
                }
                
                break
            default: break
        }
        
        self.addChild(catchesScore)
        self.addChild(breaksScore)
        self.addChild(scoreLabel)
        self.addChild(highScoreLabel)
        
        let numConsec = UserDefaults.standard.integer(forKey: "consecutive")
        let maxConsec = UserDefaults.standard.integer(forKey: "Most Consecutive Rounds")
        
        if numConsec > maxConsec {
            UserDefaults.standard.set(numConsec, forKey:"Most Consecutive Rounds")
        }
        
        UserDefaults.standard.synchronize()
        
        physicsWorld.gravity = CGVector(dx: 0.0,dy: 0.0)
        addButtons()
        justLoaded = true
    }
    
    // populate with UI elements
    fileprivate func addButtons() {
        Game = Button(imageNamed: GameButtonImage)
        GamePressed = SKTexture(imageNamed: GamePressedImage)
        Game.name = "GameButton"
        
        Menu = Button(imageNamed: MenuButtonImage)
        MenuPressed = SKTexture(imageNamed: MenuPressedImage)
        Menu.name = "MenuButton"
        
        Facebook = Button(imageNamed: FacebookButtonImage)
        Facebook.name = "FacebookButton"
        
        Twitter = Button(imageNamed: TwitterButtonImage)
        Twitter.name = "TwitterButton"
        
        if IS_IPHONE_35 || IS_IPHONE_40 {
            Facebook.setScale(0.7)
            Twitter.setScale(0.7)
            Game.setScale(0.7)
            Menu.setScale(0.7)
        }
        
        switch (parentMode) {
            case GameMode.simple:
                if IS_IPHONE_35 || IS_IPHONE_40 {
                    Facebook.position = CGPoint(x: self.frame.minX + 0.25 * self.view!.frame.size.width, y: self.frame.midY - 7)
                    Twitter.position = CGPoint(x: self.frame.maxX - 0.25 * self.view!.frame.size.width, y: self.frame.midY - 7)
                    Game.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 100)
                    Menu.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 195)
                } else {
                    Facebook.position = CGPoint(x: self.frame.minX + 0.25 * self.view!.frame.size.width, y: self.frame.midY + 10)
                    Twitter.position = CGPoint(x: self.frame.maxX - 0.25 * self.view!.frame.size.width, y: self.frame.midY + 10)
                    Game.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 110)
                    Menu.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 230)
                }
                break
            case GameMode.go:
                if IS_IPHONE_35 || IS_IPHONE_40 {
                    Game.setScale(0.65)
                    Menu.setScale(0.65)
                    Facebook.position = CGPoint(x: self.frame.minX + 0.25 * self.view!.frame.size.width, y: self.frame.midY - 48)
                    Twitter.position = CGPoint(x: self.frame.maxX - 0.25 * self.view!.frame.size.width, y: self.frame.midY - 48)
                    Game.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 135)
                    Menu.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 205)
                } else {
                    Facebook.position = CGPoint(x: self.frame.minX + 0.25 * self.view!.frame.size.width, y: self.frame.midY - 57)
                    Twitter.position = CGPoint(x: self.frame.maxX - 0.25 * self.view!.frame.size.width, y: self.frame.midY - 57)
                    Game.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 160)
                    Menu.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 280)
                }
                break
            default: break
        }
        
        addChild(Game)
        addChild(Menu)
        addChild(Facebook)
        addChild(Twitter)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var node : SKNode
        var touch : UITouch
        
        touch = touches.first!
        node = self.atPoint(touch.location(in: self))
        if node.name == "FacebookButton" {
            if !isMuted {
                self.run(PressSoundAction)
            }
            postToFB(socFlavorText)
        } else if node.name == "TwitterButton" {
            if !isMuted {
                self.run(PressSoundAction)
            }
            sendTweet(socFlavorText)
        } else if node.name == "GameButton" {
            if !isMuted {
                self.run(PressSoundAction)
            }
            Game.pressed = true
            Game.texture = GamePressed
        } else if node.name == "MenuButton" {
            if !isMuted {
                self.run(PressSoundAction)
            }
            Menu.pressed = true
            Menu.texture = MenuPressed
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        var node : SKNode
        var touch : UITouch
        
        touch = touches.first!
        node = self.atPoint(touch.location(in: self))
        
        if Game.pressed && !Menu.pressed {
            
            Game.pressed = false
            
            if node.name == "GameButton" {
                toGame()
            } else {
                Game.texture = SKTexture(imageNamed: GameButtonImage)
            }
        } else if !Game.pressed && Menu.pressed {
            
            Menu.pressed = false
            
            if node.name == "MenuButton" {
                toMenu()
            } else {
                Menu.texture = SKTexture(imageNamed: MenuButtonImage)
            }
        } else if Game.pressed && Menu.pressed {
            Game.pressed = false
            Menu.pressed = false
            Game.texture = SKTexture(imageNamed: GameButtonImage)
            Menu.texture = SKTexture(imageNamed: MenuButtonImage)
        }
    }
    
    fileprivate func toMenu() {
        if #available(iOS 9.0, *) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "hideScoreBanner"), object: nil)
        }
        
        let menuScene = MenuScene(fileNamed:"MenuScene")
        menuScene?.scaleMode = .aspectFill
        self.view!.presentScene(menuScene)
        
    }

    
    fileprivate func toGame() {
        if #available(iOS 9.0, *) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "hideScoreBanner"), object: nil)
        }
        
        let gameScene = GameScene(size: self.view!.bounds.size, mode: parentMode, style: parentStyle, fromMenu: false)
        self.view!.presentScene(gameScene)
        
    }
    
    // Check if player unlocked any achievements
    fileprivate func checkForChallenges() -> Void {
        if !RedDone && UserDefaults.standard.integer(forKey: "played") == 1 {
            RedDone = true
            UserDefaults.standard.set(true, forKey: "C1")
            UserDefaults.standard.set(3, forKey:"adConsecutive")
            notifyUser("Red Challenge Cleared!", message: "You completed your first round and have unlocked the harder Red Modes! For more challenges, see the Records screen.", socialText: "Just cleared the Red Challenge in @BallinCup on the #AppStore! #BallinCup")
        }
        
        if !IndigoDone && UserDefaults.standard.integer(forKey: "consecutive") >= 15 { // 10 debug
            IndigoDone = true
            UserDefaults.standard.set(true, forKey: "C6")
            notifyUser("Indigo Challenge Cleared!", message: "You just played 15 rounds of a single mode in a row...that takes devotion!",
                       socialText: "Just conquered the Indigo Challenge in @BallinCup on the #AppStore! #BallinCup")
        }
        
        if !VioletDone && UserDefaults.standard.integer(forKey: "Rounds Played") >= 150 { // 100 debug
            VioletDone = true
            UserDefaults.standard.set(true, forKey: "C7")
            notifyUser("Violet Challenge Cleared!", message: "You've completed 150 rounds! Here's to your sesquicentennial!",
                       socialText: "Just finished the Violet Challenge in @BallinCup on the #AppStore! #BallinCup")
        }
        
        if realScore != nil {
        
            if !OrangeDone && realScore <= 12 && parentMode == GameMode.simple && parentStyle == GameStyle.latin { //13 debug
                OrangeDone = true
                UserDefaults.standard.set(true, forKey: "C2")
                notifyUser("Orange Challenge Cleared!", message: "You got a time of 1.2 s or less in Simple Mode!",
                           socialText: "Master of easy mode and the Orange Challenge in #BallinCup! @BallinCup #AppStore")
            }
            
            if !YellowDone && realScore >= 900 && parentMode == GameMode.go && parentStyle == GameStyle.latin { // 210 debug
                YellowDone = true
                UserDefaults.standard.set(true, forKey: "C3")
                notifyUser("Yellow Challenge Cleared!", message: "You got a score of at least 900 in Go! 2:00 Mode!",
                           socialText: "Yellow Challenge: Check! #BallinCup @BallinCup #AppStore")
            }
            
            if !GreenDone && realScore <= 30 && parentMode == GameMode.simple && parentStyle == GameStyle.japan { // 60 debug
                GreenDone = true
                UserDefaults.standard.set(true, forKey: "C4")
                notifyUser("Green Challenge Cleared!", message: "You got a time of 3.0 s or less in Intense Mode. Nice!",
                           socialText: "Finished the Green Challenge in @BallinCup! #BallinCup #AppStore")
            }
        
            if !BlueDone && realScore >= 180 && parentMode == GameMode.go && parentStyle == GameStyle.japan { // 60 debug
                BlueDone = true
                UserDefaults.standard.set(true, forKey: "C5")
                notifyUser("Blue Challenge Cleared!", message: "You got a score of at least 180 in Go! 5:00 Mode. You're getting good at this!",
                           socialText: "Sayonara, Blue Challenge of Ball in Cup! @BallinCup #AppStore #BallinCup")
            }
        }
        
        UserDefaults.standard.synchronize()
        return

    }
    
    override func update(_ currentTime: TimeInterval) {
        if justLoaded {
            justLoaded = false
            checkForChallenges()
        }
    }
}
