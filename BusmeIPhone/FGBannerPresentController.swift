//
//  FGBannerPresentController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/13/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class FGBannerPresentController : BuspassEventListener {

    weak var api : BuspassApi!
    weak var masterMapScreen : MasterMapScreen!
    weak var masterController : MasterController!
    
    public init(masterMapScreen : MasterMapScreen) {
        self.masterMapScreen = masterMapScreen
        self.masterController = masterMapScreen.masterController
        self.api = masterMapScreen.api
    }
    
    
    
    public func onBuspassEvent(event: BuspassEvent) {
        let eventData = event.eventData as? BannerEventData
        if eventData != nil {
            if event.eventName == "BannerPresent:display" {
                presentBanner(eventData!);
            } else if event.eventName == "BannerPresent:dismiss" {
                abandonBanner(eventData!);
            }
        }
    }
    
    private var currentBanner : UIBanner?
    public func presentBanner(eventData : BannerEventData) {
        if (currentBanner != nil) {
            abandonedBanners.append(currentBanner!)
            self.currentBanner = nil
            clearBanners()
        }
        self.currentBanner = UIBanner(bannerInfo: eventData.bannerInfo, masterMapScreen: masterMapScreen)
        masterMapScreen.view.addSubview(currentBanner!.view)
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
    
    public func abandonBanner(eventData : BannerEventData) {
        if currentBanner != nil {
            abandonedBanners.append(currentBanner!)
        }
        self.currentBanner!.slide_out({(finished: Bool) in self.clearBanners() })
    }
}
