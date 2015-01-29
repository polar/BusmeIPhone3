//
//  MasterOverlayView.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/26/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreGraphics
import CoreLocation
import MapKit

class PatternView {
    var journeyPattern : JourneyPattern
    var disposition : Int
    var color : UIColor
    
    init(args : PatternArgs) {
        journeyPattern = args.journeyPattern
        disposition = args.disposition
        switch(disposition) {
        case Disposition.TRACK:
            self.color = UIColor(red: 0, green: 1, blue: 0, alpha: 0.9)
            break
        case Disposition.HIGHLIGHT:
            self.color = UIColor(red: 1, green: 0, blue: 0, alpha: 0.9)
            break
        case Disposition.NORMAL:
            self.color = UIColor(red: 0.1, green: 0, blue: 1, alpha: 0.5)
            break
        default:
            self.color = UIColor(red: 0.1, green: 1, blue: 1, alpha: 0.5)
        }
    }

    func getBoundingMapRect() -> MKMapRect {
        return journeyPattern.getGeoRect().toMapRect()
    }
}

class LocatorView {
    var params : LocatorArgs
    
    init(args : LocatorArgs) {
        self.params = args
    }
    
    var icon : Icon?
    func getIcon() -> Icon {
        if icon != nil {
            return icon!
        }
        if params.isReporting {
            icon = Locators.getReporting("passenger").getIcon()
            return icon!
        }
        switch params.iconType {
        case IconType.NORMAL:
            switch params.disposition {
            case Disposition.HIGHLIGHT:
                icon = Locators.getArrow("red", reported: params.isReported).getDirection(params.currentDirection)
                break
            case Disposition.TRACK:
                icon = Locators.getArrow("green", reported: params.isReported).getDirection(params.currentDirection)
                break
            case Disposition.NORMAL:
                icon = Locators.getArrow("blue", reported: params.isReported).getDirection(params.currentDirection)
                break
            default:
                icon = Locators.getArrow("blue", reported: params.isReported).getDirection(params.currentDirection)
            }
            return icon!
        case IconType.START:
            switch params.disposition {
            case Disposition.HIGHLIGHT:
                icon = Locators.getStarting("red").getStartingIcon(params.startMeasure)
                break
            case Disposition.TRACK:
                icon = Locators.getStarting("green").getStartingIcon(params.startMeasure)
                break
            case Disposition.NORMAL:
                icon = Locators.getStarting("purple").getStartingIcon(params.startMeasure)
                break
            default:
                icon = Locators.getStarting("purple").getStartingIcon(params.startMeasure)
            }
            return icon!
        case IconType.TOO_EARLY:
            icon = Locators.getTooEarly("blue").getIcon()
            return icon!
        default:
            if BLog.ERROR { BLog.logger.error("Unknown IconType \(params.iconType)") }
            icon = Locators.getTooEarly("blue").getIcon()
            return icon!
        }
    }
}

class MasterOverlayView : MKOverlayRenderer, BuspassEventListener {
    var masterController : MasterController
    var mapView : MKMapView
    var mapLayer : RouteAndLocationsMapLayer
    
    var writeLock : dispatch_semaphore_t = dispatch_semaphore_create(1)
    var locatorWriteLock : dispatch_semaphore_t = dispatch_semaphore_create(1)
    
    let mapInset : MKMapSize!
    
    var projectionController : ProjectionController!
    
    private func getProjection(mapRect: MKMapRect, zoomScale : MKZoomScale) -> MKMapProjection {
        return projectionController.getProjection(mapRect, zoomScale: zoomScale)
    }
    
    init(overlay: MasterOverlay, mapView: MKMapView, masterController: MasterController) {
        self.mapView = mapView
        self.masterController = masterController
        self.mapLayer = RouteAndLocationsMapLayer(api: masterController.api, journeyDisplayController: masterController.journeyDisplayController, journeyLocationPoster: masterController.journeyLocationPoster)
        super.init(overlay: overlay)
        self.projectionController = ProjectionController(renderer: self)
        registerForEvents()
        self.mapInset = mapRectForRect(CGRect(origin: self.pointForMapPoint(MKMapPoint(x:0, y: 0)), size: CGSize(width: 33.0/pow(2.0,-21), height: 33/pow(2.0,-21)))).size
    }
    
