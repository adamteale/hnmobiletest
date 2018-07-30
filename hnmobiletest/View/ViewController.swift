/*
ViewController.swift
hnmobiletest

Created by adam on 7/17/18.
Copyright © 2018 adam. All rights reserved.

 */

import UIKit
import KAWebBrowser

class ViewController: UITableViewController {

  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  var apiObject : APIObject?
  var previouslyDeletedItems : [Hit]?
  var hitDateFormatter : DateFormatter?
  var dateFormatterGet : DateFormatter?
  
  @IBOutlet var postsTableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(fetchPostData), for: .valueChanged)
    refreshControl.tintColor = UIColor.darkGray

    self.refreshControl = refreshControl
    tableView.dataSource = self
    tableView.delegate = self
    
    //Setup date formatters
    self.setupDateFormatters()
    
    // restore array of deleted items for later filtering
    self.loadDeletedItems()

    // Get posts from from local JSON
    self.loadLocalData()
  }

  override func viewDidAppear(_ animated: Bool) {
    // Check if network connection exists
    if Reachability.isConnectedToNetwork(){
      self.fetchPostData()
    }else{
      let alert = UIAlertController(title: "Network connection is not available.",
                                    message: "Make sure your device has an active connection.",
                                    preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
      self.present(alert, animated: true)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func setupDateFormatters(){
    self.dateFormatterGet = DateFormatter()
    self.dateFormatterGet?.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"

    self.hitDateFormatter = DateFormatter()
    self.hitDateFormatter?.dateStyle = .long
    self.hitDateFormatter?.timeStyle = .short
    self.hitDateFormatter?.doesRelativeDateFormatting = true
  }

  @objc private func fetchPostData()
  {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    // Test for connection and get JSON if available otherwise read from previously saved data
    if Reachability.isConnectedToNetwork(){
      
      let endPointAPIURL = "http://hn.algolia.com/api/v1/search_by_date?query=ios"
      guard let url = URL(string: endPointAPIURL) else{
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
      let alert = UIAlertController(title: "Network connection is not available.",
                                    message: "Make sure your device has an active connection.",
                                    preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
      present(alert, animated: true) {
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
      }
    }
    
  }
  
  func retrieveNewPostsFinishedCompletionHandler()
  {
    loadLocalData()
    DispatchQueue.main.async {
      self.refreshControl?.endRefreshing()
      self.tableView.reloadData()
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
  }

  func getLocalJSONFileURL() -> URL {
    let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    let fileUrl = documentDirectoryUrl?.appendingPathComponent("api_post_data_v2.json")
    return fileUrl!
  }
  
  func saveDeletedItems()
  {
    UserDefaults.standard.set(try? PropertyListEncoder().encode(self.previouslyDeletedItems), forKey:"deleted_items")
  }

  func loadDeletedItems()
  {
    if let data = UserDefaults.standard.value(forKey:"deleted_items") as? Data {
      self.previouslyDeletedItems = try? PropertyListDecoder().decode(Array<Hit>.self, from: data)
    }else{
      self.previouslyDeletedItems = []
    }
  }

  func loadLocalData(){
    do {
      let data = try Data(contentsOf: getLocalJSONFileURL(), options: .mappedIfSafe)
      let apiObjectStruct = try JSONDecoder().decode(APIObject.self, from: data)
      //Trim if previously deleted
      let filteredHitsArray = Array(Set<Hit>(apiObjectStruct.hits!).subtracting(self.previouslyDeletedItems!))
      let sortedfilteredHitsArray = filteredHitsArray.sorted(by: { $0.createdAt! > $1.createdAt! })
      self.apiObject = apiObjectStruct
      self.apiObject?.hits = sortedfilteredHitsArray
    }
    catch {
      print("Error reading local json file: \(error)")
    }
  }
  
  // MARK: - TableView Methods
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let itemcount = self.apiObject?.hits?.count else {
      return 0
    }
    return itemcount
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostTableViewCell
    var authorWithDate = ""
    let row = indexPath.row
    let hit = self.apiObject?.hits![row]

    if (hit?.storyTitle) != nil{
      cell.titleLabel.text = hit?.storyTitle
    }
    else if (hit?.title) != nil{
      cell.titleLabel.text = hit?.title
    }    else{
      cell.titleLabel.text = ""
    }

    if (hit?.author) != nil{
      authorWithDate = (hit?.author)!
    }

    if (hit?.createdAt) != nil{
      let createdAtDateFormatted: Date? = self.dateFormatterGet?.date(from: (hit?.createdAt)!)
      if let dateitemstring = self.hitDateFormatter?.string(from: createdAtDateFormatted!){
        authorWithDate = authorWithDate + " - "  + dateitemstring
      }
    }
    
    cell.authorWithTimeLabel.text = authorWithDate
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let hit = self.apiObject?.hits?[indexPath.row]
    if let storyURL = hit?.storyURL{
      let browser = KAWebBrowser()
      show(browser, sender: nil)
      navigationController?.isNavigationBarHidden = false
      browser.loadURL(storyURL)
    }else{
      let alert = UIAlertController(title: "Story doesn't contain a vaild URL.",
                                    message: "",
                                    preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
      self.present(alert, animated: true)
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }

  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if (editingStyle == UITableViewCellEditingStyle.delete) {
      
      let row = indexPath.row
      let hit = self.apiObject?.hits![row]

      //Add to deleted items array
      self.previouslyDeletedItems?.append((hit)!)
      self.apiObject?.hits!.remove(at: row)
      self.saveDeletedItems()
      self.tableView.reloadData()
    }
  }
}


