//
//  Feed+CoreDataProperties.swift
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

extension Feed {

    @NSManaged var name: String?
    @NSManaged var originurl: String?
    @NSManaged var summary: String?
    @NSManaged var tagurl: String?
    @NSManaged var articles: NSSet?
    @NSManaged var category: Category?
    @NSManaged var subscribedFeed: SubscribedFeed?

}
