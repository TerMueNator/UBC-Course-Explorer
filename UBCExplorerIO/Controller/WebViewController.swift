//
//  WebViewController.swift
//  UBCExplorerIO
//
//  Created by Nucha Powanusorn on 28/7/20.
//  Copyright © 2020 Nucha Powanusorn. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var progressView: UIProgressView!
    
    var urlString: String!
    var selectedCourse: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadWebsite(urlString)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        navigationItem.title = selectedCourse
        navigationItem.backBarButtonItem?.title = "Course Info"
        
        progressView.isHidden = false
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
            if progressView.progress == 1.0 {
                progressView.isHidden = true
            }
        }
    }
    
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        progressView.isHidden = false
        webView.reload()
    }
    
    func loadWebsite(_ urlString: String) {
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)
//        let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.109 Safari/537.36"
//        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        webView.load(request)
    }
}