    var mustDrawPaths = true
    
    func onBuspassEvent(event: BuspassEvent) {
        let eventName = event.eventName
        if eventName == "JourneySyncProgress" {
            let eventData = event.eventData as? JourneySyncProgressEventData
            if eventData != nil && eventData!.action == JourneySyncProgressEvent.P_DONE {
                resetAll()
            }
        } else if eventName == "UpdateProgress" {
            let eventData2 = event.eventData as? UpdateProgressEventData
            if eventData2 != nil && eventData2!.action == InvocationProgressEvent.U_FINISH {
                resetLocators()
            }
        } else if eventName == "JourneyLocationUpdate" {
            resetLocators()
            
        } else if eventName == "JourneyAdded" {
            let eventData = event.eventData as? JourneyDisplayEventData
            if eventData != nil {
                onJourneyAdded(eventData!)
            }
            
        } else if eventName == "JourneyRemoved" {
            let eventData = event.eventData as? JourneyDisplayEventData
            if eventData != nil {
                onJourneyRemoved(eventData!)
            }
        } else if eventName == "VisibilityChanged" {
            resetAll()
        }
        
    }
    
    func onJourneyAdded(eventData : JourneyDisplayEventData) {
        let journeyDisplay = eventData.journeyDisplay
        if journeyDisplay != nil {
            let mapRect = journeyDisplay!.getGeoRect().toMapRect()
            MKMapRectInset(mapRect, -mapInset.width, -mapInset.height )
            setNeedsDisplayInMapRect(mapRect)
        }
    }
    
    func onJourneyRemoved(eventData : JourneyDisplayEventData) {
        let journeyDisplay = eventData.journeyDisplay
        if journeyDisplay != nil {
            let mapRect = journeyDisplay!.getGeoRect().toMapRect()
            MKMapRectInset(mapRect, -mapInset.width, -mapInset.height )
            setNeedsDisplayInMapRect(mapRect)
        }
    }
    
    func resetAll() {
        let journeyDisplays = [JourneyDisplay](masterController.journeyDisplayController.getJourneyDisplays())
        let patterns = mapLayer.getRoutePatterns(journeyDisplays)
        let locators = mapLayer.getJourneyLocators(journeyDisplays)
        dispatch_semaphore_wait(writeLock, DISPATCH_TIME_FOREVER)
        self.patternViews = patterns.map({(p) in PatternView(args: p)})
        self.locatorViews = locators.map({(loc) in LocatorView(args: loc)})
        let locatorMapRects = [MKMapRect](previousLocators.values.array)
        dispatch_semaphore_signal(writeLock)
        setNeedsDisplayInMapRect(overlay.boundingMapRect)
        for loc in locatorMapRects {
            setNeedsDisplayInMapRect(loc)
        }
        
    }
    
    func resetLocators() {
        let journeyDisplays = [JourneyDisplay](masterController.journeyDisplayController.getJourneyDisplays())
        let locators = mapLayer.getJourneyLocators(journeyDisplays)
        dispatch_semaphore_wait(writeLock, DISPATCH_TIME_FOREVER)
        self.locatorViews = locators.map({(loc) in LocatorView(args: loc)})
        let locatorMapRects = [MKMapRect](previousLocators.values.array)
        dispatch_semaphore_signal(writeLock)
        setNeedsDisplayInMapRect(overlay.boundingMapRect)
        for locView in locatorViews {
            let point : GeoPoint = locView.params.currentLocation
            updateMapRect(locView.params.journeyDisplay, loc: point)
        }
        
        for loc in locatorMapRects {
            setNeedsDisplayInMapRect(loc)
        }
    }
    
