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
 */
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class MainViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var postTableView: UITableView!
    
    
    
    // @IBOutlet weak var postsTableView: UITableView!
    var posts = [Post]()
    
    var users = [String:AnyObject]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.postTableView.delegate = self
        self.postTableView.dataSource = self
        loadData()
        self.postTableView.reloadData()
        
    }
    
    func loadData(){
        Database.database().reference().child("posts").observe(.childAdded, with:{(snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let post = Post()
                post.setValuesForKeys(dictionary)
                
                self.posts.append(post)
            }
         
        })
        
        
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: {(snapshot) in
            print("in users?")
            
            if let usersDictionary = snapshot.value as? [String: AnyObject]{
                
                for user in usersDictionary{
                    
                    self.users[user.key] = user.value
                    //.add(user.value)
                    
                }
                //Calls tableView function
                
                self.postTableView.reloadData()
            }
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return self.posts.count
    }
    
    
    // Indexpath is the counter of the current row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //loadData()
        // self.postTableView.reloadData()
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        
        // Configure the cell...
        //TODO±!!!!!!@# create post object. - model. and change anyobject to post!!!!!!!---
        
        let post = self.posts[indexPath.row]
        let user = self.users[post.uid!] as AnyObject
        
        cell.titleLable.text = user["username"] as? String
        
        
        
        //print("USEERRRR: \(Auth.auth().currentUser?.displayName)")
        cell.contentTextView.text = post.content
        let imageName = post.image
        let imageRef = Storage.storage().reference().child("Images/\(imageName!)")
        
        
        //1024*1024 is one megabyte and we want 25 megabyte
        print("This is the ref: \(imageRef)")
        
        cell.postImageView.downloadImageToCache(imageName: imageName!)
        
        cell.titleLable.alpha = 0
        cell.contentTextView.alpha = 0
        cell.postImageView.alpha = 0
        
        UIView.animate(withDuration: 0.4, animations: {
            cell.titleLable.alpha = 1
            cell.contentTextView.alpha = 1
            cell.postImageView.alpha = 1
            
        })
        return cell
    }
    
    @IBAction func backFromPost(unwindSegue: UIStoryboardSegue) {
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
  
    internal override func viewWillAppear(_ animated: Bool) {
         self.postTableView.reloadData()
    }
    
    
}
