//
//  BannerBasket.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/8/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreLocation

class BannerBasket {
    unowned var bannerStore : BannerStore
    weak var bannerController : BannerPresentationController?
        
    init(bannerStore : BannerStore) {
        self.bannerStore = bannerStore
    }
    
    func addBanner(banner : BannerInfo) {
        let b = bannerStore.banners[banner.id]
        if b != nil {
            if b!.version < banner.version {
                bannerController?.removeBanner(b!)
                bannerStore.storeBanner(banner);
                bannerController?.addBanner(banner)
            }
        } else {
            bannerStore.storeBanner(banner);
            bannerController?.addBanner(banner)
        }
    }
    
    func removeBanner(id : String) {
        let banner = bannerStore.getBannerInfo(id)
        if (banner != nil) {
            bannerStore.removeBanner(id)
            bannerController?.removeBanner(banner!)
        }
    }
    
    func removeBanner( banner : BannerInfo) {
        bannerStore.removeBanner(banner.id)
        bannerController?.removeBanner(banner)
    }
    
    func getBanners() -> [BannerInfo] {
        return bannerStore.banners.values.array
    }
    
    func empty() {
        for banner in getBanners() {
            removeBanner(banner)
        }
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
}