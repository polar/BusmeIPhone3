//
//  UIBanner.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/13/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit


class UIBanner : UIViewController {
    weak var api : BuspassApi?
    weak var masterMapScreen : MasterMapScreen?
    
    var bannerInfo : BannerInfo
    var imageView : UIImageView!
    var textView : UILabel!
    var imageURL : NSURL?
    
    init(bannerInfo : BannerInfo, masterMapScreen : MasterMapScreen) {
        self.bannerInfo = bannerInfo
        self.masterMapScreen = masterMapScreen
        self.api = masterMapScreen.api
        self.imageView = UIImageView()
        self.textView = UILabel()
        super.init(nibName: nil, bundle: nil)
        self.initSubviews()
        self.imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.textView.setTranslatesAutoresizingMaskIntoConstraints(false)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        view.addSubview(textView)
        if (bannerInfo.goUrl != nil && !bannerInfo.goUrl!.isEmpty) {
            addTapRecognizer()
        }
        
        let views = ["text": textView, "image" : imageView]
        var constraints  : [AnyObject]  = [AnyObject]()
        
        constraints.extend(NSLayoutConstraint.constraintsWithVisualFormat("H:|[image(125)]-10-[text]|",
            options: NSLayoutFormatOptions.AlignAllCenterY, metrics: [NSObject:AnyObject](), views: views))
        constraints.extend(NSLayoutConstraint.constraintsWithVisualFormat("V:|[text]|",
            options: NSLayoutFormatOptions.AlignAllLeft, metrics: [NSObject:AnyObject](), views: views))
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        view.addConstraints(constraints)
        view.backgroundColor = UIColor.whiteColor()

    }
    
    func addTapRecognizer() {
        var recognizer = UITapGestureRecognizer(target: self, action: "onClick:")
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        view.addGestureRecognizer(recognizer)
    }
    
    func initSubviews() {
        
        if (bannerInfo.msgDescription != nil && !bannerInfo.msgDescription!.isEmpty ) {
            textView.text = bannerInfo.msgDescription!
        } else if bannerInfo.title != nil {
            textView.text = bannerInfo.title
        }
        if bannerInfo.iconUrl != nil {
            dispatch_async(api!.httpClient.queue!, {
                let url = NSURL(string: self.bannerInfo.iconUrl!)
                if url != nil {
                    let data = NSData(contentsOfURL: url!)
                    if (data != nil) {
                        let uiImage : UIImage? = UIImage(data: data!)
                        if uiImage == nil {
                            if (BLog.ERROR) { BLog.logger.error("image not found/loadable from \(url!) : data \(data)") }
                        } else {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.imageView.image = uiImage!
                                self.imageView.sizeThatFits(CGSize(width: uiImage!.size.width, height: uiImage!.size.height))
                            })
                        }
                    }
                }
            })
        }
    }
    
    func onClick(recognizer : UIGestureRecognizer) {
        if(BLog.DEBUG) { BLog.logger.debug("OnClick!") }
        let eventData = BannerEventData(bannerInfo: bannerInfo, state: BannerEvent.S_RESOLVE)
        eventData.resolve = BannerEvent.R_GO
        eventData.time = UtilsTime.current()
        api!.uiEvents.postEvent("BannerEvent", data: eventData)
    }
    
    func slide_in(completion : ( finished: Bool) -> Void ) {
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.allZeros, animations: {
            self.view.alpha = 1
            self.view.frame.origin = CGPoint(x: 0, y: self.view.frame.origin.y)
            }, completion: completion)
    }
    
    func slide_out(completion: (finished : Bool) -> Void ) {
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.allZeros, animations: {
            self.view.alpha = 0
            self.view.frame.origin = CGPoint(x: UIScreen.mainScreen().bounds.width, y: self.view.frame.origin.y)
            }, completion: completion)
    }
    
    func displayWebPage(url : String?) {
        var theURL = url
        if theURL == nil {
            theURL = bannerInfo.goUrl
        }
        if theURL != nil {
            let webScreen = WebScreen()
            webScreen.openUrl(theURL!)
            masterMapScreen?.navigationController?.pushViewController(webScreen, animated: true)
        }
    }
}