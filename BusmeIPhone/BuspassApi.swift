//
//  BuspassApi.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/4/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreLocation

public class BuspassApi : ApiBase, EventsApi {
    public var apiURL : String
    public var master_slug : String
    public var appVersion : String
    public var platformName : String
    public var buspass : Buspass?
    public var ready : Bool = false;
    public var syncRate : Int = 60 * 1000;
    public var updateRate : Int = 60 * 1000;
    public var activeStartDisplayThreshold : Double = 60 * 1000;
    public var busmeAppVersionString : String = "iPhone 1.0.0"
    public var loginManager : LoginManager?
    public var uiEvents : BuspassEventDistributor
    public var bgEvents : BuspassEventDistributor
    public var loginCredentials : Login?
    public var startReporting : Boolean?
    public var offRouteDistanceThreshold : Int = 1000;
    public var offRouteCountThreshold : Int = 20
    public var offRouteTimeThreshold : Int = 60 * 1000
    
    public init(httpClient: HttpClient, url : String, masterSlug : String, appVersion: String, platformName : String) {
        self.apiURL = url
        self.master_slug = masterSlug
        self.appVersion = appVersion
        self.platformName = platformName
        self.uiEvents = BuspassEventDistributor(name: "UIEvents(\(masterSlug))")
        self.bgEvents = BuspassEventDistributor(name: "BGEvents(\(masterSlug))")
        super.init(httpClient: httpClient)
        self.loginManager = LoginManager(api: self)
    }
    
    public func isReady() -> Bool {
        return ready
    }
    
    public func isLoggedIn() -> Bool {
        return loginCredentials != nil && loginCredentials!.loginState == LoginState.LS_LOGGED_IN
    }
    
    public func clearLogin() {
        self.loginCredentials = nil
    }
    
    public func get() -> (HttpStatusLine?, Bool) {
        if isReady() {
            return (nil, true)
        } else {
            let (status, api) = forceGet()
            return (status, api != nil)
        }
    }
    
    public func getPlatformArgs() -> String {
        return "app_version=\(appVersion)&platform=\(platformName)"
    }
    
    public var lastKnownLocation : CLLocationCoordinate2D?
    
    public func getTrackingArgs() -> String {
        if lastKnownLocation != nil {
            return "lon=\(lastKnownLocation!.longitude)&lat=\(lastKnownLocation!.latitude)"
        } else {
            return ""
        }
    }
    
