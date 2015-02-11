//
//  BannerRequestProcessor.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/12/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class BannerRequestProcessor : ArgumentPreparer, ResponseProcessor {
    unowned var bannerBasket : BannerBasket
    
    init(bannerBasket : BannerBasket) {
        self.bannerBasket = bannerBasket
    }
    
    func getArguments() -> [String : [String]]? {
        var args = [String:[String]]()
        var ids = [String]()
        var versions = [String]()
        for banner in bannerBasket.getBanners() {
            ids.append(banner.getId())
            versions.append("\(banner.version)")
        }
        args["banner_ids"] = ids
        args["banner_versions"] = versions
        return args
    }
    func onResponse(response: Tag) {
        var banners = [String : BannerInfo]()
        for child in response.childNodes {
            if child.name.lowercaseString == "banners" {
                for bspec in child.childNodes {
                    if bspec.name.lowercaseString == "banner" {
                        if bspec.attributes["destroy"]? == "1"  || bspec.attributes["destroy"]? == "true" {
                            let id = bspec.attributes["id"]
                            if id != nil {
                                banners[id!] = nil
                            }
                        } else {
                            let banner = BannerInfo(tag: bspec)
                            if banner.isValid() {
                                banners[banner.getId()] = banner
                            }
                        }
                    }
                }
            }
        }
        for key in banners.keys {
            let banner = banners[key]
            if banner == nil {
                bannerBasket.removeBanner(key)
            } else {
                bannerBasket.addBanner(banner!)
            }
        }
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
}