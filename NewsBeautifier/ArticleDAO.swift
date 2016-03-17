//
//  ArticleDAO.swift
//  NewsBeautifier
//
//  Created by Thomas Hossard on 12/02/2016.
//  Copyright © 2016 NewsBeautifierTeam. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ArticleDAO {
    
    class func createEmptyArticle() -> Article {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("Article",
            inManagedObjectContext:managedContext)
        
        let article = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext: managedContext) as! Article
        
        article.read = false
        
        return article
    }
    
    class func getAllArticles() -> NSArray? {
        var articles: NSArray? = nil

        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Article")

        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let results =
            try managedContext.executeFetchRequest(fetchRequest)
            articles = results
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

        return articles
    }
    
    class func getArticlesSearch(words: [String]) -> NSArray? {
        var articles: NSArray? = nil
        
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest(entityName: "Article")
        
        var predicateList = [NSPredicate]()
        
        for word in words {
            if word.characters.count == 0 {
                continue
            }
            let titlePredicate = NSPredicate(format: "title contains[c] %@", word)
            let urlPredicate = NSPredicate(format: "url contains[c] %@", word)
            let summaryPredicate = NSPredicate(format: "summary contains[c] %@", word)
            let orCompoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [titlePredicate, urlPredicate, summaryPredicate])
            predicateList.append(orCompoundPredicate)
        }
        
        let pred = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateList)
        fetchRequest.predicate = pred
        
        //3
        do {
            let fetchedResults =
            try managedContext.executeFetchRequest(fetchRequest)
            articles = fetchedResults
        }
        catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return articles
    }
    
    class func deleteAllArticles() {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let articles = self.getAllArticles()
        
        for article in articles! {
            managedContext.deleteObject(article as! NSManagedObject)
        }
        appDelegate.saveContext()
    }
}