//
//  BuspassApi.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/4/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreLocation

class BuspassApi : ApiBase, EventsApi {
    var apiURL : String
    var master_slug : String
    var appVersion : String
    var platformName : String
    var buspass : Buspass?
    var ready : Bool = false;
    var syncRate : Int = 60 * 1000;
    var updateRate : Int = 60 * 1000;
    var activeStartDisplayThreshold : Double = 60 * 1000;
    var busmeAppVersionString : String = "iOS 1.0.0"
    var loginManager : LoginManager?
    var uiEvents : BuspassEventDistributor
    var bgEvents : BuspassEventDistributor
    var loginCredentials : Login?
    var startReporting : Boolean?
    var offRouteDistanceThreshold : Int = 1000;
    var offRouteCountThreshold : Int = 20
    var offRouteTimeThreshold : Int = 60 * 1000
    
    init(httpClient: HttpClient, url : String, masterSlug : String, appVersion: String, platformName : String) {
        self.apiURL = url
        self.master_slug = masterSlug
        self.appVersion = appVersion
        self.platformName = platformName
        self.uiEvents = BuspassEventDistributor(name: "UIEvents(\(masterSlug))")
        self.bgEvents = BuspassEventDistributor(name: "BGEvents(\(masterSlug))")
        super.init(httpClient: httpClient)
        self.loginManager = LoginManager(api: self)
    }
    
    func isReady() -> Bool {
        return ready
    }
    
    func isLoggedIn() -> Bool {
        return loginCredentials != nil && loginCredentials!.loginState == LoginState.LS_LOGGED_IN
    }
    
    func clearLogin() {
        self.loginCredentials = nil
    }
    
    func get() -> (HttpStatusLine?, Bool) {
        if isReady() {
            return (nil, true)
        } else {
            let (status, api) = forceGet()
            return (status, api != nil)
        }
    }
    
    func getPlatformArgs() -> String {
        return "app_version=\(appVersion)&platform=\(platformName)"
    }
    
    var lastKnownLocation : CLLocationCoordinate2D?
    
    func getTrackingArgs() -> String {
        if lastKnownLocation != nil {
            return "lon=\(lastKnownLocation!.longitude)&lat=\(lastKnownLocation!.latitude)"
        } else {
            return ""
        }
    }
    
    func forceGet() -> (HttpStatusLine, BuspassApi?) {
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
    
    func getPlatformQuery() -> Query {
        let q = Query()
        q.add(getPlatformArgs())
        return q
    }
    
    func getHelpUrl() -> String? {
        if buspass != nil && buspass!.helpUrl != nil {
            return "\(buspass!.helpUrl!)?\(getPlatformArgs())"
        }
        return nil
    }
    
    func authTokenLogin(login : Login) -> (HttpStatusLine, Tag?) {
        if isReady() {
            login.url = buspass!.authUrl!
            var params = [String:AnyObject]()
            params["access_token"] = login.authToken!
            params["role_intent"] = login.roleIntent
            params["app_version"] = busmeAppVersionString
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
    
    func s(str : String?) -> String {
        return (str == nil) ? "" : str!
    }
    
    func passwordRegistration(login : Login) -> (HttpStatusLine, Tag?) {
        if isReady() {
            login.url = buspass!.registerUrl!
            var params = [String:AnyObject]()
            params["email"] = s(login.email)
            params["password"] = s(login.password)
            params["password_confirmation"] = s(login.passwordConfirmation)
            params["auth_code"] = s(login.driverAuthCode)
            params["role_intent"] = login.roleIntent
            params["app_version"] = busmeAppVersionString
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
    
    
    
    func passwordLogin(login : Login) -> (HttpStatusLine, Tag?) {
        if isReady() {
            login.url = buspass!.loginUrl!
            var params = [String:AnyObject]()
            params["email"] = s(login.email)
            params["password"] = s(login.password)
            params["auth_code"] = s(login.driverAuthCode)
            params["role_intent"] = login.roleIntent
            params["app_version"] = busmeAppVersionString
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
    
    func postLogout(login : Login) -> (HttpStatusLine, Tag?) {
        if isReady() {
            let url = buspass!.logoutUrl!
            var params = [String:AnyObject]()
            params["app_version"] = busmeAppVersionString
            let response = postURLResponse(url, parameters: params)
            let status = response.getStatusLine()
            if status.statusCode == 200 {
                return (status, nil)
//                let tag = xmlParse(response.getEntity())
//                if tag != nil {
//                    if ("ok" == tag!.name.lowercaseString) {
//                        return (status, tag!)
//                    } else {
//                        let s = HttpStatusLine(statusCode: 1000, reasonPhrase: "Wrong Response")
//                        if (BLog.ERROR) { BLog.logger.error(s.toString()) }
//                        return (s, nil)
//                    }
//                } else {
//                    let s = HttpStatusLine(statusCode: 1000, reasonPhrase: "Invalid Structure")
//                    if (BLog.ERROR) { BLog.logger.error(s.toString()) }
//                    return (s,nil)
//                }
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

    
    func postJourneyLocation(ploc : PostLocation, role : String) -> (HttpStatusLine, String?) {
        if isReady() {
            let postJourneyLocationUrl = buspass!.postJourneyLocationUrl
            if postJourneyLocationUrl != nil {
                let query = getPlatformQuery()
                let url = postJourneyLocationUrl! + query.toString()
                var params = [String:AnyObject]()
                params["lon"] = "\(ploc.location.longitude)"
                params["lat"] = "\(ploc.location.latitude)"
                params["id"]  = ploc.journey.id
                params["dir"] = "\(ploc.location.bearing)"
                
                params["reported_time"] = "\(ploc.location.time)"
                
                params["speed"] = "\(ploc.location.speed)"
                if role == "driver" {
                    params["driver"] = "1"
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
    
    func getRouteDefinition(nameid : NameId) -> Route? {
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
    
    func getJourneyPattern(id: String) -> JourneyPattern? {
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
                    if (tag != nil) {
                        if ("route" == tag!.name.lowercaseString && tag!.attributes["type"] != nil) {
                            if tag!.attributes["type"]!.lowercaseString == "pattern" {
                                var pattern = JourneyPattern(tag: tag!)
                                return pattern
                            } else {
                                if BLog.DEBUG { BLog.logger.debug("not the right type") }
                            }
                        } else {
                            if BLog.DEBUG { BLog.logger.debug("Not a Route structure") }
                        }
                    } else {
                        if BLog.DEBUG { BLog.logger.debug("Invalid XML") }
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
    
    func getMarkerClickThru(id : String) -> String? {
        if isReady() {
            var clickThru = buspass!.markerClickThru
            if clickThru != nil {
                let url = clickThru! + getDefaultQuery().toString()
                var params = [String:String]()
                params["marker_id"] = id
                params["master_slug"] = buspass!.slug!
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
    
    func getMasterMessageClickThru(id : String) -> String? {
        if isReady() {
            var clickThru = buspass!.messageClickThru
            if clickThru != nil {
                let url = clickThru! + getDefaultQuery().toString()
                var params = [String:String]()
                params["message_id"] = id
                params["master_slug"] = buspass!.slug!
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
    
    func getBannerClickThru(id : String) -> String? {
        if isReady() {
            var clickThru = buspass!.bannerClickThru
            if clickThru != nil {
                let url = clickThru! + getDefaultQuery().toString()
                var params = [String:String]()
                params["banner_id"] = id
                params["master_slug"] = buspass!.slug!
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
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
    
}