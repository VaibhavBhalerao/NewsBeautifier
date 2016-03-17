//
//  ArticleTableViewController.swift
//  NewsBeautifier
//
//  Created by Ronaël Bajazet on 10/03/2016.
//  Copyright © 2016 NewsBeautifierTeam. All rights reserved.
//

import UIKit

class ArticleTableViewController: UITableViewController {
    
    let myRSS = UrlSessionManager(configuration: .defaultSessionConfiguration())
    var feed: Feed?
    var articles: [Article]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the reflesh control action
        self.refreshControl!.addTarget(self, action: "doRefresh:", forControlEvents: .ValueChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.articles?.sortInPlace({ $0.date!.compare($1.date!) == .OrderedDescending })
        self.navigationItem.title = articles?.first?.feed?.name
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func doRefresh(sender: AnyObject) {
        self.articles?.removeAll(keepCapacity: false)
        
        self.articles = feed?.getAllArticles() as? [Article]
        self.articles?.sortInPlace({ $0.date!.compare($1.date!) == .OrderedDescending })
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
        if articles!.isEmpty {
            self.tableView.separatorStyle = .None
        } else {
            self.tableView.separatorStyle = .SingleLine
        }
        return articles!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kArticleCellID, forIndexPath: indexPath) as! ArticleTableViewCell
        
        // Configure the cell...
        cell.titleLabel.text = articles![indexPath.row].title
        if articles![indexPath.row].attrdescription != nil {
            cell.descriptionLabel.attributedText = articles![indexPath.row].attrdescription as? NSAttributedString
        } else {
            cell.descriptionLabel.text = articles![indexPath.row].summary
            loadHtml(indexPath, article: articles![indexPath.row])
        }
        if articles![indexPath.row].date != nil {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "dd/MM/yy - HH:mm"
            cell.dateLabel.text = formatter.stringFromDate(articles![indexPath.row].date!)
            if articles![indexPath.row].author != nil {
                cell.dateLabel.text! += " / by " + articles![indexPath.row].author!
            }
        } else if articles![indexPath.row].author != nil {
            cell.dateLabel.text = " by " + articles![indexPath.row].author!
        }
        
        if (articles![indexPath.row].imagedata != nil) {
            let im = UIImage(data: articles![indexPath.row].imagedata!)
            cell.articleImageView.image = im
            cell.articleImageView.hidden = false
        } else if articles![indexPath.row].imageurl != nil {
            self.myRSS.download(articles![indexPath.row].imageurl!) {
                url in
                if url == nil {
                    return
                }
                let data = NSData(contentsOfURL: url)!
                self.articles![indexPath.row].imagedata = data
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
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("kShowArticleDetailsSegue", sender: indexPath)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "kShowArticleDetailsSegue" {
            let indexPath = sender as! NSIndexPath
            let destinationVC = segue.destinationViewController as! ArticleViewController
            destinationVC.article = articles![indexPath.row]
        }
    }
    
}