    public func forceGet() -> (HttpStatusLine, BuspassApi?) {
        let response = getURLResponse(apiURL)
        let status = response.getStatusLine()
        if status.statusCode == 200 {
            let ent = response.getEntity()
            let tag = xmlParse(ent)
            if (tag != nil && tag!.name.lowercaseString == "api") {
                let api = tag!
                if "1" == api.attributes["majorVersion"] {
                    let bp = Buspass()
                    bp.mode = api.attributes["mode"]
                    bp.name = api.attributes["name"]
                    bp.slug = api.attributes["slug"]
                    bp.authUrl = api.attributes["auth"]
                    bp.loginUrl = api.attributes["login"]
                    bp.registerUrl = api.attributes["register"]
                    bp.logoutUrl = api.attributes["logout"]
                    bp.oauthLoginUrl = api.attributes["oauth_login"]
                    bp.oauthLogoutUrl = api.attributes["oauth_logout"]
                    bp.postloc_time_rate = api.attributes["postloc_time_rate"]
                    bp.postloc_dist_rate = api.attributes["postloc_dist_rate"]
                    bp.curloc_time_rate = api.attributes["curloc_time_rate"]
                    bp.lon = api.attributes["lon"]
                    bp.lat = api.attributes["lat"]
                    bp.box = api.attributes["box"]
                    bp.timezone = api.attributes["timezone"]
                    bp.time = api.attributes["time"]
                    bp.timeoffset = api.attributes["timeoffset"]
                    bp.datefmt = api.attributes["datefmt"]
                    bp.getRouteJourneyIdsUrl = api.attributes["getRouteJourneyIds"]
                    bp.getRouteDefinitionUrl = api.attributes["getRouteDefinition"]
                    bp.getJourneyLocationUrl = api.attributes["getJourneyLocation"]
                    bp.getMultipleJourneyLocationsUrl = api.attributes["getMultipleJourneyLocations"]
                    bp.postJourneyLocationUrl = api.attributes["postJourneyLocation"]
                    bp.getMessageUrl = api.attributes["getMessage"]
                    bp.getMessagesUrl = api.attributes["getMessages"]
                    bp.getMarkersUrl = api.attributes["getMarkers"]
                    bp.postFeedbackUrl = api.attributes["postFeedback"]
                    bp.updateUrl = api.attributes["update"]
                    bp.updateRate = api.attributes["updateRate"]
                    bp.activeStartDisplayThreshold = api.attributes["activeStartThreshold"]
                    bp.activeEndWaitThreshold = api.attributes["activeEndWaitThreshold"]
                    bp.offRouteDistanceThreshold = api.attributes["offRouteDistanceThreshold"]
                    bp.offRouteCountThreshold = api.attributes["offRouteCountThreshold"]
                    bp.offRouteTimeThreshold = api.attributes["offRouteTimeThreshold"]
                    bp.getRouteJourneyIds1Url = api.attributes["getRouteJourneyIds1"]
                    bp.markerClickThru = api.attributes["markerClickThru"]
                    bp.messageClickThru = api.attributes["messageClickThru"]
                    bp.syncRate = api.attributes["syncRate"]
                    bp.bannerRefreshRate = api.attributes["bannerRefreshRate"]
                    bp.bannerMaxImageSize = api.attributes["bannerMaxImageSize"]
                    bp.bannerClickThru = api.attributes["bannerClickThru"]
                    bp.helpUrl = api.attributes["helpUrl"]
                    bp.bannerImageUrl = api.attributes["bannerImage"]
                    for child in api.childNodes {
                        if ("message" == child.name.lowercaseString) {
                            let message = MasterMessage(tag: child)
                            if message.isValid() {
                                bp.initialMessages.append(message)
                            }
                        }
                    }
                    self.syncRate = bp.syncRate != nil ? (bp.syncRate! as NSString).integerValue : 10000 // milliseconds
                    self.updateRate = bp.updateRate != nil ? (bp.updateRate! as NSString).integerValue : 40000 // milliseconds
                    self.activeStartDisplayThreshold = bp.activeStartDisplayThreshold != nil ? (bp.activeStartDisplayThreshold! as NSString).doubleValue : 10000
                    self.offRouteCountThreshold = bp.offRouteCountThreshold != nil ? (bp.offRouteCountThreshold! as NSString).integerValue : 10 // milliseconds
                    self.offRouteDistanceThreshold = bp.offRouteDistanceThreshold != nil ? (bp.offRouteDistanceThreshold! as NSString).integerValue : 200
                    self.offRouteTimeThreshold = bp.offRouteTimeThreshold != nil ? (bp.offRouteTimeThreshold! as NSString).integerValue : 20000 // milliseconds
                    self.buspass = bp
                    self.ready = true
                    return (response.getStatusLine(), self)
                } else {
                    return (HttpStatusLine(statusCode: 1000, reasonPhrase: "Wrong Version"), nil)
                }
            } else {
                return (HttpStatusLine(statusCode: 1000, reasonPhrase: "Invalid Structure"), nil)
            }
        } else {
            return (status, nil)
        }
    }
    
    class Query {
        var query : String = ""
        func add(args : String?) {
            if (args != nil && !args!.isEmpty) {
                if query.isEmpty {
                    query = args!
                } else {
                    query += "&\(args!)"
                }
            }
        }
        func toString() -> String {
            if query.isEmpty {
                return ""
            } else {
                return "?\(query)"
            }
        }
    }
    
