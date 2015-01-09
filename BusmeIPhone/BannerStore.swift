//
//  JourneyStore.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/5/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class BannerStore : StorageProtocol {
    
    public var banners : [String:BannerInfo] = [String:BannerInfo]()

    func initWithCoder( coder : NSCoder) {
        let banners = coder.decodeObjectForKey("banners") as? [String:BannerInfo]
        if banners != nil {
            self.banners = banners!
        }
    }
    
    public func encodeWithCoder( coder : NSCoder ) {
        coder.encodeObject(banners, forKey: "banners")
    }
    
    public func preSerialize(api: ApiBase, time: TimeValue64) {
        for banner in banners.values.array {
            banner.preSerialize(api, time: time)
        }
    }
    
    public func postSerialize(api: ApiBase, time: TimeValue64) {
        for banner in banners.values.array {
            banner.postSerialize(api, time: time)
        }
    }
    
    public func getBannerInfo(id: String) -> BannerInfo? {
        return banners[id]
    }
    
    public func empty() {
        self.banners = [String:BannerInfo]()
    }
    
    public func doesContainBanner(id : String) -> Bool {
        return banners[id] != nil
    }
    
    public func storeBanner(banner : BannerInfo) {
        banners[banner.id] = banner
    }
    
    public func removeBanner(id : String) {
        let banner = banners[id]
        if banner != nil {
            banners[id] = nil
        }
    }
}