//
//  MarkerAnnotationView.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/20/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import MapKit

class MarkerAnnotationView : MKAnnotationView {
    var uiMarker : UIMarker?
    weak var masterMapScreen : MasterMapScreen?
    
    // WTF do I need this????
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(markerAnnotation: MarkerAnnotation!) {
        //self.uiMarker = UIMarker(markerInfo: markerAnnotation.markerInfo)
        super.init(annotation: markerAnnotation, reuseIdentifier: "Marker")
        if self.uiMarker == nil {
            // WTF does this happen? 
            self.uiMarker = UIMarker(markerInfo: markerAnnotation.markerInfo)
        }
        self.centerOffset = getCenterOffset()
        
        //uiMarker?.addTarget(self, action: "onButtonClicked", forControlEvents: UIControlEvents.TouchUpInside)
        uiMarker?.addTarget(self, action: "onButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.addSubview(uiMarker!)
        self.frame = uiMarker!.frame
        if BLog.DEBUG {
            BLog.logger.debug("Marker frame \(self.frame)")
            BLog.logger.debug("Button frame \(self.uiMarker!.frame)")
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        if BLog.DEBUG { BLog.logger.debug (" prepare for Reuse" ) }
        masterMapScreen?.fgMarkerPresentationController.dismissMessage(uiMarker!.markerInfo)
    }
    
    func onButtonClicked(sender : UIButton!) {
        masterMapScreen?.fgMarkerPresentationController.displayMessage(uiMarker!.markerInfo)
    }
    
    func getCenterOffset() -> CGPoint {
        // The damn documentation says that positive values "move" down and to the right.
        // and negative values "move" up and to the left. I guess that depends on your
        // perspective. We need to move the view so that the coordinate is at the
        // bottom left, which I would think means move the picture from its intended
        // point up half the height and to the right half the width, i.e. negative, positive.
        // So, I don't really know what the documentation's logical
        // perspective is, but it's the opposite. And it still looks off.
        let point = CGPoint(x: -uiMarker!.frame.size.width/2.0, y: 0 + uiMarker!.frame.size.height/2.0)
        
        // It looks like this, from it's placement that it's the upper left corner.
        let point2 = CGPoint(x: 0, y: 0)
        
        // This is close, but it looks like it's not consistent in differing zoom levels. 
        // It is fucked up.
        let point3 = CGPoint(x: 0, y: 0 - uiMarker!.frame.size.height)
        return point3
    }
}
