//
//  ArticleViewController.swift
//  NewsBeautifier
//
//  Created by Ronaël Bajazet on 10/03/2016.
//  Copyright © 2016 NewsBeautifierTeam. All rights reserved.
//

import UIKit
import SafariServices

class ArticleViewController: UIViewController, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infosLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var loadLabel: UIButton!
    
    var article: Article?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        titleLabel.text = article?.title
        descriptionLabel.text = article!.summary!
        
        if article!.date != nil {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "dd/MM/yy - HH:mm"
            infosLabel.text = formatter.stringFromDate(article!.date!)
            if article!.author != nil {
                infosLabel.text! += " / by " + article!.author!
            }
        } else if article!.author != nil {
            infosLabel.text = " by " + article!.author!
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 10
        
        queue.addOperationWithBlock { () -> Void in
            let content = try! NSMutableAttributedString(
                data: self.article!.summary!.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
                options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                documentAttributes: nil)
            content.enumerateAttribute(NSAttachmentAttributeName, inRange: NSMakeRange(0, content.length), options: NSAttributedStringEnumerationOptions(rawValue: 0)) { (value, range, stop) -> Void in
                if let attachement = value as? NSTextAttachment {
                    let image = attachement.imageForBounds(attachement.bounds, textContainer: NSTextContainer(), characterIndex: range.location)
                    let screenSize: CGRect = UIScreen.mainScreen().bounds
                    if image!.size.width > screenSize.width-2 {
                        let newImage = image?.resizeImage(self.view.frame.width / image!.size.width)
                        let newAttribut = NSTextAttachment()
                        newAttribut.image = newImage
                        content.addAttribute(NSAttachmentAttributeName, value: newAttribut, range: range)
                    }
                }
            }
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.descriptionLabel.attributedText = content
                self.view.layoutIfNeeded()
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showArticle(sender: UIButton) {
        if let url = NSURL(string: self.article!.url!) {
            let safariVC = SFSafariViewController(URL: url, entersReaderIfAvailable: true)
            safariVC.delegate = self
            self.presentViewController(safariVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func shareArticle(sender: UIBarButtonItem) {
        let textTitle = article!.title! as String
        let link = NSURL(string: article!.url!)! as NSURL
        
        let objectsToShare = [textTitle, link]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    // MARK: - SFSafariViewControllerDelegate
    func safariViewControllerDidFinish(controller: SFSafariViewController)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func safariViewController(controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        if !didLoadSuccessfully {
            print("bruh")
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "kShowWebViewSegue" {
            let destVC = segue.destinationViewController as! ArticleWebViewController
            destVC.urlText = article?.url
        }
    }
}

extension UIImage {
    func resizeImage(scale: CGFloat) -> UIImage {
        let newSize = CGSizeMake(self.size.width*scale, self.size.height*scale)
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        UIGraphicsBeginImageContext(newSize)
        self.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