    func getDefaultQuery() -> Query {
        let q = Query()
        q.add(getPlatformArgs())
        q.add(getTrackingArgs())
        return q
    }
    
    public func authTokenLogin(login : Login) -> (HttpStatusLine, Tag?) {
        if isReady() {
            login.url = buspass!.authUrl!
            var params = [String:[String]]()
            params["access_token"] = [ "\(login.authToken!)" ]
            params["role_intent"] = [ login.roleIntent ]
            params["app_version"] = [ busmeAppVersionString ]
            let response = postURLResponse(login.url!, parameters: params)
            let status = response.getStatusLine()
            if status.statusCode == 200 {
                let tag = xmlParse(response.getEntity())
                if tag != nil {
                    if ("login" == tag!.name.lowercaseString) {
                        return (status, tag!)
                    } else {
                        let s = HttpStatusLine(statusCode: 1000, reasonPhrase: "Wrong Response")
                        if (BLog.ERROR) { BLog.logger.error(s.toString()) }
                        return (s, nil)
                    }
                } else {
                    let s = HttpStatusLine(statusCode: 1000, reasonPhrase: "Invalid Structure")
                    if (BLog.ERROR) { BLog.logger.error(s.toString()) }
                    return (s,nil)
                }
            } else {
                if (BLog.ERROR) { BLog.logger.error(status.toString()) }
                return (status, nil)
            }
        } else {
            let s = HttpStatusLine(statusCode: 1000, reasonPhrase: "Api Not Ready")
            if (BLog.ERROR) { BLog.logger.error(s.toString()) }
            return (s,nil)
        }
    }
    
    public func passwordRegistration(login : Login) -> (HttpStatusLine, Tag?) {
        if isReady() {
            login.url = buspass!.registerUrl!
            var params = [String:[String]]()
            params["email"] = [ "\(login.email)" ]
            params["password"] = [ "\(login.password)" ]
            params["password_confirmation"] = [ "\(login.passwordConfirmation)" ]
            params["auth_code"] = [ "\(login.driverAuthCode)" ]
            params["role_intent"] = [ login.roleIntent ]
            params["app_version"] = [ busmeAppVersionString ]
            let response = postURLResponse(login.url!, parameters: params)
            let status = response.getStatusLine()
            if status.statusCode == 200 {
                let tag = xmlParse(response.getEntity())
                if tag != nil {
                    if ("login" == tag!.name.lowercaseString) {
                        return (status, tag!)
                    } else {
                        let s = HttpStatusLine(statusCode: 1000, reasonPhrase: "Wrong Response")
                        if (BLog.ERROR) { BLog.logger.error(s.toString()) }
                        return (s, nil)
                    }
                } else {
                    let s = HttpStatusLine(statusCode: 1000, reasonPhrase: "Invalid Structure")
                    if (BLog.ERROR) { BLog.logger.error(s.toString()) }
                    return (s,nil)
                }
            } else {
                if (BLog.ERROR) { BLog.logger.error(status.toString()) }
                return (status, nil)
            }
        } else {
            let s = HttpStatusLine(statusCode: 1000, reasonPhrase: "Api Not Ready")
            if (BLog.ERROR) { BLog.logger.error(s.toString()) }
            return (s,nil)
        }
    }
    
    
    
