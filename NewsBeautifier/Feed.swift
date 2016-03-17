//
//  Feed.swift
//  NewsBeautifier
//
//  Created by Ronaël Bajazet on 12/02/2016.
//  Copyright © 2016 NewsBeautifierTeam. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Feed: NSManagedObject {
    
    func addArticle(article: Article) -> Bool {
        let articles = self.mutableSetValueForKey("articles")
        
        if (isContainsArticle(article)?.count == 0) {
            articles.addObject(article)
            return true
        }
        return false
    }
    
    func getAllArticles() -> NSArray {
        return (self.articles?.allObjects)!
    }
    
    func isContainsArticle(article: Article) -> NSArray? {
        var articles: NSArray? = nil
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Article")
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let pred = NSPredicate(format: "(url = %@) AND (feed = %@)", article.url!, self, article)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = pred
        
        do {
            let results =
            try managedContext.executeFetchRequest(fetchRequest)
            articles = results
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        print(articles?.count)
        
        return articles
    }

}