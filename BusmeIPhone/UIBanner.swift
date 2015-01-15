//
//  UIBanner.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/13/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit


public class UIBanner : UIViewController {
    weak var api : BuspassApi?
    weak var masterMapScreen : MasterMapScreen?
    
    public var bannerInfo : BannerInfo
    public var imageView : UIImageView!
    public var textView : UILabel!
    public var imageURL : NSURL?
    
    public init(bannerInfo : BannerInfo, masterMapScreen : MasterMapScreen) {
        self.bannerInfo = bannerInfo
        self.masterMapScreen = masterMapScreen
        self.api = masterMapScreen.api
        self.imageView = UIImageView()
        self.textView = UILabel()
        super.init()
        view.addSubview(imageView)
        view.addSubview(textView)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        if (bannerInfo.goUrl != nil && !bannerInfo.goUrl!.isEmpty) {
            addTapRecognizer()
        }
    }
    
    public func addTapRecognizer() {
        var recognizer = UITapGestureRecognizer(target: self, action: "onClick")
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        view.addGestureRecognizer(recognizer)
    }
    
    func initViews() {
        
        if (bannerInfo.description != nil && !bannerInfo.description!.isEmpty ) {
            textView.text = bannerInfo.description!
        } else if bannerInfo.title != nil {
            textView.text = bannerInfo.title
        }
        if bannerInfo.iconUrl != nil {
            dispatch_async(api!.httpClient.queue!, {
                let url = NSURL(string: self.bannerInfo.iconUrl!)
                if url != nil {
                    let data = NSData(contentsOfURL: url!)
                    if (data != nil) {
                        let uiImage : UIImage = UIImage(data: data!)!
                        dispatch_async(dispatch_get_main_queue(), {
                            self.imageView.image = uiImage
                            self.imageView.sizeThatFits(CGSize(width: uiImage.size.width, height: uiImage.size.height))
                        })
                    }
                }
            })
        }
    }
    
    public func onClick(recognizer : UIGestureRecognizer) {
        if(BLog.DEBUG) { BLog.logger.debug("OnClick!") }
        let eventData = BannerEventData(bannerInfo: bannerInfo, state: BannerEvent.S_RESOLVE)
        api!.uiEvents.postEvent("BannerEvent", data: eventData)
    }
    
    public func slide_in(completion : (finished : Bool) -> Void ) {
        view.transform = CGAffineTransformMakeTranslation(-UIScreen.mainScreen().bounds.width, 0);
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.allZeros, animations: {
            self.view.alpha = 1
            self.view.transform = CGAffineTransformMakeTranslation(0, 0)
            }, completion: completion)
    }
    
    public func slide_out(completion: (finished : Bool) -> Void ) {
        view.transform = CGAffineTransformMakeTranslation(0, 0);
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.allZeros, animations: {
            self.view.alpha = 0
            self.view.transform = CGAffineTransformMakeTranslation(UIScreen.mainScreen().bounds.width, 0)
            }, completion: completion)
    }
}