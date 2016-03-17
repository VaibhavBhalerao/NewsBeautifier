//
//  ArticleSearchTableViewController.swift
//  NewsBeautifier
//
//  Created by Ronaël Bajazet on 11/03/2016.
//  Copyright © 2016 NewsBeautifierTeam. All rights reserved.
//

import UIKit

class ArticleSearchTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var filteredArticles = [Article]()
    
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.active && self.searchController.searchBar.text != "" {
            return self.filteredArticles.count
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kArticleCellID, forIndexPath: indexPath)
        
        // Configure the cell...
        if self.searchController.active && self.searchController.searchBar.text != "" {
            cell.textLabel?.text = self.filteredArticles[indexPath.row].title
        }
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("kShowArticleDetailsSegue", sender: indexPath)
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        activityIndicator.startAnimating()
        self.activityView.hidden = false

        self.filteredArticles.removeAll(keepCapacity: false)
        
        if self.searchController.searchBar.text != "" {
            if let articlesArray = ArticleDAO.getArticlesSearch(searchController.searchBar.text!.componentsSeparatedByString(" ")) as? [Article] {
                self.filteredArticles = articlesArray
            }
        }

        activityIndicator.stopAnimating()
        self.activityView.hidden = true
        self.tableView.reloadData()
    }
    
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
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "kShowArticleDetailsSegue" {
            let indexPath = sender as! NSIndexPath
            let destinationVC = segue.destinationViewController as! ArticleViewController
            destinationVC.article = filteredArticles[indexPath.row]
        }
    }
}
