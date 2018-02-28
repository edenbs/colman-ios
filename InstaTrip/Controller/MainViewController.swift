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
import SQLite
import ReachabilitySwift


class MainViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate  , NetworkStatusListener {
    
    
    
    
    @IBOutlet weak var postTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    // @IBOutlet weak var postsTableView: UITableView!
    var posts = [Post]()
    var shits = [Post]()
    var currPosts = [Post]()
    var users = [User]()
    var usersListUp = User()
    var usersA = [String:AnyObject]()
    //var networkStat = Int()
    var profileTabItem : UITabBarItem?
    var postTabItem : UITabBarItem?
   
    

    override func viewDidLoad() {
      let tabitems = self.tabBarController?.tabBar.items
        if let tabarray = tabitems{
            postTabItem = tabarray[1];
           profileTabItem = tabarray[2];
            
            
        }
        // TODO do not use fire base here!
       
        if  AuthUser.isUserConnected() == nil {
            //Auth.auth().currentUser == nil {
            // user is loggedin
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
            self.present(vc!, animated: false, completion:nil )
  
        }
        
        super.viewDidLoad()
        postTableView.isUserInteractionEnabled = true
        
        Post.listenToChange()
        
        
        
        //adding the event of added post to the notification center.
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.actOnChildAdded), name: NSNotification.Name(rawValue: postAddedNotification), object: nil)
        
        //adding delegates.
        self.postTableView.delegate = self
        self.postTableView.dataSource = self
        
        posts.removeAll()
        currPosts.removeAll()
        
        
        
        
        self.postTableView.reloadData()
        self.searchBar.delegate = self
        setUpSearchBar()
        
        if(!OfflineHelper.isOnline()){
            postTabItem?.isEnabled = false
            profileTabItem?.isEnabled = false
        }
        else{
            postTabItem?.isEnabled = true
            profileTabItem?.isEnabled = true
        }
    }
    
    
    
    
    
    func loadData(complition: @escaping () -> Void ){
        print("in load data")
        // 0 NO net
       // self.networkStat =      //ReachabilityManager.shared.reachability.currentReachabilityStatus.hashValue
        
        
        currPosts.removeAll()
        posts.removeAll()
        DispatchQueue.global(qos: .background).async {
            SqlPostsModel.connectDB()
            
            
            
            // Run only if internet connection is available.
            if (OfflineHelper.isOnline() )
            {
                print("in internet?!")
                User.getUsers(complition: {(response) in
                    guard let usersA = response  as? [User] else {return}
                    //  print("This is the users list and response\(usersList) \(response)")
                    
                    print("in get usere")
                    self.users = usersA
                    Post.getPosts(users: self.users){ (response) in
                        
                        guard  let postsA = response as? [Post] else {return}
                        //  print("This is the users list and response\(usersList) \(response)")
                        self.posts = postsA
                        self.currPosts = self.posts
                        print("1756: posts: \(self.currPosts.count)")
                        self.postTableView.reloadData()
                    }
                    
                })
                print("useres array length:\(self.users.count)")
                
                print("inside the net")

            }
                
                
            else {
                print("inside the  NOT net")
                self.posts = PostOffline().listPosts(database: SqlPostsModel.database!)
                //SqlPostsModel.listPosts()
                self.currPosts = self.posts
                DispatchQueue.main.async { // Correct
                    self.postTableView.reloadData()
                }
                
                
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
        print("1756")
        print(self.currPosts.count)
        print( section)
        return self.currPosts.count
    }
    
    
    // Indexpath is the counter of the current row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        print("in table view")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        
        
        print("curr posts: \(self.currPosts)")
        let post = self.currPosts[indexPath.row]
        
        if (OfflineHelper.isOnline() )
        {
            if let i = users.index(where: { $0.uid == post.uid! }) {
                cell.titleLable.text = users[i].username!
                print("this is the username:\(users[i].username!)")
            }
            else{
                cell.titleLable.text = "Error"
                print("this is the error:\(users)")
            }
         
        }else{
            cell.titleLable.text = self.currPosts[indexPath.row].username
        }
        
        
        
        cell.contentTextView.text = post.content
        let imageName = post.image
        
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
            try AuthUser.signout()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
            self.present(vc!, animated: true, completion: nil)
            
        } catch{
            print("ERROR SIGNING OUT USER!")
            
        }
    }
    
    internal override func viewDidAppear(_ animated: Bool) {
        print("in view did appear")
        
        //ADD THIS IS PROBLEMS APPEAR.
        // self.loadData(complition: {})
        
        
        
    }
    
    // Application became active - load data.
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        loadData(complition: {})
    }
    
    private func setUpSearchBar(){
        
    }
    
 
    internal func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("inside search")
        // gaurd - if unwrapping fails. meaning that searchText is nil like if let else
        guard !searchText.isEmpty else {
            currPosts = posts
            postTableView.reloadData()
            return
        }
        currPosts = posts.filter({post -> Bool in
            var isFound: Bool
            isFound = (post.content!.lowercased().contains(searchText.lowercased()) || post.tags!.lowercased().contains(searchText.lowercased()))
            return  isFound
        })
        postTableView.reloadData()
        
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
    }
    
    // When connected to internet delete sql posts.
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
            postTabItem?.isEnabled = false
            profileTabItem?.isEnabled = false
        case .reachableViaWiFi:
            print("this is WIFI ")
            loadData(complition: {})
            postTabItem?.isEnabled = true
            profileTabItem?.isEnabled = true
            
        case .reachableViaWWAN:

            loadData(complition: {})
            debugPrint("ViewController: Network reachable through Cellular Data")
            postTabItem?.isEnabled = true
            profileTabItem?.isEnabled = true
            
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        //Add the listiner of the network
        ReachabilityManager.shared.addListener(listener: self)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    //if a post was added to the db. load data.
    func actOnChildAdded() {
        loadData(complition: {})
        
    }
    
    @IBAction func tapped(_ sender: Any) {
        self.searchBar.endEditing(true)
    }
    
    
    
    
    
    
    
    
}
