//
//  FeedDAO.swift
//  NewsBeautifier
//
//  Created by Thomas Hossard on 12/02/2016.
//  Copyright © 2016 NewsBeautifierTeam. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class FeedDAO {
    
    class func createFeed(url: String) -> Feed {
        
        if let feeds = getFeedWithUrl(url) as? [Feed] {
            if !feeds.isEmpty {
                return feeds.first!
            }
        }

        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("Feed",
            inManagedObjectContext:managedContext)
        
        let feed = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext: managedContext) as! Feed
        
        feed.setValue(url, forKey: "originurl")
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }

        return feed
    }
    
    class func getAllFeeds() -> NSArray? {
        var feeds: NSArray? = nil
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Feed")
        
        do {
            let results =
            try managedContext.executeFetchRequest(fetchRequest)
            feeds = results
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return feeds
    }
    
    class func getFeedWithUrl(url: String) -> NSArray? {
        var feeds: NSArray? = nil
        
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest(entityName: "Feed")
        let pred = NSPredicate(format: "(originurl = %@)", url)
        fetchRequest.predicate = pred
        
        //3
        do {
            let fetchedResults =
            try managedContext.executeFetchRequest(fetchRequest)
            feeds = fetchedResults
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return feeds
    }
    
    class func deleteAllFeeds() {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let feeds = self.getAllFeeds()
        
        for feed in feeds! {
            managedContext.deleteObject(feed as! NSManagedObject)
        }
        appDelegate.saveContext()
    }
}