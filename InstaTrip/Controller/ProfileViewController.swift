//
//  ProfileViewController.swift
//  InstaTrip
//
//  Created by Dana Tsirulnik on 26/01/2018.
//  Copyright © 2018 Eden Ben Shoshan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
class ProfileViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    
  //  @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var nothingLable: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
   // @IBOutlet weak var usernameLable: UILabel!
    var userPosts = [Post]()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        if Auth.auth().currentUser == nil {
            // user is loggedin
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
            self.present(vc!, animated: false, completion:nil )
            
        }
        else{
           // self.usernameLable.text = Auth.auth().currentUser?.email
            nothingLable.isHidden = true
            
        }
       
       
       
        
    }
    func loadData(){
        Post.getPostByUserID(uid: (Auth.auth().currentUser?.uid)! , complition: {(response) in
            let posts = response as? [Post]
            self.userPosts = posts!
            print("in view did load")
            if (self.userPosts.count == 0) {
                print("inside the if")
                self.nothingLable.isHidden = false
            }
            else {
                self.nothingLable.isHidden = true
            }
           // DispatchQueue.main.async(execute: self.collectionView.reloadData)
            self.collectionView.reloadData()
            
        })
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("count")
        print(userPosts.count)
        return userPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath)
            as! CollectionViewCell
        let post = userPosts[indexPath.row]
        post.getPostImage(imageView: cell.postImage)
        cell.postContent.text = post.content
        cell.postId = post.postId!
        cell.imageName = post.image!
        return cell
    }
    internal override func viewDidAppear(_ animated: Bool) {
        print("in view did appear")
        self.loadData()
   
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)  {
        print("selected")
        //deleteButton.isEnabled = true
//        deleteButton.isHidden = false
       
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"collectionViewCell", for: indexPath) as! CollectionViewCell
        //cell.deleteTap()
        
       //self.collectionView.reloadData()
        cell.postContent.text = ""
        
        
    }
   /* func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        cell.backgroundColor = UIColor.red
        //let desertRef = storageRef.child("desert.jpg")
     
        if ( cell.deleteButt.isHidden) {
            cell.deleteButt.isHidden = false
            cell.deleteButt.isEnabled = true
            Database.database().reference().child("posts").child(cell.postId).removeValue(completionBlock: {(error, ref) in
                print("in 123456789")
                print(ref)
            })
  
            
            
            Storage.storage().reference().child("Images/\(cell.imageName)").delete { error in
                if let error = error {
                    // Uh-oh, an error occurred!
                } else {
                    // File deleted successfully
                }
            }
        }
        else{
            cell.deleteButt.isHidden = true
            cell.deleteButt.isEnabled = false
            
        }
        
        
        
    }*/
    
    
    
    
}
