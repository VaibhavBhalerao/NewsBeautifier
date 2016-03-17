//
//  Article+CoreDataProperties.swift
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

extension Article {

    @NSManaged var author: String?
    @NSManaged var date: NSDate?
    @NSManaged var imagedata: NSData?
    @NSManaged var imageurl: String?
    @NSManaged var read: NSNumber?
    @NSManaged var summary: String?
    @NSManaged var title: String?
    @NSManaged var url: String?
    @NSManaged var attrdescription: NSObject?
    @NSManaged var feed: Feed?

}
