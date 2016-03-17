//
//  Category.swift
//  NewsBeautifier
//
//  Created by Ronaël Bajazet on 12/02/2016.
//  Copyright © 2016 NewsBeautifierTeam. All rights reserved.
//

import Foundation
import CoreData


class Category: NSManagedObject {

    func addFeed(feed: Feed) -> Bool {
        let feeds = self.mutableSetValueForKey("feeds")
        
        if !(feeds.containsObject(feed)) {
            feeds.addObject(feed)
            return true
        }
        return false
    }

    func getAllFeeds() -> NSArray {
        return (self.feeds?.allObjects)!
    }
}
