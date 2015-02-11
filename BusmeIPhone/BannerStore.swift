//
//  JourneyStore.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/5/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class BannerStore : StorageProtocol {
    
    var banners : [String:BannerInfo] = [String:BannerInfo]()

    func initWithCoder( coder : NSCoder) {
        let banners = coder.decodeObjectForKey("banners") as? [String:BannerInfo]
        if banners != nil {
            self.banners = banners!
        }
    }
    
    func encodeWithCoder( coder : NSCoder ) {
        coder.encodeObject(banners, forKey: "banners")
    }
    
    func preSerialize(api: ApiBase, time: TimeValue64) {
        for banner in banners.values.array {
            banner.preSerialize(api, time: time)
        }
    }
    
    func postSerialize(api: ApiBase, time: TimeValue64) {
        for banner in banners.values.array {
            banner.postSerialize(api, time: time)
        }
    }
    
    func getBannerInfo(id: String) -> BannerInfo? {
        return banners[id]
    }
    
    func empty() {
        self.banners = [String:BannerInfo]()
    }
    
    func doesContainBanner(id : String) -> Bool {
        return banners[id] != nil
    }
    
    func storeBanner(banner : BannerInfo) {
        banners[banner.id] = banner
    }
    
    func removeBanner(id : String) {
        let banner = banners[id]
        if banner != nil {
            banners[id] = nil
        }
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
}