    public func passwordLogin(login : Login) -> (HttpStatusLine, Tag?) {
        if isReady() {
            login.url = buspass!.loginUrl!
            var params = [String:[String]]()
            params["email"] = [ "\(login.email)" ]
            params["password"] = [ "\(login.password)" ]
            params["auth_code"] = [ "\(login.driverAuthCode)" ]
            params["role_intent"] = [ login.roleIntent ]
            params["app_version"] = [ busmeAppVersionString ]
            let response = postURLResponse(login.url!, parameters: params)
            let status = response.getStatusLine()
            if status.statusCode == 200 {
                let tag = xmlParse(response.getEntity())
                if tag != nil {
                    if ("login" == tag!.name.lowercaseString) {
                        return (status, tag!)
                    } else {
                        let s = HttpStatusLine(statusCode: 1000, reasonPhrase: "Wrong Response")
                        if (BLog.ERROR) { BLog.logger.error(s.toString()) }
                        return (s, nil)
                    }
                } else {
                    let s = HttpStatusLine(statusCode: 1000, reasonPhrase: "Invalid Structure")
                    if (BLog.ERROR) { BLog.logger.error(s.toString()) }
                    return (s,nil)
                }
            } else {
                if (BLog.ERROR) { BLog.logger.error(status.toString()) }
                return (status, nil)
            }
        } else {
            let s = HttpStatusLine(statusCode: 1000, reasonPhrase: "Api Not Ready")
            if (BLog.ERROR) { BLog.logger.error(s.toString()) }
            return (s,nil)
            
        }
    }
    
    public func postJourneyLocation(ploc : PostLocation, role : String) -> (HttpStatusLine, String?) {
        if isReady() {
            let postJourneyLocationUrl = buspass!.postJourneyLocationUrl
            if postJourneyLocationUrl != nil {
                let query = getDefaultQuery()
                let url = postJourneyLocationUrl! + query.toString()
                var params = [String:[String]]()
                params["lon"] = ["\(ploc.location.longitude)"]
                params["lat"] = ["\(ploc.location.latitude)"]
                params["id"]  = ["\(ploc.journey.id)"]
                params["dir"] = ["\(ploc.location.bearing)"]
                
                params["reported_time"] = ["\(ploc.location.time)"]
                
                params["speed"] = ["\(ploc.location.speed)"]
                if role == "driver" {
                    params["driver"] = ["1"]
                }
                let response = postURLResponse(url, parameters: params)
                let status = response.getStatusLine()
                if status.statusCode == 200 {
                    let tag = xmlParse(response.getEntity())
                    if (tag != nil) {
                        return (status, tag!.name.lowercaseString)
                    } else {
                        let s = HttpStatusLine(statusCode: 1000, reasonPhrase: "Wrong Response")
                        if (BLog.ERROR) { BLog.logger.error(s.toString()) }
                        return (s, nil)
                    }
                } else {
                    if (BLog.ERROR) { BLog.logger.error(status.toString()) }
                    return (status, nil)
                }
            } else {
                let s = HttpStatusLine(statusCode: 1000, reasonPhrase: "No Posting Url")
                if (BLog.ERROR) { BLog.logger.error(s.toString()) }
                return (s,nil)            }
        } else {
            let s = HttpStatusLine(statusCode: 1000, reasonPhrase: "Api Not Ready")
            if (BLog.ERROR) { BLog.logger.error(s.toString()) }
            return (s,nil)
        }
    }
    
    public func getRouteDefinition(nameid : NameId) -> Route? {
        if isReady() {
            var routeDefUrl = buspass!.getRouteDefinitionUrl
            if routeDefUrl != nil{
                let query = getDefaultQuery()
                query.add("id=\(nameid.id)")
                query.add("type=\(nameid.type!)")
                let url = routeDefUrl! + query.toString()
                let response = getURLResponse(url)
                let status = response.getStatusLine()
                if status.statusCode == 200 {
                    let tag = xmlParse(response.getEntity())
                    if (tag != nil && "route" == tag!.name.lowercaseString) {
                        var route = Route(tag: tag!)
                        return route
                    }
                } else {
                    if (BLog.DEBUG) { BLog.logger.debug(status.toString()) }
                }
            } else {
                if (BLog.ERROR) { BLog.logger.error("No URL") }
            }
        } else {
            if (BLog.ERROR) { BLog.logger.error("Api Not Ready") }
        }
        return nil
    }
    
