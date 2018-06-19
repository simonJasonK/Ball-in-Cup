//
//  Constants.swift
//  Ball in Cup
//
//  Created by Jason Simon on 7/18/16. 
//  Copyright (c) 2016 Jason Simon. All rights reserved.
//

/** Keeps commonly used references in one place to streamline edits */
import UIKit
import SpriteKit

let scale = UIScreen.main.scale;
var result = CGSize(width: UIScreen.main.bounds.size.width * scale, height: UIScreen.main.bounds.size.height * scale);

// macros to determine which phone the user has
// VERSION 1.0.1 UPDATE: Works with zoom view for 4.7" and 5.5" (Credit Azzhao)
// VERSION 1.0.2 UPDATE: Turns out 5.5" zoom was still broken; fixed (Credit Wzhu)
// VERSION 1.0.3 UPDATE: iPhone X Compatibility

let IS_IPHONE_35 = result.height == 960.0 ? true : false
let IS_IPHONE_40 = result.height == 1136.0 ? true : false
let IS_IPHONE_47 = (result.height == 1334.0 || result.height == 2001.0) ? true : false
let IS_IPHONE_55 = result.height == 2208.0 ? true : false
let IS_IPHONE_X = result.height == 2436.0 ? true : false

// game elements
let BackgroundImage = "Background"
let RopeTextureImage = "RopeTexture"
let RopeHolderImage = "RopeHolder"

// UI elements

struct Balero {
    static let SimpleButtonImage = "SimpleButtonLAT"
    static let SimplePressedImage = "SimplePressedLAT"
    static let GoButtonImage = "GoButtonLAT"
    static let GoPressedImage = "GoPressedLAT"
    static let MenuButtonImage = "MenuButtonLAT"
    static let MenuPressedImage = "MenuPressedLAT"
    static let GameButtonImage = "GameButtonLAT"
    static let GamePressedImage = "GamePressedLAT"
    static let EndButtonImage = "EndButtonLAT"
    static let EndPressedImage = "EndPressedLAT"
    static let BallImage = "Ball"
    static let CupImage = "Cup"

}

struct Kendama {
    static let SimpleButtonImage = "SimpleButtonJPN"
    static let SimplePressedImage = "SimplePressedJPN"
    static let GoButtonImage = "GoButtonJPN"
    static let GoPressedImage = "GoPressedJPN"
    static let MenuButtonImage = "MenuButtonJPN"
    static let MenuPressedImage = "MenuPressedJPN"
    static let GameButtonImage = "GameButtonJPN"
    static let GamePressedImage = "GamePressedJPN"
    static let EndButtonImage = "EndButtonJPN"
    static let EndPressedImage = "EndPressedJPN"
    static let BallImage = "JapanBall"
    static let CupImage = "JapanCup"
}

let RecordsButtonImage = "RecordsButton"
let RecordsPressedImage = "RecordsPressed"
let ToggleLATImage = "ToggleLAT"
let ToggleJPNImage = "ToggleJPN"
let LoudSpeakerImage = "LoudSpeaker"
let MuteSpeakerImage = "MuteSpeaker"
let FacebookButtonImage = "FacebookButton"
let TwitterButtonImage = "TwitterButton"
let RainbowButtonImage = "RainbowButton"

// Text
let LogoText = "Logo"
let ScoreHeaderText = "ScoreHeader"
let RecordsHeaderText = "RecordsHeader"
let AllClearText = "AllClearImage"

// Sound effects
let BackgroundMusicSound = "Menu.caf"
let ToggleSound = "Toggle.caf"
let PressSound = "Press.caf"
let AchievementSound = "Achievement.caf"
let GameOverSound = "GameOver.caf"
let PositiveSound = "Positive.caf"
let NegativeSound = "Negative.caf"
let ChimeSound = "Chime.caf"

let ToggleSoundAction = SKAction.playSoundFileNamed(ToggleSound, waitForCompletion: false)
let PressSoundAction = SKAction.playSoundFileNamed(PressSound, waitForCompletion: false)
let AchievementSoundAction = SKAction.playSoundFileNamed(AchievementSound, waitForCompletion: false)
let GameOverSoundAction = SKAction.playSoundFileNamed(GameOverSound, waitForCompletion: false)
let PositiveSoundAction = SKAction.playSoundFileNamed(PositiveSound, waitForCompletion: false)
let NegativeSoundAction = SKAction.playSoundFileNamed(NegativeSound, waitForCompletion: false)
let ChimeSoundAction = SKAction.playSoundFileNamed(ChimeSound, waitForCompletion: false)

// Blocks
let GrayBoxImage = "GrayBox"
let RedBoxImage = "RedBox"
let OrangeBoxImage = "OrangeBox"
let YellowBoxImage = "YellowBox"
let GreenBoxImage = "GreenBox"
let BlueBoxImage = "BlueBox"
let IndigoBoxImage = "IndigoBox"
let VioletBoxImage = "VioletBox"

let CreamColor = UIColor(red: 1.00, green: 0.99,
                         blue: 0.81, alpha: 1.0)

let MagentaColor = UIColor(red: 0.42, green: 0.65,
                           blue: 0.76, alpha: 1.0)

// Fade In
let FadeIn = SKAction.fadeAlpha(to: 0.85, duration: 0.5)

// Fade Out
let FadeOut = SKAction.fadeAlpha(to: 0.35, duration: 0.5)

// Fast Fade In
let FastFadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.25)

// Fast Fade Out
let FastFadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.25)

// All Challenges Complete image
let CompleteImage = UIImage(named: "Winner.png")
let AdvertImage = UIImage(named: "Advert.png")

enum GameMode {
    case none
    case simple
    case go
}

enum GameStyle {
    case none
    case latin
    case japan
}

struct Category {
    static let Cup: UInt32 = 1
    static let RopeHolder: UInt32 = 2
    static let Rope: UInt32 = 4
    static let Ball: UInt32 = 8
}
