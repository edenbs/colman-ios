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
 * TODO: add users also to offline table.
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
    var networkStat = Int()
    
    
    
    
    
    
    
    override func viewDidLoad() {
        
        
        print("in view did load")
        if Auth.auth().currentUser == nil {
            // user is loggedin
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
            self.present(vc!, animated: false, completion:nil )
            
            
        }
        
        
        
        super.viewDidLoad()
        
        Post.listenToChange()
        
        
      
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.actOnChildAdded), name: NSNotification.Name(rawValue: postAddedNotification), object: nil)
        
        self.postTableView.delegate = self
        self.postTableView.dataSource = self
        
        posts.removeAll()
        currPosts.removeAll()
        
        
        
        
        self.postTableView.reloadData()
        self.searchBar.delegate = self
        setUpSearchBar()
    }
    
    
    
    
    
    func loadData(complition: @escaping () -> Void ){
        // 0 NO net
        self.networkStat = ReachabilityManager.shared.reachability.currentReachabilityStatus.hashValue
        
        
        currPosts.removeAll()
        posts.removeAll()
        DispatchQueue.global(qos: .background).async {
            SqlPostsModel.connectDB()
            //SqlPostsModel.delAll()
            
            
            
            //   SqlPostsModel.delAll()
            print("in load data")
            
            // Run only if internet connection is available.
            
            if (self.networkStat != 0)
            {
                print("inside the net")
                FirebaseModel.getPosts{ (response) in
                    
                    guard  let postsA = response as? [Post] else {return}
                    //  print("This is the users list and response\(usersList) \(response)")
                    self.posts = postsA
                    self.currPosts = self.posts
                    
                }
                FirebaseModel.getUsers { (response) in
                    
                    guard  let usersA = response  as? [String : AnyObject] else {return}
                    //  print("This is the users list and response\(usersList) \(response)")
                    self.users = usersA
                    self.postTableView.reloadData()
                }
                
               
            }
                
                
            else {
                print("inside the  NOT net")
                self.posts = PostOffline().listPosts(database: SqlPostsModel.database!)
                //SqlPostsModel.listPosts()
                self.currPosts = self.posts
                
            }
            complition()
        }
        
        
        
        
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
        self.networkStat = ReachabilityManager.shared.reachability.currentReachabilityStatus.hashValue
        print("in table view")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        
        
        //TODO±!!!!!!@# create post object. - model. and change anyobject to post!!!!!!!---
        
        let post = self.currPosts[indexPath.row]
        // print("posts \(post.image)")
        let user = self.users[post.uid!] as AnyObject
        
        cell.titleLable.text = user["username"] as? String
        
        
        
        
        cell.contentTextView.text = post.content
        let imageName = post.image
        // let imageRef = Storage.storage().reference().child("Images/\(imageName!)")
        
        
        //1024*1024 is one megabyte and we want 25 megabyte
        //  print("This is the ref: \(imageRef)")
        
        
        
        /* cell.titleLable.alpha = 0
         cell.contentTextView.alpha = 0
         cell.postImageView.alpha = 0*/
        
        UIView.animate(withDuration: 0.4, animations: {
            cell.titleLable.alpha = 1
            cell.contentTextView.alpha = 1
            cell.postImageView.alpha = 1
            
            
        })
        
        
        post.getPostImage(imageView: cell.postImageView)
        
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
        print("in view did appear")
        self.loadData(complition: {})
        
        
        
    }
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        print("LLLOOOOKKK!!")
        loadData(complition: {})
    }
    
    private func setUpSearchBar(){
        
    }
    
    //TODO: add search by tags
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
            loadData(complition: {})
            debugPrint("ViewController: Network became unreachable")
            
            let alertController = UIAlertController(title: "iOScreator", message:
                "Hey travler you should know that you are not connected to the internet, but thats ok. You can still explore."
                , preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        case .reachableViaWiFi:
            print("this is WIFI ")
            loadData(complition: {})
            //SqlPostsModel.createTable()
            //  SqlPostsModel.insertPost()
            
            
            
            
            
        // debugPrint("ViewController: Network reachable through WiFi")
        case .reachableViaWWAN:
            //  SqlPostsModel.createTable()
            //  SqlPostsModel.insertPost()
            loadData(complition: {})
            debugPrint("ViewController: Network reachable through Cellular Data")
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        ReachabilityManager.shared.addListener(listener: self)
        print("stats: \(ReachabilityManager.shared.isNetworkAvailable)")
        print("stats: \(ReachabilityManager.shared.reachability.currentReachabilityStatus.hashValue)")
        print("stats: \(ReachabilityManager.shared.reachabilityStatus)")
        print("stats: \(Reachability.NetworkStatus.notReachable)")
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    func actOnChildAdded() {
        loadData(complition: {})
        
    }
    
    
    
    
    
    
    
    
    
    
}
