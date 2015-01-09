//
//  BannerPresentationController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/8/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class BannerPresentationController {
    public var api : BuspassApi
    public var bannerBasket : BannerBasket
    public var currentBanner : BannerInfo?
    public var bannerQ : PriorityQueue<BannerInfo>?
    
    public init(api : BuspassApi, basket: BannerBasket) {
        self.api = api
        self.bannerBasket = basket
        self.bannerQ = PriorityQueue<BannerInfo>(compare: self.compare)
    }
    
    public func addBanner(banner: BannerInfo) {
        if (!bannerQ!.doesInclude(banner)) {
            bannerQ!.push(banner)
        }
    }
    
    public func removeBanner(banner: BannerInfo) {
        if (currentBanner === banner) {
            abandonBanner(banner)
            banner.onDismiss(true)
            currentBanner = nil
        }
        bannerQ!.delete(banner)
    }
    
    public func removeBanner(id: String) {
        if (currentBanner?.id == id) {
            abandonBanner(currentBanner!)
            currentBanner!.onDismiss(true)
            bannerQ!.delete(currentBanner!)
            currentBanner = nil
        } else {
            for b in bannerQ!.getElements() {
                if (b.id == id) {
                    bannerQ!.delete(b)
                }
            }
        }
    }
    
    public func doesContain(banner: BannerInfo) -> Bool {
        return bannerQ!.doesInclude(banner)
    }
    
    public func roll(removeCurrent : Bool, now : TimeValue64 = UtilsTime.current()) {
        if (currentBanner != nil) {
            if (!removeCurrent && !currentBanner!.isDisplayTimeExpired(now)) {
                return
            } else {
                abandonBanner(currentBanner!)
                currentBanner!.onDismiss(true, time: now)
                self.currentBanner = nil
            }
        }
        var banner = bannerQ!.poll()
        while banner != nil {
            if banner!.shouldBeSeen(now) {
                presentBanner(banner!)
                banner!.onDisplay(now)
                self.currentBanner = banner
                return
            }
            banner = bannerQ!.poll()
        }
    }
    
    func abandonBanner(banner: BannerInfo) {
        let evd = BannerEventData(bannerInfo: banner)
        api.uiEvents.postEvent("BannerPresent:dismiss", data: evd)
    }
    
    func presentBanner(banner: BannerInfo) {
        let evd = BannerEventData(bannerInfo: banner)
        api.uiEvents.postEvent("BannerPresent:display", data: evd)
    }
    
    public func onLocationUpdate(location: GeoPoint, now: TimeValue64 = UtilsTime.current()) {
        for banner in bannerBasket.getBanners() {
            if (banner.point == nil ||
                GeoCalc.getGeoAngle(location, c2: banner.point!) < banner.radius) {
                    if banner.shouldBeSeen(now) {
                        bannerQ!.push(banner)
                    }
            }
        }
    }

    func cmp(a1 : TimeValue64, a2 : TimeValue64) -> Int {
        if (a1 == a2) {
            return 0;
        }
        if (a1 < a2) {
            return -1
        }
        if (a1 > a2) {
            return 1
        }
        return 0
    }
    
    
    func compare(b1 : BannerInfo, b2: BannerInfo) -> Int {
        let now = UtilsTime.current()
        let time = cmp(b1.nextTime(now), a2: b2.nextTime(now))
        if time == 0 {
            return cmp(Int64(b1.priority), a2: Int64(b2.priority))
        } else {
            return time
        }
    }
}