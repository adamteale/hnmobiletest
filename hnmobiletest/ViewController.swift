/*
ViewController.swift
hnmobiletest

Created by adam on 7/17/18.
Copyright © 2018 adam. All rights reserved.

- test for connection - load previous if exists or GET from API
- retrieve json data & decode
- write data to user defaults
- refresh tableview from saved data
- format date
- sort posts by date
- push to web view
- swipe to delete

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
    
    // restore array of deleted items for later filtering
    self.loadDeletedItems()
    // Get posts from API or from local JSON
    self.fetchPostData()

  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  func fetchPostData()
  {
    
    // Test for connection and collect json if available
    if Reachability.isConnectedToNetwork(){

      let api_urlstring = "http://hn.algolia.com/api/v1/search_by_date?query=ios"

      guard let url = URL(string: api_urlstring) else
      { return }
      
      let urltask = URLSession.shared.dataTask(with: url, completionHandler:{(data: Data?, response: URLResponse?, error: Error?) in
        
        if error != nil {
          print(error!.localizedDescription)
        }
        
        guard let data = data else { return }
        
        //save JSON data locally for offline use
        do {
          try data.write(to: self.getLocalJSONFileURL(), options: [])
        } catch {
          print(error)
        }

        self.retrieveNewPostsFinishedCompletionHandler()
        
      })
      
      urltask.resume()

    }else{
      print("Internet Connection not Available!")
    }

    do {
      let data = try Data(contentsOf: getLocalJSONFileURL(), options: .mappedIfSafe)
      let api_object_struct = try JSONDecoder().decode(API_object.self, from: data)
      
      //Trim if previously deleted
      let filteredHitsArray = Array(Set<Hit>(api_object_struct.hits!).subtracting(self.deleted_items!))
      let sortedfilteredHitsArray = filteredHitsArray.sorted(by: { $0.created_at! > $1.created_at! })
      
      self.api_object = api_object_struct
      self.api_object?.hits = sortedfilteredHitsArray
    }
    catch {
      // handle error
      print("Error reading local json file")
    }
    
  }
  
  
  @objc private func refreshPostsData(_ sender: Any) {
    fetchPostData()
  }
 
  
  func retrieveNewPostsFinishedCompletionHandler()
  {
    DispatchQueue.main.async {
      self.tableView.refreshControl?.endRefreshing()
      self.tableView.reloadData()
    }
    
  }

  
  func getLocalJSONFileURL() -> URL {
    
    let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    let fileUrl = documentDirectoryUrl?.appendingPathComponent("api_post_data.json")
    
    return fileUrl!
  }
  
  func saveDeletedItems()
  {
    UserDefaults.standard.set(try? PropertyListEncoder().encode(self.deleted_items), forKey:"deleted_items")
  }

  func loadDeletedItems()
  {
    if let data = UserDefaults.standard.value(forKey:"deleted_items") as? Data {
      self.deleted_items = try? PropertyListDecoder().decode(Array<Hit>.self, from: data)
    }else{
      self.deleted_items = []
    }
    
  }

  // MARK: - Nav / Segue Methods

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if  segue.identifier == "showWebView",
      let destination = segue.destination as? WebView_ViewController,
      let post_index = tableView.indexPathForSelectedRow?.row
    {
      if (self.api_object?.hits?[post_index].story_url) != nil{
        destination.post_url = self.api_object?.hits?[post_index].story_url
        print(destination.post_url)
      }
    }
  }
  

  // MARK: - TableView Methods
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
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
      let dateFormatterGet = DateFormatter()
      dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"

      let date: Date? = dateFormatterGet.date(from: (self.api_object?.hits![row].created_at)!)
      
      let dateFormatter = DateFormatter()
      dateFormatter.dateStyle = .long
      dateFormatter.timeStyle = .short
      dateFormatter.doesRelativeDateFormatting = true
      
      let dateitemstring = dateFormatter.string(from: date!)
      
      author_and_date = author_and_date + " - "  + dateitemstring

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
      self.saveDeletedItems()
      self.tableView.reloadData()
    }
  }

}