    public func getJourneyPattern(id: String) -> JourneyPattern? {
        if isReady() {
            var journeyPatterUrl = buspass!.getRouteDefinitionUrl
            if journeyPatterUrl != nil{
                let query = getDefaultQuery()
                query.add("id=\(id)")
                query.add("type=P")
                let url = journeyPatterUrl! + query.toString()
                let response = getURLResponse(url)
                let status = response.getStatusLine()
                if status.statusCode == 200 {
                    let tag = xmlParse(response.getEntity())
                    if (tag != nil && "pattern" == tag!.name.lowercaseString) {
                        var pattern = JourneyPattern(tag: tag!)
                        return pattern
                    }
                } else {
                    if (BLog.DEBUG) { BLog.logger.debug(status.toString()) }
                }
            } else {
                if (BLog.ERROR) { BLog.logger.error("No URL") }
            }
        } else {
            if (BLog.ERROR) { BLog.logger.error("Api Not Ready") }
        }
        return nil
    }
    
    public func getMarkerClickThru(id : String) -> String? {
        if isReady() {
            var clickThru = buspass!.messageClickThru
            if clickThru != nil {
                let url = clickThru! + getDefaultQuery().toString()
                var params = [String:[String]]()
                params["marker_id"] = [id]
                params["master_slug"] = [buspass!.slug!]
                let response = postURLResponse(url, parameters: params)
                let status = response.getStatusLine()
                if status.statusCode == 200 {
                    let tag = xmlParse(response.getEntity())
                    if tag != nil && "a" == tag!.name.lowercaseString {
                        return tag!.attributes["href"]
                    }
                } else {
                    if (BLog.DEBUG) { BLog.logger.debug(status.toString()) }
                }
            } else {
                if (BLog.ERROR) { BLog.logger.error("No URL") }
            }
        } else {
            if (BLog.ERROR) { BLog.logger.error("Api Not Ready") }
        }
        return nil
    }
    
    public func getMasterMessageClickThru(id : String) -> String? {
        if isReady() {
            var clickThru = buspass!.messageClickThru
            if clickThru != nil {
                let url = clickThru! + getDefaultQuery().toString()
                var params = [String:[String]]()
                params["message_id"] = [id]
                params["master_slug"] = [buspass!.slug!]
                let response = postURLResponse(url, parameters: params)
                let status = response.getStatusLine()
                if status.statusCode == 200 {
                    let tag = xmlParse(response.getEntity())
                    if tag != nil && "a" == tag!.name.lowercaseString {
                        return tag!.attributes["href"]
                    }
                } else {
                    if (BLog.DEBUG) { BLog.logger.debug(status.toString()) }
                }
            } else {
                if (BLog.ERROR) { BLog.logger.error("No URL") }
            }
        } else {
            if (BLog.ERROR) { BLog.logger.error("Api Not Ready") }
        }
        return nil
    }
    
    public func getBannerClickThru(id : String) -> String? {
        if isReady() {
            var clickThru = buspass!.bannerClickThru
            if clickThru != nil {
                let url = clickThru! + getDefaultQuery().toString()
                var params = [String:[String]]()
                params["banner_id"] = [id]
                params["master_slug"] = [buspass!.slug!]
                let response = postURLResponse(url, parameters: params)
                let status = response.getStatusLine()
                if status.statusCode == 200 {
                    let tag = xmlParse(response.getEntity())
                    if tag != nil && "a" == tag!.name.lowercaseString {
                        return tag!.attributes["href"]
                    }
                } else {
                    if (BLog.DEBUG) { BLog.logger.debug(status.toString()) }
                }
            } else {
                if (BLog.ERROR) { BLog.logger.error("No URL") }
            }
        } else {
            if (BLog.ERROR) { BLog.logger.error("Api Not Ready") }
        }
        return nil
    }
    
}