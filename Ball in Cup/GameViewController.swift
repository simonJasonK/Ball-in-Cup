//
//  GameViewController.swift
//  Ball in Cup
//
//  Created by Jason Simon on 7/17/16.
//  Copyright (c) 2016 Jason Simon. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation
import GoogleMobileAds
import NotificationCenter

class GameViewController: UIViewController {
    var menuBannerView: GADBannerView!
    var scoreBannerView: GADBannerView!
    var interstitial: GADInterstitial!
    
    func showMenuBanner() {
        menuBannerView.isHidden = false
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID, "REDACTED"]
        menuBannerView.load(request)
    }
    
    func hideMenuBanner() {
        menuBannerView.isHidden = true
    }
    
    func showScoreBanner() {
        scoreBannerView.isHidden = false
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID, "REDACTED"]
        scoreBannerView.load(request)
    }
    
    func hideScoreBanner() {
        scoreBannerView.isHidden = true
    }
    
    @objc fileprivate func createAndLoadInterstitial() {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-REDACTED")
        let request = GADRequest()
        // Request test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made.
        request.testDevices = [kGADSimulatorID, "REDACTED"]
        interstitial.load(request)
    }
    
    func showInterstitial() {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 9.0, *) {
            // Create a banner ad and add it to the view hierarchy.
            menuBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
            // 1.0.2 NOV. 11, 2017: Added to support safe area of iPhone X display
            addBannerViewToView(menuBannerView)
            menuBannerView.isHidden = true
            menuBannerView.adUnitID = "ca-app-pub-REDACTED"
            menuBannerView.rootViewController = self
            
            // Create a banner ad and add it to the view hierarchy.
            scoreBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
            // 1.0.2 NOV. 11, 2017: Added to support safe area of iPhone X display
            addBannerViewToView(scoreBannerView)
            scoreBannerView.isHidden = true
            scoreBannerView.adUnitID = "ca-app-pub-REDACTED"
            scoreBannerView.rootViewController = self
            
            createAndLoadInterstitial()
            
            NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.showMenuBanner), name: NSNotification.Name(rawValue: "showMenuBanner"), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.hideMenuBanner), name: NSNotification.Name(rawValue: "hideMenuBanner"), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.showScoreBanner), name: NSNotification.Name(rawValue: "showScoreBanner"), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.hideScoreBanner), name: NSNotification.Name(rawValue: "hideScoreBanner"), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.createAndLoadInterstitial), name: NSNotification.Name(rawValue: "initInterstitial"), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.showInterstitial), name: NSNotification.Name(rawValue: "showInterstitial"), object: nil)
        }

        UserDefaults.standard.set(0, forKey:"adConsecutive")
        UserDefaults.standard.synchronize()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print(error)
        }
        
        if let scene = MenuScene(fileNamed:"MenuScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = false
            skView.showsNodeCount = false
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            skView.presentScene(scene)
        }
    }
    
    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    
    // 1.0.2 NOV. 11, 2017: Added to support safe area of iPhone X display
    func addBannerViewToView(_ bannerView: UIView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        if #available(iOS 11.0, *) {
            positionBannerAtTopOfSafeArea(bannerView)
        }
        else {
            positionBannerAtTopOfView(bannerView)
        }
    }
    
    @available (iOS 11, *)
    func positionBannerAtTopOfSafeArea(_ bannerView: UIView) {
        // Position the banner. Stick it to the top of the Safe Area.
        // Centered horizontally.
        let guide: UILayoutGuide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate(
            [bannerView.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
             bannerView.topAnchor.constraint(equalTo: guide.topAnchor)]
        )
    }
    
    func positionBannerAtTopOfView(_ bannerView: UIView) {
        // Center the banner horizontally.
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .centerX,
                                              multiplier: 1,
                                              constant: 0))
        // Lock the banner to the top of the top layout guide.
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self.topLayoutGuide,
                                              attribute: .top,
                                              multiplier: 1,
                                              constant: 0))
    }
}
