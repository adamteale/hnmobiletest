//
//  WebView_ViewController.swift
//  hnmobiletest
//
//  Created by Adam Teale on 17/7/18.
//  Copyright © 2018 adam. All rights reserved.
//

import UIKit
import WebKit

class WebView_ViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var post_webview: WKWebView!

    var post_url : URL?

    override func loadView() {
        self.post_webview = WKWebView()
        self.post_webview.navigationDelegate = self
        view = post_webview
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.post_webview.load(URLRequest(url: self.post_url!))
        self.post_webview.allowsBackForwardNavigationGestures = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
}
