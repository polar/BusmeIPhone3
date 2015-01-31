//
//  JourneyLocationAnnotationView.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/30/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import MapKit

class JourneyLocationAnnotationView : MKPinAnnotationView {
    var journeyLocationAnnotation : JourneyLocationAnnotation
    weak var masterMapScreen : MasterMapScreen?
    init(journeyLocationAnnotation : JourneyLocationAnnotation) {
        self.journeyLocationAnnotation = journeyLocationAnnotation
        super.init(annotation: journeyLocationAnnotation, reuseIdentifier: "JourneyLocation")
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}