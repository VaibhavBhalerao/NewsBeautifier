//
//  FeedsCategoryViewController.swift
//  NewsBeautifier
//
//  Created by Ronaël Bajazet on 10/03/2016.
//  Copyright © 2016 NewsBeautifierTeam. All rights reserved.
//

import UIKit

private let categoryItemID = "kCategoryItem"
private let feedItemID = "kFeedItem"

class FeedsCategoryViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var feedCollectionView: UICollectionView!
    @IBOutlet weak var feedStackView: UIStackView!
    @IBOutlet weak var feedLabel: UILabel!
    
    var categories = [Category]()
    var feeds = [Feed]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.categoryCollectionView.backgroundColor = UIColor.whiteColor()
        self.feedCollectionView.backgroundColor = UIColor.whiteColor()
        // Do any additional setup after loading the view.
        
        setLongPress()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        categories = CategoryDAO.getAllCategories() as! [Category]
        self.categoryCollectionView.reloadData()
        self.feedCollectionView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if feeds.isEmpty {
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                self.feedCollectionView.hidden = true
                self.feedLabel.hidden = true
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setLongPress() {
        let lpgr = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.feedCollectionView.addGestureRecognizer(lpgr)
    }
    
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.Ended {
            return
        }
        
        let p = gestureReconizer.locationInView(self.feedCollectionView)
        let indexPath = self.feedCollectionView.indexPathForItemAtPoint(p)
        
        if let index = indexPath {
            let feed = feeds[index.row]
            if (feed.subscribedFeed == nil) {
                subscribe(feed, indexPath: index)
            } else {
                unsubscribe(feed, indexPath: index)
            }
        }
    }
    
    func subscribe(feed: Feed, indexPath: NSIndexPath) {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate

        let feedAC = UIAlertController(title: feed.name, message: "Do you want to subscribe ?", preferredStyle: .Alert)
        
        feedAC.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))

        feedAC.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
            let sFeed = SubscribedFeedDAO.createSubscribedFeed(feed.originurl!)
            sFeed.feed = feed
            appDelegate.saveContext()

            let cell = self.feedCollectionView.cellForItemAtIndexPath(indexPath) as! FeedCollectionViewCell
            cell.checkImageView.hidden = false
        }))
        self.presentViewController(feedAC, animated: true, completion: nil)
    }
    
    func unsubscribe(feed: Feed, indexPath: NSIndexPath) {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let feedAC = UIAlertController(title: feed.name, message: "Are you sure you want to unsubscribe ?", preferredStyle: .Alert)
        
        feedAC.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        feedAC.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
            managedContext.deleteObject(feed.subscribedFeed!)
            feed.subscribedFeed = nil
            appDelegate.saveContext()
            
            let cell = self.feedCollectionView.cellForItemAtIndexPath(indexPath) as! FeedCollectionViewCell
            cell.checkImageView.hidden = true
        }))
        self.presentViewController(feedAC, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "kShowFeedsSegue" {
            let indexPath = sender as! NSIndexPath
            let destVC = segue.destinationViewController as! ArticleTableViewController
            destVC.feed = feeds[indexPath.row]
            destVC.articles = feeds[indexPath.row].getAllArticles() as? [Article]
        }
    }
}

extension FeedsCategoryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView {
            return categories.count
        }
        return feeds.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if collectionView == categoryCollectionView {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(categoryItemID, forIndexPath: indexPath) as! CategoryCollectionViewCell
            
            // Configure the cell
            cell.nameLabel.text = categories[indexPath.row].name
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(feedItemID, forIndexPath: indexPath) as! FeedCollectionViewCell
        
        
        // Configure the cell
        let feed = feeds[indexPath.row]
        cell.nameLabel.text = feed.name
        
        if feed.subscribedFeed == nil {
            cell.checkImageView.hidden = true
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == categoryCollectionView {
            feeds = categories[indexPath.row].getAllFeeds() as! [Feed]
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                self.feedLabel.hidden = false
                self.feedCollectionView.hidden = false
            })
            feedCollectionView.reloadData()
        } else {
            performSegueWithIdentifier("kShowFeedsSegue", sender: indexPath)
        }
    }
    
}
