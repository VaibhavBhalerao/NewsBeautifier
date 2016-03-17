//
//  FetchArticleManager.swift
//  NewsBeautifier
//
//  Created by Ronaël Bajazet on 11/03/2016.
//  Copyright © 2016 NewsBeautifierTeam. All rights reserved.
//

import Foundation
import UIKit

class FetchArticleManager : NSObject, FeedParserDelegate {
    
    // MARK: - Properties
    
    var queue: NSOperationQueue!
    var feedParser : FeedParser?
    var feed: Feed?
    
    init(feed: Feed) {
        self.queue = NSOperationQueue()
        self.queue.maxConcurrentOperationCount = 10
        self.queue.name = "Fetch article Queue"
        self.feed = feed
        self.feedParser = FeedParser(feedURL: feed.originurl!)
        super.init()
        
        self.feedParser?.delegate = self
    }
    
    func execute() {
        self.feedParser?.parse()
    }
    
    // MARK: - FeedParserDelegate methods
    func feedParser(parser: FeedParser, didParseItem item: FeedItem) {
        queue.addOperationWithBlock { () -> Void in
            
            let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
            
            let managedContext = appDelegate.managedObjectContext
            
            let article = ArticleDAO.createEmptyArticle()
            
            article.title = item.feedTitle
            article.url = item.feedLink
            article.imageurl = item.imageURLsFromDescription?.first
            article.summary = item.feedContent
            article.date = item.feedPubDate
            article.author = item.feedAuthor
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                if !self.feed!.addArticle(article) {
                    managedContext.deleteObject(article)
                    appDelegate.saveContext()
                } else {
                    // create a corresponding local notification
                    let notification = UILocalNotification()
                    notification.alertBody = "New article \"\(article.title!)\" from \(self.feed!.name!)." // text that will be displayed in the notification
                    notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
                    notification.fireDate = NSDate() // todo item due date (when notification will be fired)
                    notification.soundName = UILocalNotificationDefaultSoundName // play default sound
                    notification.userInfo = ["UUID": item.feedIdentifier!] // assign a unique identifier to the notification so that we can retrieve it later
                    notification.category = "ARTICLE_FETCH"
                    UIApplication.sharedApplication().scheduleLocalNotification(notification)
                }
                appDelegate.saveContext()
            })
        }
    }
}