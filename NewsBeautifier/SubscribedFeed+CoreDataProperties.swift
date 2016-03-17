//
//  subscribedFeed+CoreDataProperties.swift
//  NewsBeautifier
//
//  Created by Ronaël Bajazet on 12/03/2016.
//  Copyright © 2016 NewsBeautifierTeam. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension SubscribedFeed {

    @NSManaged var date: NSDate?
    @NSManaged var url: String?
    @NSManaged var feed: Feed?

}
