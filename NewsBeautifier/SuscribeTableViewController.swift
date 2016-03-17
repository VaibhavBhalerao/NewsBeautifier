//
//  subscribeTableViewController.swift
//  NewsBeautifier
//
//  Created by Ronaël Bajazet on 18/02/2016.
//  Copyright © 2016 NewsBeautifierTeam. All rights reserved.
//

import UIKit
import CoreData
import Feeder

let kHANDLE_FINISH_PARSING = "FeedParserFinish"

class subscribeTableViewController: UITableViewController, UISearchResultsUpdating, FeedParserDelegate {
    
    var feedParser : FeedParser?
    var entries: [FeedItem]?
    var channel: FeedChannel?
    
    var optionalUrl: String?
    var optionalTitle: String?
    var optionalCategory: String?
    
    var filteredFeeds = [String]()
    let searchController = UISearchController(searchResultsController: nil)
    
    var activityView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        setIndicator()
        
        entries = [FeedItem]()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "handleEndParsing:",
            name:kHANDLE_FINISH_PARSING,
            object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kHANDLE_FINISH_PARSING, object: nil)
        stopIndicator()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func handleEndParsing(notification: NSNotification) {
        let errorAC = UIAlertController(title: "Error", message: "No feed found at url \(self.optionalUrl!)", preferredStyle: .Alert)
        errorAC.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        stopIndicator()
        
        errorAC.view.setNeedsLayout()
        self.presentViewController(errorAC, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.active && self.searchController.searchBar.text != "" {
            return self.filteredFeeds.count
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("kFeedCell", forIndexPath: indexPath)
        
        // Configure the cell...
        if self.searchController.active && self.searchController.searchBar.text != "" {
            cell.textLabel?.text = self.filteredFeeds[indexPath.row]
        }
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if self.searchController.active && self.searchController.searchBar.text != "" {
            self.optionalUrl = filteredFeeds[indexPath.row]
            
            self.feedParser = FeedParser(feedURL: filteredFeeds[indexPath.row])
            self.feedParser?.delegate = self
            self.feedParser?.parse()
            self.searchController.active = false
        }
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        startIndicator()
        if (!self.filteredFeeds.isEmpty) {
            self.filteredFeeds.removeAll(keepCapacity: false)
            self.tableView.reloadData()
        }
        
        var urlText = searchController.searchBar.text!
        
        if urlText.lowercaseString.hasPrefix("http://") || urlText.lowercaseString.hasPrefix("https://") {
        } else {
            urlText = "http://" + urlText
        }
        
        if let url = NSURL(string: urlText) {
            if (UIApplication.sharedApplication().canOpenURL(url)) {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    Feeder.shared.find(urlText) { page, error in
                        if (error == nil) {
                            for feed in page.feeds {
                                self.filteredFeeds.append(feed.href)
                            }
                            self.tableView.reloadData()
                        }
                        self.stopIndicator()
                    }
                })
            } else {
                startIndicator()
            }
        }
    }
    
    @IBAction func addFeed(sender: UIBarButtonItem) {
        let feedAC = UIAlertController(title: "Enter RSS URL", message: "Enter a feed URL here", preferredStyle: .Alert)
        
        feedAC.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        feedAC.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.clearButtonMode = .WhileEditing
        }
        
        feedAC.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action) -> Void in
            self.startIndicator()
            var urlText = feedAC.textFields![0].text!
            
            if urlText.lowercaseString.hasPrefix("http://") || urlText.lowercaseString.hasPrefix("https://") {
            } else {
                urlText = "http://" + urlText
            }

            if let url = NSURL(string: urlText) {
                if (UIApplication.sharedApplication().canOpenURL(url)) {
                    self.optionalUrl = feedAC.textFields![0].text
                    
                    self.feedParser = FeedParser(feedURL: urlText)
                    self.feedParser?.delegate = self
                    self.feedParser?.parse()
                }
            } else {
                self.stopIndicator()
                feedAC.message = "Please enter a correct URL"
                feedAC.view.setNeedsLayout()
                self.presentViewController(feedAC, animated: true, completion: nil)
            }
        }))

        feedAC.view.setNeedsLayout()
        self.presentViewController(feedAC, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    func setIndicator() {
        activityView = UIView(frame: CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height))
        activityView.backgroundColor=UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7)
        activityView.alpha = 0.0
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.activityView.alpha = 0.5
        })
        self.view.addSubview(activityView)
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        activityIndicator.startAnimating()
        activityIndicator.color = UIColor(red: CGFloat(7/255.0), green: CGFloat(161/255.0), blue: CGFloat(172/255.0), alpha: 1.0)
        activityIndicator.center = CGPointMake(self.tableView.frame.size.width / 2, self.tableView.frame.size.height / 2)
        self.tableView.addSubview(activityIndicator)
        activityIndicator.stopAnimating()
        self.activityView.hidden = true
    }
    
    func startIndicator() {
        self.activityView.hidden = false
        self.activityIndicator.startAnimating()
        self.view.layoutIfNeeded()
    }
    
    func stopIndicator() {
        self.activityView.hidden = true
        self.activityIndicator.stopAnimating()
        self.view.layoutIfNeeded()
    }
    
    func newFeed() {
        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 5
        queue.name = "My Downloader Queue"
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let feed = FeedDAO.createFeed(self.optionalUrl!)
        feed.name = self.channel?.channelTitle
        feed.tagurl = self.channel?.channelLink
        feed.summary = self.channel?.channelDescription
        
        let category = CategoryDAO.createCategory(self.optionalCategory!)
        
        if feed.category == nil {
            category.addFeed(feed)
        } else {
            managedContext.deleteObject(category as NSManagedObject)
            appDelegate.saveContext()
        }
        
        let sFeed = SubscribedFeedDAO.createSubscribedFeed(feed.originurl!)
        if feed.subscribedFeed?.url != sFeed.url {
            sFeed.feed = feed
            
            queue.addOperationWithBlock({ () -> Void in
                if self.entries?.count > 0 {
                    for entrie in self.entries! {
                        let article = ArticleDAO.createEmptyArticle()
                        
                        article.title = entrie.feedTitle
                        article.url = entrie.feedLink
                        article.imageurl = entrie.imageURLsFromDescription?.first
                        article.summary = entrie.feedContent
                        article.date = entrie.feedPubDate
                        article.author = entrie.feedAuthor
                        if !feed.addArticle(article) {
                            managedContext.deleteObject(article)
                        }
                    }
                    self.stopIndicator()
                    appDelegate.saveContext()
                }
                self.entries?.removeAll(keepCapacity: false)
            })
        } else {
            managedContext.deleteObject(sFeed as NSManagedObject)
            appDelegate.saveContext()
        }
    }
    
    func checkFeed() {
        if channel?.channelTitle == nil || channel?.channelCategory == nil {
            let feedAC = UIAlertController(title: "Missing infos", message: "We need more informations.", preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
            
            let feedAction = UIAlertAction(title: "Add", style: .Default) { (_) in
                for textField in feedAC.textFields! {
                    if textField.tag == 1 {
                        self.optionalTitle = textField.text
                    } else if textField.tag == 2 {
                        self.optionalCategory = textField.text
                    }
                }
                self.startIndicator()
                self.newFeed()
            }
            feedAction.enabled = false
            
            if channel?.channelTitle == nil {
                feedAC.addTextFieldWithConfigurationHandler { (textField) in
                    textField.placeholder = "Title"
                    textField.tag = 1
                    
                    NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                        feedAction.enabled = textField.text != ""
                    }
                }
            }
            if channel?.channelCategory == nil {
                feedAC.addTextFieldWithConfigurationHandler { (textField) in
                    textField.placeholder = "Category"
                    textField.tag = 2
                    
                    NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                        feedAction.enabled = textField.text != ""
                    }
                }
            }
            feedAC.addAction(feedAction)
            feedAC.addAction(cancelAction)
            stopIndicator()
            feedAC.view.setNeedsLayout()
            self.presentViewController(feedAC, animated: true, completion: nil)
        } else {
            self.newFeed()
        }
    }
    
    // MARK: - FeedParserDelegate methods
    func feedParser(parser: FeedParser, didParseChannel channel: FeedChannel) {
        // Here you could react to the FeedParser identifying a feed channel.
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.channel = channel
            self.optionalTitle = self.channel?.channelTitle
            self.optionalCategory = self.channel?.channelCategory
        })
    }
    
    func feedParser(parser: FeedParser, didParseItem item: FeedItem) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.entries?.append(item)
        })
    }
    
    func feedParser(parser: FeedParser, successfullyParsedURL url: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if (self.entries?.count > 0) {
                print("All feeds parsed.")
                self.checkFeed()
            } else {
                print("No feeds found at url \(url).")
                let errorAC = UIAlertController(title: "Error", message: "No feed found at url \(url)", preferredStyle: .Alert)
                errorAC.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.stopIndicator()
                errorAC.view.setNeedsLayout()
                self.presentViewController(errorAC, animated: true, completion: nil)
            }
        })
    }
    
    func feedParser(parser: FeedParser, parsingFailedReason reason: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            print("Feed parsed failed: \(reason)")
            self.entries = []
        })
    }
    
    func feedParserParsingAborted(parser: FeedParser) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            print("Feed parsing aborted by the user")
            self.entries = []
        })
    }
}
