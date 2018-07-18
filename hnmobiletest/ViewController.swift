/*
ViewController.swift
hnmobiletest

Created by adam on 7/17/18.
Copyright © 2018 adam. All rights reserved.

- test for connection - load previous if exists or GET from API
- retrieve json data & decode
* write data to user defaults
- refresh tableview from saved data
- format date
- push to web view
- swipe to delete
* update URL string

 */

import UIKit



class ViewController: UITableViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var api_object : API_object?
    var deleted_items : [Hit]?
    
    
    @IBOutlet var posts_tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshPostsData), for: .valueChanged)
        refreshControl.tintColor = UIColor.darkGray
        tableView.refreshControl = refreshControl
        
        // Get posts from API
        self.fetchPostData()

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    func fetchPostData()
    {
        if Reachability.isConnectedToNetwork(){

            //let api_urlstring = "http://hn.algolia.com/api/v1/search_by_date?query=ios"
            let api_urlstring = "https://api.myjson.com/bins/b6whq"
            
            guard let url = URL(string: api_urlstring) else
            { return }
            
            let urltask = URLSession.shared.dataTask(with: url, completionHandler:{(data: Data?, response: URLResponse?, error: Error?) in
                
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                guard let data = data else { return }
                
                //Implement JSON decoding and parsing
                do {
                    let api_object_struct = try JSONDecoder().decode(API_object.self, from: data)
                    var hits : [Hit] = []
                    //Trim
                    for item in self.deleted_items!
                    {
                        
                    }

                    for item in api_object_struct.hits!
                    {
                        
                    }

                    self.api_object = api_object_struct
                    
                } catch let jsonError {
                    print(jsonError)
                }
                self.retrieveNewPostsFinishedCompletionHandler()
                
            })
            
            urltask.resume()

        }else{
            print("Internet Connection not Available!")
        }

        
    }
    
    
    @objc private func refreshPostsData(_ sender: Any) {
        // Fetch Post Data
        fetchPostData()
    }
 
    
    func retrieveNewPostsFinishedCompletionHandler()
    {
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
        
    }


    func saveJSONToDocuments(){
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        let filename = paths[0].appendingPathComponent("api_post_data.txt")
        let data = NSKeyedArchiver.archivedData(withRootObject: self.api_object!)

        do {
            try data.write(to: filename)
        } catch {
            print("error saving")
        }
    }
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "showWebView",
            let destination = segue.destination as? WebView_ViewController,
            let post_index = tableView.indexPathForSelectedRow?.row
        {
            if (self.api_object?.hits?[post_index].story_url) != nil{
                destination.post_url = self.api_object?.hits?[post_index].story_url
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let itemcount = self.api_object?.hits?.count else {
            return 0
        }
        return itemcount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! Post_TableViewCell
        var author_and_date = ""


        let row = indexPath.row

        if (self.api_object?.hits![row].story_title) != nil
        {
            cell.title_label.text = self.api_object?.hits![row].story_title
        }
        else
        {
            cell.title_label.text = ""
        }

        if (self.api_object?.hits![row].author) != nil
        {
            author_and_date = (self.api_object?.hits![row].author)!
        }

        if (self.api_object?.hits![row].created_at) != nil
        {
            author_and_date = author_and_date + " - "  + (self.api_object?.hits![row].created_at)!
        }
        
        cell.authorAndTime_label.text = author_and_date

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            let row = indexPath.row
            
            //Add to deleted items array
            self.deleted_items?.append((self.api_object?.hits![row])!)
            self.api_object?.hits!.remove(at: row)
            
            self.tableView.reloadData()
        }
    }

}

