//
//  HistoryNavigationViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 8/8/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import GoogleMobileAds

class HistoryNavigationViewController: UINavigationController {
    
    let mainView = HistoryTableViewController()
    
    var theme: Theme! {
        didSet {
            setTheme()
            mainView.theme = theme
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.prefersLargeTitles = true
        loadBannerView()
        pushViewController(mainView, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let theme = theme {
            return theme.dark ? .lightContent : .default
        }
        
        return .default
    }
    
    fileprivate func setTheme() {
        UIView.animate(withDuration: 0.5) {
            self.view.backgroundColor = self.theme.backgroundColor
        }
    }
    
    fileprivate func loadBannerView() {
        let bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-9026572937829340/8501436976"
        bannerView.rootViewController = self
        bannerView.isAutoloadEnabled = true
        toolbar.addSubview(bannerView)
    }
}

extension HistoryNavigationViewController: GADBannerViewDelegate {
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        UIView.animate(withDuration: 0.5) {
            self.isToolbarHidden = false
        }
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        isToolbarHidden = true
    }
}
