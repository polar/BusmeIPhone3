//
//  WebScreen.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/21/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit

class WebScreen : UIViewController, UIWebViewDelegate {
    var webView : UIWebView
    override init() {
        webView = UIWebView()
        webView.frame = UIScreen.mainScreen().bounds
        webView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        webView.scalesPageToFit = true
        webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
        super.init(nibName: nil, bundle: nil)
        self.view = webView
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func openUrl(url : String) {
        let nsurl = NSURL(string: url)
        if nsurl != nil {
            let request = NSURLRequest(URL: nsurl!)
            webView.loadRequest(request)
        }
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return UIApplication.sharedApplication().openURL(request.URL)
    }
}