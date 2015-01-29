//
//  FGBannerPresentController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/13/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreGraphics

class FGBannerPresentController : BuspassEventListener {

    let BANNER_HEIGHT = CGFloat(40)
    
    weak var api : BuspassApi!
    weak var masterMapScreen : MasterMapScreen!
    weak var masterController : MasterController!
    
    init(masterMapScreen : MasterMapScreen) {
        self.masterMapScreen = masterMapScreen
        self.masterController = masterMapScreen.masterController
        self.api = masterMapScreen.api
        registerForEvents()
        
    }
    
    func registerForEvents() {
        api.uiEvents.registerForEvent("BannerPresent:display", listener: self)
        api.uiEvents.registerForEvent("BannerPresent:dismiss", listener: self)
        api.uiEvents.registerForEvent("BannerPresent:webDisplay", listener: self)
    }
    
    
    func unregisterForEvents() {
        api.uiEvents.unregisterForEvent("BannerPresent:display", listener: self)
        api.uiEvents.unregisterForEvent("BannerPresent:dismiss", listener: self)
        api.uiEvents.unregisterForEvent("BannerPresent:webDisplay", listener: self)
    }
    
    
    func onBuspassEvent(event: BuspassEvent) {
        let eventData = event.eventData as? BannerEventData
        if eventData != nil {
            if event.eventName == "BannerPresent:display" {
                presentBanner(eventData!);
            } else if event.eventName == "BannerPresent:dismiss" {
                abandonBanner(eventData!);
            } else if event.eventName == "BannerPresent:webDisplay" {
                onWebDisplay(eventData!);
            }
        }
    }
    
    private var currentBanner : UIBanner?
    func presentBanner(eventData : BannerEventData) {
        let newBanner = UIBanner(bannerInfo: eventData.bannerInfo, masterMapScreen: masterMapScreen)
        newBanner.view.frame = CGRect(x: -masterMapScreen.view.frame.size.width, y: CGFloat(masterMapScreen.view.frame.size.height - BANNER_HEIGHT), width: CGFloat(masterMapScreen.view.frame.size.width), height: BANNER_HEIGHT)
        if (currentBanner != nil) {
            let banner = currentBanner!
            self.currentBanner = newBanner
            masterMapScreen.view.addSubview(currentBanner!.view)
            banner.slide_out({(finished: Bool) in
                banner.removeFromParentViewController()
                self.currentBanner!.slide_in({(x) in })
            })
        } else {
            self.currentBanner = newBanner
            masterMapScreen.view.addSubview(currentBanner!.view)
            self.currentBanner!.slide_in({(x) in })
        }
    }
    
    private var abandonedBanners : [UIBanner] = [UIBanner]()
    private func clearBanners() {
        while(!abandonedBanners.isEmpty) {
            let banner : UIBanner? = abandonedBanners.removeLast()
            if (banner != nil) {
                banner!.removeFromParentViewController()
            }
        }
    }
    
    func abandonBanner(eventData : BannerEventData) {
        if currentBanner != nil {
            let banner = currentBanner!
            self.currentBanner = nil
            if eventData.bannerInfo === banner.bannerInfo {
                banner.slide_out({(y) in
                    banner.removeFromParentViewController()
                })
            }

        }
    }
    
    func onWebDisplay(eventData : BannerEventData) {
        if currentBanner != nil {
            let banner = currentBanner!
            if banner.bannerInfo === eventData.bannerInfo {
                banner.displayWebPage(eventData.thruUrl)
                abandonBanner(eventData)
            }
        }
    }
}
