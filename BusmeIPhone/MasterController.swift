//
//  MasterController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/10/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class MasterController {
    public var api : BuspassApi
    public var master : Master
    public var directory : String?
    public var mainController : AnyObject
    public var bannerBasket : BannerBasket
    public var bannerPresentationController : BannerPresentationController
    public var bannerStore : BannerStore
    
    public var journeyBasket : JourneyBasket
    public var journeyDisplayController : JourneyDisplayController
    public var journeyStore : JourneyStore
    public var journeyVisibilityController : JourneyVisibilityController
    public var journeySelectionPostingController : AnyObject
    
    public var markerBasket : MarkerBasket
    public var markerPresentationController : MarkerPresentationController
    public var markerStore : MarkerStore
    
    public var masterMessageBasket : MasterMessageBasket
    public var masterMessagePresentationController : MasterMessagePresentationController
    public var masterMessageStore : MasterMessageStore
    
    public var loginForeground : LoginForeground
    public var loginBackground : LoginBackground
    
    public var journeyLocationPoster : JourneyLocationPoster
    public var journeEventController : JourneyEventController
    public var journeyPostingController : JourneyPostingController
    
    
    
}