    func updateMapRect(journeyDisplay : JourneyDisplay, loc : GeoPoint) {
        // If data is the lastLocation we have to update that mapRect.
        // However, if it is the newLocation, we just assume the icon
        // is the same size. We assume that if the zoomLevel changes
        // that we will get a pertinent update anyway.
        let mapRect = previousLocators[journeyDisplay.route.id!]
        var size : MKMapSize?
        if mapRect != nil {
            size = mapRect!.size
        }
        if size == nil {
            let geoRect = journeyDisplay.getGeoRect()
            let nw = CLLocationCoordinate2D(latitude: geoRect.top, longitude: geoRect.left)
            let se = CLLocationCoordinate2D(latitude: geoRect.bottom, longitude: geoRect.right)
            let nwMapPoint = MKMapPointForCoordinate(nw)
            let seMapPoint = MKMapPointForCoordinate(se)
            let nwMapRect = MKMapRect(origin: nwMapPoint, size: MKMapSize(width: 0, height: 0))
            let seMapRect = MKMapRect(origin: seMapPoint, size: MKMapSize(width: 0, height: 0))
            let mapRect = MKMapRectUnion(nwMapRect, seMapRect)
            size = mapRect.size
        }
        let rect = mapRectForLocation(loc, mapSize: size!)
        setNeedsDisplayInMapRect(rect)
    }
    
    func mapRectForLocation(loc : GeoPoint, mapSize : MKMapSize) -> MKMapRect {
        let coord = CLLocationCoordinate2D(latitude: loc.getLatitude(), longitude: loc.getLongitude())
        let mapPoint = MKMapPointForCoordinate(coord)
        let mapWidth = mapSize.width
        let mapHeight = mapSize.height
        // Center the Rect
        let corner = MKMapPoint(x: mapPoint.x - mapWidth/2, y: mapPoint.y - mapHeight/2)
        let mapRect = MKMapRect(origin: corner, size: mapSize)
        return mapRect
    }
    
    func registerForEvents() {
        masterController.api.uiEvents.registerForEvent("VisibilityChanged", listener: self)
        masterController.api.uiEvents.registerForEvent("UpdateProgress", listener: self)
        masterController.api.uiEvents.registerForEvent("JourneySyncProgress", listener: self)
        masterController.api.uiEvents.registerForEvent("JourneyAdded", listener: self)
        masterController.api.uiEvents.registerForEvent("JourneyRemoved", listener: self)
        masterController.api.uiEvents.registerForEvent("JourneyLocationUpdate", listener: self)
    }
    
    func unregisterForEvents() {
        masterController.api.uiEvents.unregisterForEvent("VisibilityChanged", listener: self)
        masterController.api.uiEvents.unregisterForEvent("UpdateProgress", listener: self)
        masterController.api.uiEvents.unregisterForEvent("JourneySyncProgress", listener: self)
        masterController.api.uiEvents.unregisterForEvent("JourneyAdded", listener: self)
        masterController.api.uiEvents.unregisterForEvent("JourneyRemoved", listener: self)
        masterController.api.uiEvents.unregisterForEvent("JourneyLocationUpdate", listener: self)
    }
    
