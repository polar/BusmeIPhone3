//
//  MasterOverlayView.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/26/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreGraphics
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
        return journeyPattern.getRect()
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
    
    var writeLock : dispatch_semaphore_t = dispatch_semaphore_create(1)
    
    init(overlay: MasterOverlay, mapView: MKMapView, masterController: MasterController) {
        self.mapView = mapView
        self.masterController = masterController
        super.init(overlay: overlay)
    }
    
    var mustDrawPaths = true
    
    func onBuspassEvent(event: BuspassEvent) {
        
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
    
    var drawCount = 0
    var patternViews : [PatternView]
    var locatorViews : [LocatorView]
    
    override func drawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale, inContext context: CGContext!) {
        let timeStart = UtilsTime.current()
        if true {
            CGContextSaveGState(context)
            let mp = MKMapRectInset(mapRect, 3.0/Double(zoomScale), 3.0/Double(zoomScale))
            let cgrect = rectForMapRect(mp)
            CGContextSetLineWidth(context, CGFloat(2.0/Double(zoomScale)))
            CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
            CGContextStrokeRect(context, cgrect)
            CGContextRestoreGState(context)
        }
        
        let projection = MKMapProjection(renderer: self, zoomScale: zoomScale, mapRect: mapRect)
        
        // Critical Section 
        dispatch_semaphore_wait(writeLock, DISPATCH_TIME_FOREVER)
        drawCount += 1
        let count = drawCount

        let pats = [PatternView](patternViews)
        let locs = [LocatorView](locatorViews)
        dispatch_semaphore_signal(writeLock)
        
        drawPatterns(pats, projection: projection, context: context)
        drawLocators(locs, projection: projection, context: context)
        
        let timeEnd = UtilsTime.current()
        if BLog.DEBUG { BLog.logger.debug("Draw \(count): \((timeEnd - timeStart)/1000) secs") }
    }
    
    func drawPatterns(patterns : [PatternView], projection: MKMapProjection, context : CGContextRef) {
        var drawn = [String:Bool]()
        for pattern in patterns {
            if drawn[pattern.journeyPattern.id] != nil {
                let mapRect = MKMapRectInset(pattern.getBoundingMapRect(), Double(-projection.lineWidth), Double(-projection.lineWidth))
                if MKMapRectIntersectsRect(mapRect, projection.mapRect) {
                    drawPattern(pattern, projection: projection, context: context)
                    drawn[pattern.journeyPattern.id] = true
                }
            }
        }
    }
    
    func drawPattern(patternView : PatternView, projection : MKMapProjection, context : CGContextRef) {
        CGContextSaveGState(context)
        
        if false {
            let cgrect = rectForMapRect(patternView.getBoundingMapRect())
            CGContextSetLineWidth(context, 2.0/projection.zoomScale)
            CGContextSetStrokeColorWithColor(context, UIColor.greenColor().CGColor)
            CGContextStrokeRect(context, cgrect)
        }
        
        CGContextSetLineWidth(context, projection.lineWidth)
        CGContextSetStrokeColorWithColor(context, patternView.color.CGColor)
        
        let projectedPath = patternView.journeyPattern.getProjectedPath()
        let path = ScreenPathUtils.toClippedScreenPath(projectedPath, projection: projection, path: nil)
        CGContextAddPath(context, path.cgpath)
        CGContextStrokePath(context)
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
        let x            = point.x - icon.hotspot.x/projection.zoomScale
        let y            = point.y - icon.hotspot.y/projection.zoomScale
        let width        = icon.image.size.width/projection.zoomScale
        let height       = icon.image.size.height/projection.zoomScale
        let imageRect = CGRect(x: x, y: y, width: width, height: height)
        CGContextDrawImage(context, imageRect, scaledIcon.image.CGImage)
        return imageRect
    }
    
    var previousLocators = [String:MKMapRect]()
    func recordLocatorMapRect(journeyDisplay : JourneyDisplay, mapRect : MKMapRect) {
        previousLocators[journeyDisplay.route.id!] = mapRect
    }
}
