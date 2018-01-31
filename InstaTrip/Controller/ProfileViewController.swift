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
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var usernameLable: UILabel!
    var userPosts = [Post]()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        FirebaseModel.getPostByUserID(uid: "56NrGlEqKKPTIa0Gklr6CVF2bT72", complition: {(response) in
            let posts = response as? [Post]
            self.userPosts = posts!
            print("in view did load")
            DispatchQueue.main.async(execute: self.collectionView.reloadData)
        })
        if Auth.auth().currentUser == nil {
            // user is loggedin
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
            self.present(vc!, animated: false, completion:nil )
            
        }
        else{
            self.usernameLable.text = Auth.auth().currentUser?.email
            
        }
        
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
        return cell
    }
    
    
    
}
