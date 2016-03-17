//
//  UrlSessionManager.swift
//  NewsBeautifier
//
//  Created by Ronaël Bajazet on 12/02/2016.
//  Copyright © 2016 NewsBeautifierTeam. All rights reserved.
//

import Foundation

class Wrapper<T> {
    let ch: T
    init(completionHandler: T){self.ch = completionHandler}
}

typealias UrlSessionManagerCompletion = (NSURL!) -> ()

class UrlSessionManager : NSObject, NSURLSessionDelegate, FeedParserDelegate {
    
    // MARK: - Properties
    let config: NSURLSessionConfiguration
    lazy var session: NSURLSession = {
        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 5
        queue.name = "My Downloader Queue"
        return NSURLSession(configuration: self.config,
            delegate: self, delegateQueue: queue)
    }()
    
    init(configuration: NSURLSessionConfiguration) {
        self.config = configuration
        super.init()
    }
    
    // MARK: - NSURLSessionDelegate
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        let req = downloadTask.originalRequest!
        let ch = NSURLProtocol.propertyForKey("ch", inRequest:req)!
        let response = downloadTask.response as! NSHTTPURLResponse
        let stat = response.statusCode
        var url : NSURL! = nil
        if stat == 200 {
            url = location
        }
        let ch2 = (ch as! Wrapper).ch as UrlSessionManagerCompletion
        ch2(url)
    }
    
    // MARK: - Methods
    func download(urlString: String, completionHandler ch : UrlSessionManagerCompletion) -> NSURLSessionTask {
        let url = NSURL(string: urlString)!
        let req = NSMutableURLRequest(URL:url)
        NSURLProtocol.setProperty(Wrapper(completionHandler: ch), forKey:"ch", inRequest:req)
        let task = self.session.downloadTaskWithRequest(req)
        task.resume()
        return task
    }
    
    func cancelAllTasks() {
        self.session.invalidateAndCancel()
    }
}