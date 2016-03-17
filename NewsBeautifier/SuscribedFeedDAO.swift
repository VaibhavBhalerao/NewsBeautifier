//
//  subscribedFeedDAO.swift
//  NewsBeautifier
//
//  Created by Ronaël Bajazet on 12/02/2016.
//  Copyright © 2016 NewsBeautifierTeam. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SubscribedFeedDAO {

    class func createSubscribedFeed(url: String) -> SubscribedFeed {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate

        let managedContext = appDelegate.managedObjectContext

        let entity =  NSEntityDescription.entityForName("SubscribedFeed",
            inManagedObjectContext:managedContext)

        let sFeed = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext: managedContext) as! SubscribedFeed

        sFeed.setValue(url, forKey: "url")
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }

        return sFeed
    }
    
    class func getAllSubscribedFeeds() -> NSArray? {
        var subscribedFeeds: NSArray? = nil
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "SubscribedFeed")
        
        do {
            let results =
            try managedContext.executeFetchRequest(fetchRequest)
            subscribedFeeds = results
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return subscribedFeeds
    }
    
    class func deleteAllSubscribedFeeds() {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let sFeeds = self.getAllSubscribedFeeds()
        
        for sFeed in sFeeds! {
            managedContext.deleteObject(sFeed as! NSManagedObject)
        }
        appDelegate.saveContext()
    }
}