//
//  MainViewController.swift
//  InstaTrip
//
//  Created by Dana Tsirulnik on 09/01/2018.
//  Copyright © 2018 Eden Ben Shoshan. All rights reserved.
//




// TODO:  BUGLIST:
/*
 *board is empty; user addes a post. goes back, still empty. had to logout..
 *user creates a new post - after it finished uploading it stays in the same screen! bad!!!!!! must go to explore.
 *new post does not appera automaticly. BAD!
 *TODO: Add observe to see if a user added a photo , and refresh the page
 */
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SQLite
import ReachabilitySwift


class MainViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate  , NetworkStatusListener {
    
    
    @IBOutlet weak var postTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    // @IBOutlet weak var postsTableView: UITableView!
    var posts = [Post]()
    var shits = [Post]()
    var currPosts = [Post]()
    var users = [String:AnyObject]()
    var usersListUp = User()
    var usersA = [String:AnyObject]()
    
    var database: Connection!
    let offlinePostsTable = Table("offlinePostsTable")
    let uid = Expression<String>("uid")
    let tags = Expression<String>("tags")
    let content = Expression<String>("content")
    let imageData = Expression<String>("imageData")
    let id = Expression<Int>("id")
    
    
    
    
    
    override func viewDidLoad() {
        
        
        print("in view did load")
        if Auth.auth().currentUser == nil {
            // user is loggedin
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
            self.present(vc!, animated: false, completion:nil )
            
            
        }
        
        
        
        super.viewDidLoad()
        
        /*  do {
         let documentDirectory = try  FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true )
         let fileUrl = documentDirectory.appendingPathComponent("posts").appendingPathExtension("sqlite3")
         let database = try Connection(fileUrl.path)
         self.database = database
         // createTable()
         } catch {
         print (error)
         }
         //  createTable()
         */
        
        self.postTableView.delegate = self
        self.postTableView.dataSource = self
        
        posts.removeAll()
        currPosts.removeAll()
      
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: {
            //  self.loadData()
        })
        
        
        self.postTableView.reloadData()
        self.searchBar.delegate = self
        setUpSearchBar()
    }
    
    // Adding - when loading data, each time it will write also to the db.
    // it will try to download new photos only if we are connected to the internet,
    func loadData(){
        
        
        currPosts.removeAll()
        posts.removeAll()
        SqlPostsModel.connectDB()
        SqlPostsModel.delAll()
        SqlPostsModel.createTable()
        
        SqlPostsModel.insertPost()
         SqlPostsModel.delAll()
        print("in load data")
        
        // Run only if internet connection is available.
        /*Database.database().reference().child("posts").observe(.childAdded, with:{(snapshot) in
         if let dictionary = snapshot.value as? [String: AnyObject]{
         let post = Post()
         post.setValuesForKeys(dictionary)
         
         self.posts.append(post)
         
         }
         self.currPosts = self.posts
         
         })*/
       FirebaseModel.getPosts{ (response) in
            
            guard  let postsA = response as? [Post] else {return}
            //  print("This is the users list and response\(usersList) \(response)")
            self.posts = postsA
            self.currPosts = self.posts
            
        }
        
        // self.posts =
        
        
        FirebaseModel.getUsers { (response) in
            
            guard  let usersA = response  as? [String : AnyObject] else {return}
            //  print("This is the users list and response\(usersList) \(response)")
            self.users = usersA
            self.postTableView.reloadData()
        }
       // var apo = [Post]()
        
       
        self.shits = SqlPostsModel.listPosts()
        for shit in SqlPostsModel.listPosts() {
            print("this is in shits")
            print(shit.content)
        }
        self.posts = SqlPostsModel.listPosts()
        self.currPosts = self.posts
        print("shits \(shits.count)")
        //print("this is the amount AAA\(.count)")
        

        }
        
        override func didReceiveMemoryWarning() {
            print("MEMEOO")
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        
        
        func numberOfSections(in tableView: UITableView) -> Int {
            
            
            return 1
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // insertPost()
            return self.currPosts.count
        }
        
        
        // Indexpath is the counter of the current row
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            print("in table view")
            //loadData()
            // self.postTableView.reloadData()
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
            
            // Configure the cell...
            //TODO±!!!!!!@# create post object. - model. and change anyobject to post!!!!!!!---
            
            let post = self.currPosts[indexPath.row]
            print("posts \(post.image)")
            let user = self.users[post.uid!] as AnyObject
            
            cell.titleLable.text = user["username"] as? String
            
            
            
            //print("USEERRRR: \(Auth.auth().currentUser?.displayName)")
            cell.contentTextView.text = post.content
            let imageName = post.image
            let imageRef = Storage.storage().reference().child("Images/\(imageName!)")
            
            
            //1024*1024 is one megabyte and we want 25 megabyte
            print("This is the ref: \(imageRef)")
            
            
            
            cell.titleLable.alpha = 0
            cell.contentTextView.alpha = 0
            cell.postImageView.alpha = 0
            
            UIView.animate(withDuration: 0.4, animations: {
                cell.titleLable.alpha = 1
                cell.contentTextView.alpha = 1
                cell.postImageView.alpha = 1
                
                
            })
            cell.postImageView.downloadImageToCache(imageName: imageName!)
            return cell
        }
        
        @IBAction func backFromPost(unwindSegue: UIStoryboardSegue) {
            // Rewind from Post screen
        }
        @IBAction func backFromProfile(unwindSegue: UIStoryboardSegue) {
            // Rewind from Post screen
        }
        
        
        @IBAction func logoutTapped(_ sender: Any) {
            
            // TODO: Check do try catch syntax
            do {
                try Auth.auth().signOut()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
                self.present(vc!, animated: true, completion: nil)
                
            } catch{
                print("ERROR SIGNING OUT USER!")
                
            }
        }
        
        internal override func viewDidAppear(_ animated: Bool) {
            
            self.loadData()
            
            
            
        }
        
        private func setUpSearchBar(){
            
        }
        internal func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            print("inside search")
            guard !searchText.isEmpty else {
                currPosts = posts
                postTableView.reloadData()
                return
            }
            currPosts = posts.filter({post -> Bool in
                return  post.content!.contains(searchText)
            })
            print(currPosts)
            postTableView.reloadData()
            
        }
        func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
            
        }
        func networkStatusDidChange(status: Reachability.NetworkStatus) {
            switch status {
            case .notReachable:
                debugPrint("ViewController: Network became unreachable")
                let alertController = UIAlertController(title: "iOScreator", message:
                    "Hey travler you should know that you are not connected to the internet, but thats ok. You can still explore."
                    , preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
            case .reachableViaWiFi:
                debugPrint("ViewController: Network reachable through WiFi")
            case .reachableViaWWAN:
                debugPrint("ViewController: Network reachable through Cellular Data")
            }
            
        }
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            ReachabilityManager.shared.addListener(listener: self)
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            ReachabilityManager.shared.removeListener(listener: self)
        }
        @IBAction func createTable(){
            
            let createTable = self.offlinePostsTable.create(ifNotExists: true)  { (table) in
                table.column(self.id, primaryKey: true)
                table.column(self.imageData)
                table.column(self.uid)
                table.column(self.tags)
                table.column(self.content)
            }
            do {
                try self.database.run(createTable)
                print("Successfull!")
                
            }catch {
                print("Error!!!: \(error)")
            }
        }
        
        
        
    
        
        
        
        
        
        
        
}
