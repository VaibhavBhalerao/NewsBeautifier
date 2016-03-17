//
//  HomeTableViewController.swift
//  NewsBeautifier
//
//  Created by Ronaël Bajazet on 12/02/2016.
//  Copyright © 2016 NewsBeautifierTeam. All rights reserved.
//

import UIKit

let kArticleCellID = "kArticleCell"

class HomeTableViewController: UITableViewController {
    
    let myRSS = UrlSessionManager(configuration: .defaultSessionConfiguration())
    var articles = [Article]()
    
    var time: NSDate?
    
    var noContentLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the reflesh control action
        self.refreshControl!.addTarget(self, action: "doRefresh:", forControlEvents: .ValueChanged)
        
        noContentLabel = UILabel(frame: CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height))
        noContentLabel!.center = self.tableView.center
        noContentLabel!.textAlignment = NSTextAlignment.Center
        noContentLabel!.text = "No content. Please subscribe to some feeds"
        noContentLabel?.hidden = false
        self.tableView.addSubview(noContentLabel!)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetch(completion: () -> Void) {
        time = NSDate()
        
        print("yolo")
        
        let feeds = FeedDAO.getAllFeeds() as! [Feed]
        for feed in feeds {
            let dwld = FetchArticleManager(feed: feed)
            dwld.execute()
        }
        
        completion()
    }
    
    func updateUI() {
        if let _ = time {
            self.articles.removeAll(keepCapacity: false)
            
            let sFeeds = SubscribedFeedDAO.getAllSubscribedFeeds() as! [SubscribedFeed]
            if !sFeeds.isEmpty {
                for sFeed in sFeeds {
                    let articlesFetch = sFeed.feed!.getAllArticles() as? [Article]
                    if articlesFetch != nil {
                        self.articles += articlesFetch!
                    }
                }
                self.articles.sortInPlace({ $0.date!.compare($1.date!) == .OrderedDescending })
                if (self.articles.isEmpty) {
                    noContentLabel?.hidden = false
                } else {
                    noContentLabel?.hidden = true
                }
            }
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.tableView.reloadData()
            })
        }
        else {
            print("Not yet updated")
        }
    }
    
    func doRefresh(sender: AnyObject) {
        self.fetch(self.updateUI)
        self.refreshControl?.endRefreshing()
    }
    
    func loadHtml(indexPath: NSIndexPath, article: Article) {
        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        queue.addOperationWithBlock { () -> Void in
            let content = try? NSMutableAttributedString(
                data: article.summary!.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
                options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                documentAttributes: nil)
            if (content != nil) {
                content!.enumerateAttribute(NSAttachmentAttributeName, inRange: NSMakeRange(0, content!.length), options: NSAttributedStringEnumerationOptions(rawValue: 0)) { (value, range, stop) -> Void in
                    if let attachement = value as? NSTextAttachment {
                        let image = attachement.imageForBounds(attachement.bounds, textContainer: NSTextContainer(), characterIndex: range.location)
                        let screenSize: CGRect = UIScreen.mainScreen().bounds
                        if image!.size.width > screenSize.width-2 {
                            content!.removeAttribute(NSAttachmentAttributeName, range: range)
                        }
                    }
                }
                article.attrdescription = content
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.tableView.reloadRowsAtIndexPaths(
                        [indexPath], withRowAnimation: .None)
                })
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if articles.isEmpty {
            self.tableView.separatorStyle = .None
        } else {
            self.tableView.separatorStyle = .SingleLine
        }
        return articles.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kArticleCellID, forIndexPath: indexPath) as! HomeTableViewCell
        
        // Configure the cell...
        cell.titleLabel.text = articles[indexPath.row].title
        
        if articles[indexPath.row].read == false {
            cell.titleLabel.font = UIFont.boldSystemFontOfSize(15.0)
        } else {
            cell.titleLabel.font = UIFont.systemFontOfSize(15)
        }
        if articles[indexPath.row].attrdescription != nil {
            cell.descriptionLabel.attributedText = articles[indexPath.row].attrdescription as? NSAttributedString
        } else {
            cell.descriptionLabel.text = articles[indexPath.row].summary
            loadHtml(indexPath, article: articles[indexPath.row])
        }
        if articles[indexPath.row].date != nil {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "dd/MM/yy - HH:mm"
            cell.dateLabel.text = formatter.stringFromDate(articles[indexPath.row].date!)
            if articles[indexPath.row].author != nil {
                cell.dateLabel.text! += " / by " + articles[indexPath.row].author!
            }
        } else if articles[indexPath.row].author != nil {
            cell.dateLabel.text = " by " + articles[indexPath.row].author!
        }
        
        if (articles[indexPath.row].imagedata != nil) {
            let im = UIImage(data: articles[indexPath.row].imagedata!)
            cell.articleImageView.image = im
        } else if articles[indexPath.row].imageurl != nil {
            self.myRSS.download(articles[indexPath.row].imageurl!) {
                url in
                if url == nil {
                    return
                }
                let data = NSData(contentsOfURL: url)!
                self.articles[indexPath.row].imagedata = data
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.tableView.reloadRowsAtIndexPaths(
                        [indexPath], withRowAnimation: .None)
                })
            }
        } else {
            cell.articleImageView.image = nil
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("kShowArticleDetailsSegue", sender: indexPath)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "kShowArticleDetailsSegue" {
            let indexPath = sender as! NSIndexPath
            let destinationVC = segue.destinationViewController as! ArticleViewController
            destinationVC.article = articles[indexPath.row]
            articles[indexPath.row].read = true
        }
    }
    
}
