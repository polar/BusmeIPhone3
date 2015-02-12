//
//  BannerPresentationController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/8/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
class BannerInfoComparator : Comparator {
    func compare(lhs: AnyObject, rhs: AnyObject) -> Int {
        return compare(lhs as BannerInfo, b2: rhs as BannerInfo)
    }
    
    func compare(b1 : BannerInfo, b2: BannerInfo) -> Int {
        let now = UtilsTime.current()
        let time = cmp(b1.nextTime(now), b2.nextTime(now))
        if time == 0 {
            return cmp(b1.priority, b2.priority)
        } else {
            return time
        }
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
}

class BannerPresentationController {
    unowned var api : BuspassApi
    unowned var bannerBasket : BannerBasket
    var currentBanner : BannerInfo?
    var bannerQ : PriorityQueue<BannerInfo>!
    
    init(api : BuspassApi, basket: BannerBasket) {
        self.api = api
        self.bannerBasket = basket
        self.bannerQ = PriorityQueue<BannerInfo>(compare: BannerInfoComparator())
        bannerBasket.bannerController = self
    }
    
    func addBanner(banner: BannerInfo) {
        if (!bannerQ.doesInclude(banner)) {
            bannerQ.push(banner)
        }
    }
    
    func removeBanner(banner: BannerInfo) {
        if (currentBanner === banner) {
            abandonBanner(banner)
            banner.onDismiss(true)
            currentBanner = nil
        }
        bannerQ.delete(banner)
    }
    
    func removeBanner(id: String) {
        if (currentBanner?.id == id) {
            abandonBanner(currentBanner!)
            currentBanner!.onDismiss(true)
            bannerQ.delete(currentBanner!)
            currentBanner = nil
        } else {
            for b in bannerQ!.getElements() {
                if (b.id == id) {
                    bannerQ.delete(b)
                }
            }
        }
    }
    
    func doesContain(banner: BannerInfo) -> Bool {
        return bannerQ.doesInclude(banner)
    }
    
    func roll(removeCurrent : Bool, now : TimeValue64 = UtilsTime.current()) {
        if (currentBanner != nil) {
            if (!removeCurrent && !currentBanner!.isDisplayTimeExpired(now)) {
                return
            } else {
                abandonBanner(currentBanner!)
                currentBanner!.onDismiss(true, time: now)
                self.currentBanner = nil
            }
        }
        var banner = bannerQ.poll()
        while banner != nil {
            if banner!.shouldBeSeen(now) {
                presentBanner(banner!)
                banner!.onDisplay(now)
                self.currentBanner = banner
                return
            }
            banner = bannerQ.poll()
        }
    }
    
    func onDismiss(remind: Bool, bannerInfo: BannerInfo, time : TimeValue64) {
        bannerInfo.onDismiss(remind)
        if !remind {
            // User doesn't get a choice on remove the banner from display
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
    
    // Done on Background
    
    func onLocationUpdate(location: GeoPoint, now: TimeValue64 = UtilsTime.current()) {
        for banner in bannerBasket.getBanners() {
            if (banner.point == nil ||
                GeoCalc.getGeoAngle(location, c2: banner.point!) < banner.radius) {
                    if banner.shouldBeSeen(now) {
                        bannerQ.push(banner)
                    }
            }
        }
    }
    
    func compare(b1 : BannerInfo, b2: BannerInfo) -> Int {
        let now = UtilsTime.current()
        let time = cmp(b1.nextTime(now), b2.nextTime(now))
        if time == 0 {
            return cmp(b1.priority, b2.priority)
        } else {
            return time
        }
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
}