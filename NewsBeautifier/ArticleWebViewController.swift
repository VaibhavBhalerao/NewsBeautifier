//
//  ArticleWebViewController.swift
//  NewsBeautifier
//
//  Created by Ronaël Bajazet on 10/03/2016.
//  Copyright © 2016 NewsBeautifierTeam. All rights reserved.
//

import UIKit
import WebKit

class ArticleWebViewController: UIViewController, WKNavigationDelegate {

    // MARK: - Properties
    var webView: WKWebView?
    
    var urlText: String?
    
    override func loadView() {
        super.loadView()
        
        self.webView = WKWebView()
        self.view = self.webView
        self.webView?.navigationDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let url = NSURL(string: self.urlText!) {
            let req = NSURLRequest(URL:url)
            self.webView!.loadRequest(req)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