    func setCenterAndZoom() {
        let rect = Rect(geoRect: masterController.master.bbox!.toGeoRect())
        let center = rect.center()
        let coord = CLLocationCoordinate2D(latitude: center.getY(), longitude: center.getX())
        let span = MKCoordinateSpan(latitudeDelta: rect.height(), longitudeDelta: rect.width())
        let region = MKCoordinateRegion(center: coord, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    var drawCount = 0
    var patternViews : [PatternView] = [PatternView]()
    var locatorViews : [LocatorView] = [LocatorView]()
    
    override func drawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale, inContext context: CGContext!) {
        let timeStart = CACurrentMediaTime()
        if BLog.DEBUG_PATTERN {
            CGContextSaveGState(context)
            let mp = MKMapRectInset(mapRect, 3.0/Double(zoomScale), 3.0/Double(zoomScale))
            let cgrect = rectForMapRect(mp)
            CGContextSetLineWidth(context, CGFloat(2.0/Double(zoomScale)))
            CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
            CGContextStrokeRect(context, cgrect)
            CGContextRestoreGState(context)
        }
        
        let projection = getProjection(mapRect, zoomScale: zoomScale)
        
        // Critical Section
        dispatch_semaphore_wait(writeLock, DISPATCH_TIME_FOREVER)
        drawCount += 1
        let count = drawCount

        let pats = [PatternView](patternViews)
        let locs = [LocatorView](locatorViews)
        dispatch_semaphore_signal(writeLock)
        
        drawPatterns(pats, projection: projection, context: context)
        drawLocators(locs, projection: projection, context: context)
        
        let timeEnd = CACurrentMediaTime()
        if BLog.DEBUG_PATTERN { BLog.logger.debug("Draw \(count): \(timeEnd - timeStart) secs \(mapRect.toString())") }
    }
    
    func drawPatterns(patterns : [PatternView], projection: MKMapProjection, context : CGContextRef) {
        var drawn = [String:Bool]()
        for pattern in patterns {
            let name = "\(pattern.journeyPattern.id)-\(pattern.color)"
            if drawn[name] == nil {
                let mapRect = MKMapRectInset(pattern.getBoundingMapRect(), -mapInset.width, -mapInset.height)
                if MKMapRectIntersectsRect(mapRect, projection.mapRect) {
                    drawPattern(pattern, projection: projection, context: context)
                    drawn[name] = true
                }
            }
        }
    }
    
    func drawPattern(patternView : PatternView, projection : MKMapProjection, context : CGContextRef) {
        CGContextSaveGState(context)
        
        let timeStart = CACurrentMediaTime()
        
        if BLog.DEBUG_PATTERN {
            let patternMapRect = patternView.getBoundingMapRect()
            let cgrect = rectForMapRect(patternView.getBoundingMapRect())
            CGContextSetLineWidth(context, 2.0/projection.zoomScale)
            CGContextSetStrokeColorWithColor(context, UIColor.greenColor().CGColor)
            CGContextStrokeRect(context, cgrect)
            let willShow = MKMapRectIntersectsRect(projection.mapRect, patternView.getBoundingMapRect())
            let geoRect = ScreenPathUtils.cgRectToGeoRect(self, cgRect: cgrect)
            let canRect = ScreenPathUtils.mapRectToGeoRect(projection.mapRect)
        }
        
        CGContextSetLineWidth(context, max(7.0/projection.zoomScale, projection.lineWidth))
        CGContextSetStrokeColorWithColor(context, patternView.color.CGColor)
        
        var cgPath = projection.getCGPath(patternView.journeyPattern)
        CGContextAddPath(context, cgPath)
        CGContextStrokePath(context)
        
        let timeEnd = CACurrentMediaTime()
        if BLog.DEBUG_PATTERN { BLog.logger.debug("drawPattern : \(timeEnd-timeStart) secs") }
    }
    
    func drawLocators(locatorViews : [LocatorView], projection: MKMapProjection, context: CGContextRef) {
        for locator in locatorViews {
            drawLocator(locator, projection: projection, context: context)
        }
    }
    
    func drawLocator(locatorView: LocatorView, projection : MKMapProjection, context: CGContextRef) {
        let loc = locatorView.params.currentLocation
        let coord = CLLocationCoordinate2D(latitude: loc.getLatitude(), longitude: loc.getLongitude())
        let mapPoint = MKMapPointForCoordinate(coord)
        let cgPoint = pointForMapPoint(mapPoint)
        let jd = locatorView.params.journeyDisplay
        let imageRect = drawLocatorIcon(cgPoint, icon: locatorView.getIcon(), projection: projection, context: context)
        let mapRect = mapRectForRect(imageRect)
        recordLocatorMapRect(jd, mapRect: mapRect)
    }
    
    func drawLocatorIcon(point : CGPoint, icon: Icon, projection : MKMapProjection, context: CGContextRef) -> CGRect {
        let scale        = max(1.0, (4.0-(19.0-Double(projection.zoomLevel))/2.0)/2.0)
        let scaledIcon   = icon.scaleBy(scale)
        let x            = point.x - scaledIcon.hotspot.x/projection.zoomScale
        let y            = point.y - scaledIcon.hotspot.y/projection.zoomScale
        let width        = scaledIcon.image.size.width/projection.zoomScale
        let height       = scaledIcon.image.size.height/projection.zoomScale
        let imageRect = CGRect(x: x, y: y, width: width, height: height)
        CGContextDrawImage(context, imageRect, scaledIcon.image.CGImage)
        return imageRect
    }
    
    var previousLocators = [String:MKMapRect]()
    func recordLocatorMapRect(journeyDisplay : JourneyDisplay, mapRect : MKMapRect) {
        previousLocators[journeyDisplay.route.id!] = mapRect
    }
}
