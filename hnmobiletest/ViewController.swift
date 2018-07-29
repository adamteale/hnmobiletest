/*
ViewController.swift
hnmobiletest

Created by adam on 7/17/18.
Copyright © 2018 adam. All rights reserved.

 */

import UIKit

class ViewController: UITableViewController {
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  var api_object : API_object?
  var deleted_items : [Hit]?
  var hitDateFormatter : DateFormatter?
  
  @IBOutlet var posts_tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(fetchPostData), for: .valueChanged)
    refreshControl.tintColor = UIColor.darkGray

    self.refreshControl = refreshControl
    tableView.dataSource = self
    tableView.delegate = self
    
    // restore array of deleted items for later filtering
    self.loadDeletedItems()

    // Get posts from from local JSON
    self.loadLocalData()
  }
  
  

  override func viewDidAppear(_ animated: Bool) {
    if Reachability.isConnectedToNetwork(){
      
      self.fetchPostData()
    }else{
      let alert = UIAlertController(title: "Network connection is not available.", message: "Make sure your device has an active connection.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
      self.present(alert, animated: true)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func setupDateFormatter(){
    self.hitDateFormatter = DateFormatter()
    self.hitDateFormatter?.dateStyle = .long
    self.hitDateFormatter?.timeStyle = .short
    self.hitDateFormatter?.doesRelativeDateFormatting = true
  }

  @objc private func fetchPostData()
  {
    
    // Test for connection and get JSON if available otherwise read from previously saved data
    if Reachability.isConnectedToNetwork(){
      let api_urlstring = "http://hn.algolia.com/api/v1/search_by_date?query=ios"
      guard let url = URL(string: api_urlstring) else{
        return
      }
      let urltask = URLSession.shared.dataTask(with: url, completionHandler:{(data: Data?, response: URLResponse?, error: Error?) in
        if error != nil {
          print(error!.localizedDescription)
        }
        guard let data = data else {
          return
        }
        //save JSON data locally for offline use
        do {
          try data.write(to: self.getLocalJSONFileURL(), options: [])
        } catch {
          print(error)
        }
        self.retrieveNewPostsFinishedCompletionHandler()
      })
      urltask.resume()
    }
    else{
      print("No network")



      let alert = UIAlertController(title: "Network connection is not available.",
                                    message: "Make sure your device has an active connection.",
                                    preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
//      DispatchQueue.main.async {
//        self.present(alert, animated: true)
//      }
      present(alert, animated: true) {
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
      }
    }
    

  }
  
  func retrieveNewPostsFinishedCompletionHandler()
  {
    loadLocalData()
    DispatchQueue.main.async {
      self.refreshControl?.endRefreshing()
      self.tableView.reloadData()
    }    
  }

  func getLocalJSONFileURL() -> URL {
    let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    let fileUrl = documentDirectoryUrl?.appendingPathComponent("api_post_data_v2.json")
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

  func loadLocalData(){
    do {
      let data = try Data(contentsOf: getLocalJSONFileURL(), options: .mappedIfSafe)
      let api_object_struct = try JSONDecoder().decode(API_object.self, from: data)
      //Trim if previously deleted
      let filteredHitsArray = Array(Set<Hit>(api_object_struct.hits!).subtracting(self.deleted_items!))
      let sortedfilteredHitsArray = filteredHitsArray.sorted(by: { $0.createdAt! > $1.createdAt! })
      self.api_object = api_object_struct
      self.api_object?.hits = sortedfilteredHitsArray
    }
    catch {
      // handle error
      print("Error reading local json file")
    }
  }
  
  // MARK: - Nav / Segue Methods
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showWebView", let destination = segue.destination as? WebView_ViewController, let post_index = tableView.indexPathForSelectedRow?.row{
      let story = self.api_object?.hits?[post_index]
      if (story?.storyURL) != nil{
        destination.post_url = self.api_object?.hits?[post_index].storyURL
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
    let hit = self.api_object?.hits![row]

    if (hit?.storyTitle) != nil{
      cell.title_label.text = hit?.storyTitle
    }
    else{
      cell.title_label.text = ""
    }

    if (hit?.author) != nil{
      author_and_date = (hit?.author)!
    }

    if (hit?.createdAt) != nil{
      let date: Date? = self.hitDateFormatter?.date(from: (hit?.createdAt)!)
      if let dateitemstring = self.hitDateFormatter?.string(from: date!){
        author_and_date = author_and_date + " - "  + dateitemstring
      }
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
      let hit = self.api_object?.hits![row]

      //Add to deleted items array
      self.deleted_items?.append((hit)!)
      self.api_object?.hits!.remove(at: row)
      self.saveDeletedItems()
      self.tableView.reloadData()
    }
  }
}
