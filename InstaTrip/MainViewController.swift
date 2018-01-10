//
//  MainViewController.swift
//  InstaTrip
//
//  Created by Dana Tsirulnik on 09/01/2018.
//  Copyright © 2018 Eden Ben Shoshan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class MainViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var postTableView: UITableView!
    
   // @IBOutlet weak var postsTableView: UITableView!
    var posts = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.postTableView.delegate = self
        self.postTableView.dataSource = self
        
        loadData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func loadData(){
        Database.database().reference().child("posts").observeSingleEvent(of: .value, with: { (snapshot) in
            if let postsDictionary = snapshot.value as? [String: AnyObject]{
                for post in postsDictionary{
                    self.posts.add(post.value)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell

        // Configure the cell...
        //TODO±!!!!!!@# create post object. - model. and change anyobject to post!!!!!!!---
        let post = self.posts[indexPath.row] as! [String: AnyObject]
        cell.titleLable.text = post["tags"] as? String
        //let user = Database.database().reference().child("users").child((post["uid"] as? String)!)
       
        print("this \( post["uid"] )")
        //print("USEERRRR: \(Auth.auth().currentUser?.displayName)")
        cell.contentTextView.text = post["content"] as? String
        let imageName = post["image"] as? String //The name of the image
        let imageRef = Storage.storage().reference().child("Images/\(imageName!)")

        //1024*1024 is one megabyte and we want 25 megabyte
        print("This is the ref: \(imageRef)")
        imageRef.getData(maxSize: 25 * 1024 * 1024, completion: {(data, err) -> Void in
            if err == nil {
                //GOOD
                let image = UIImage(data: data!)
                print(image!)
                cell.postImageView.image = image
            }else {
               // error
                print("Error downloading image\(err?.localizedDescription)")
            }
        })
        
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
