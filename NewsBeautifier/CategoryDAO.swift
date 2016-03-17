//
//  CategoryDAO.swift
//  NewsBeautifier
//
//  Created by Thomas Hossard on 12/02/2016.
//  Copyright © 2016 NewsBeautifierTeam. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CategoryDAO {
    
    class func createCategory(name: String) -> Category {
        
        if let categories = getCategoryWithName(name) as? [Category] {
            if !categories.isEmpty {
                return categories.first!
            }
        }

        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("Category",
            inManagedObjectContext:managedContext)

        let category = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext: managedContext) as! Category
        
        category.setValue(name, forKey: "name")
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        return category
    }
    
    class func getCategoryWithName(name: String) -> NSArray? {
        var categories: NSArray? = nil
        
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest(entityName: "Category")
        let pred = NSPredicate(format: "(name = %@)", name)
        fetchRequest.predicate = pred
        
        //3
        do {
            let fetchedResults =
            try managedContext.executeFetchRequest(fetchRequest)
            categories = fetchedResults
        }
        catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return categories
    }
    
    class func getAllCategories() -> NSArray? {
        var categories: NSArray? = nil
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Category")
        
        do {
            let results =
            try managedContext.executeFetchRequest(fetchRequest)
            categories = results
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return categories
    }
    
    class func deleteAllCategories() {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let categories = self.getAllCategories()
        
        for category in categories! {
            managedContext.deleteObject(category as! NSManagedObject)
        }
        appDelegate.saveContext()
    }
}