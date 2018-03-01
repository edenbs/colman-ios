//
//  ProfileViewController.swift
//  InstaTrip
//
//  Created by Dana Tsirulnik on 26/01/2018.
//  Copyright © 2018 Eden Ben Shoshan. All rights reserved.
//

import UIKit
import ReachabilitySwift
class ProfileViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,NetworkStatusListener {
  
    
    
    //TODO: add a alert that you are not connected to the internet. like posts page.
    //  @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var nothingLable: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    // @IBOutlet weak var usernameLable: UILabel!
    var userPosts = [Post]()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        //TODO do not use fire base here move to user
        if AuthUser.isUserConnected() == nil {
            // user is loggedin
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
            self.present(vc!, animated: false, completion:nil )
            
        }

        
        
        
        
    }
    func loadData(){
        if(OfflineHelper.isOnline() == true)
        {
            Post.getPostByUserID(uid: (AuthUser.isUserConnected())! , complition: {(response) in
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
                
                self.collectionView.reloadData()
                
            }
            )}
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
        if(OfflineHelper.isOnline() == true)
        {
            post.getPostImage(imageView: cell.postImage)
            
        }
        cell.postContent.text = post.content
        cell.postId = post.postId!
        cell.imageName = post.image!
        cell.deleteButt.layer.setValue(indexPath, forKey: "index")
        if (self.userPosts.count == 0) {
            print("inside the if")
            self.nothingLable.isHidden = false
        }
        else {
            self.nothingLable.isHidden = true
        }
        
        return cell
    }
    internal override func viewDidAppear(_ animated: Bool) {
        print("in view did appear")
        self.loadData()
        
    }

    
    
    @IBAction func tap(_ sender: Any) {
        let refreshAlert = UIAlertController(title: "Delete this?!", message: "post will be lost.", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            let sendButton = sender as! UIButton
            let indexPath = sendButton.layer.value(forKey: "index") as! IndexPath
            let cell = self.collectionView.cellForItem(at: indexPath) as! CollectionViewCell
            Post.deletePost(postId: cell.postId, imageName: cell.imageName, complition: {})
            self.userPosts.remove(at: indexPath.row)
            self.collectionView.reloadData()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
        
        
        
        
    }

    func networkStatusDidChange(status: Reachability.NetworkStatus) {
        print("in net change!!")
        switch status {
        case .notReachable:
            
            debugPrint("ViewController: Network became unreachable")
            
            let alertController = UIAlertController(title: "iOScreator", message:
                "Hey travler you are not online! ."
                , preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
            self.tabBarController?.selectedIndex = 0
        case .reachableViaWiFi:
            print("this is WIFI ")
            
            
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
    

    
    
}
