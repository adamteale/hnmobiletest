//
//  ViewController.swift
//  hnmobiletest
//
//  Created by adam on 7/17/18.
//  Copyright © 2018 adam. All rights reserved.
//

import UIKit



class ViewController: UITableViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var posts_array = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self

        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshPostsData), for: .valueChanged)
        refreshControl.tintColor = UIColor.darkGray
        tableView.refreshControl = refreshControl
        
        
        self.title = "Recent Posts"
        
        print("view did load")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }


    func fetchPostData()
    {
        print("fetchPostData");
        
        let posts = API_request()
        posts.jsonResponseAsNSDictionary( {(response: API_object) -> () in
            
            self.posts_array.removeAll()
            print(response)

            self.refreshControl?.endRefreshing()
            
            DispatchQueue.main.async(execute: { self.tableView.reloadData() });
            
        })
        
    }
    
    @objc private func refreshPostsData(_ sender: Any) {
        print("refreshing");
        
        // Fetch Post Data
        fetchPostData()
    }
 
    
    
}

