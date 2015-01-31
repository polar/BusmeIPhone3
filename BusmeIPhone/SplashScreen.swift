//
//  SplashScreen.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/31/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit

class SplashScreen : UIViewController {
    var imageName : String
    var imageView : UIImageView
    var image : UIImage
    
    init(imageName : String) {
        self.imageName = imageName
        self.image = UIImage(named: imageName)!
        self.imageView = UIImageView(frame: UIScreen.mainScreen().bounds)
        imageView.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.addSubview(imageView)
        view.bringSubviewToFront(imageView)
    }
}