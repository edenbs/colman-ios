//
//  Post.swift
//  InstaTrip
//
//  Created by Dana Tsirulnik on 13/01/2018.
//  Copyright © 2018 Eden Ben Shoshan. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import ProgressHUD

let imageCache = NSCache<AnyObject, AnyObject>()

//Added to listen to child changes of posts..
let postAddedNotification = "com.instatrip.postAddedNotification"

class Post: NSObject {
    var content: String?
    var image: String?
    var tags: String?
    var uid: String?
    var postId: String?
    var username: String?
    
    private func getPostImageOnline(imageView: UIImageView){
        imageView.image = nil
        
        //check if iamge is in cache
        if let cachedImage = imageCache.object(forKey: self.image as AnyObject) as? UIImage{
            imageView.image  = cachedImage
            return
        }
        
        let imageRef = Storage.storage().reference().child("Images/\(self.image!)")
        imageRef.getData(maxSize: 25 * 1024 * 1024, completion: {(data, err) -> Void in
            if err == nil {
                if let downloadedImage = UIImage(data: data!){
                    imageCache.setObject(downloadedImage, forKey: self.image as AnyObject)
                    imageView.image = downloadedImage
                    PostOffline().updatePostImage(image: downloadedImage, database: SqlPostsModel.database!,
                                                  postId: self.postId!, completion: {})
                }
            }
        })
    }
    
    private func getPostImageOffline(imageView: UIImageView){
        if let cachedImage = imageCache.object(forKey: self.image as AnyObject) as? UIImage{
            imageView.image  = cachedImage
            
            return
        }
        
        let dataDecoded : Data = Data(base64Encoded: self.image!, options: .ignoreUnknownCharacters)!
        let decodedimage = UIImage(data: dataDecoded)
        
        imageCache.setObject(decodedimage!, forKey: self.image as AnyObject)
        imageView.image = decodedimage
    }
    
    // Main get post func.
    func getPostImage(imageView: UIImageView){
        
        // get posts online
        if (OfflineHelper.isOnline()){
            getPostImageOnline(imageView: imageView)
        }
            
        // get posts offline
        else{
            getPostImageOffline(imageView: imageView)
        }
    }
    
    static func notify() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: postAddedNotification), object: self)
    }
    
    public static func listenToChange(){
        var refHandle =  Database.database().reference().child("posts").observe(DataEventType.value, with: { (snapshot) in
            DispatchQueue.global(qos: .background).async {
                notify()
            }
        })
    }
    
    func insertNewPost( image: UIImage ,complition: @escaping () -> Void ){
        let PhotoIdString = NSUUID().uuidString
        let uploadRef = Storage.storage().reference().child("Images/\(PhotoIdString).jpg")
        if let imageData = UIImageJPEGRepresentation(image, 0.1) {
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            let uploadTask = uploadRef.putData(imageData, metadata:metadata, completion: {
                (metadata,error) in
                if let metadata = metadata{
                    let postObject: Dictionary<String, Any> = [
                        "uid" : self.uid,
                        "tags" : self.tags,
                        "content" : self.content,
                        "image" : PhotoIdString+".jpg",
                        ]
                    Database.database().reference().child("posts").childByAutoId().setValue(postObject)
                    
                    complition()
                }
                else{
                    ProgressHUD.showError()
                }
            })
            uploadTask.observe(.progress, handler: { (snapshot) in
                guard let progress = snapshot.progress else {
                    return
                }
                
                let percentage = (Double(progress.completedUnitCount) / Double(progress.totalUnitCount)) * 100
                ProgressHUD.show("Uploading", interaction: false)
            })
        }
    }

    static func getPostByUserID(uid: String, complition: @escaping (Any?) -> Void ){
        var posts = [Post]()
        do {
            Database.database().reference().child("posts").queryOrdered(byChild: "uid").queryEqual(toValue: uid).observeSingleEvent(of: .value, with:{(snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    for post in dictionary{
                        var tempPost = Post()
                        tempPost.content = post.value["content"] as? String
                        tempPost.image =  post.value["image"] as? String
                        tempPost.tags =  post.value["tags"] as? String
                        tempPost.uid =  post.value["uid"] as? String
                        tempPost.postId = post.key
                        
                        posts.append(tempPost)
                    }
                    
                    complition(posts)
                }
            })
        } catch {
            complition(nil)
        }
    }
    
    private static func getPostsWhenOffline()-> [Post]{
        return PostOffline().listPosts(database: SqlPostsModel.database!)
    }
    
    private static func getPostsWhenOnline(users: [User],complition: @escaping (Any?) -> Void ){
        var posts = [Post]()
        var username: String = ""
        do {
            
            Database.database().reference().child("posts").observeSingleEvent(of: .value, with:{(snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    for post in dictionary{
                        var tempPost = Post()
                        tempPost.content = post.value["content"] as? String
                        tempPost.image =  post.value["image"] as? String
                        tempPost.tags =  post.value["tags"] as? String
                        tempPost.uid =  post.value["uid"] as? String
                        tempPost.postId = post.key
                        
                        posts.append(tempPost)
                        
                        if let i = users.index(where: { $0.uid == tempPost.uid! }) {
                            username = users[i].username!
                        }
                        else{
                            username = "Error"
                        }
                        
                        PostOffline().insert(post: tempPost, database: SqlPostsModel.database!, username: username)
                    }
                    
                    complition(posts)
                }
            })
        } catch {
            complition(nil)
        }
    }
    
    static func getPosts(users:[User] ,complition: @escaping (Any?) -> Void ){
        if (OfflineHelper.isOnline()){
            getPostsWhenOnline(users: users, complition: complition)
        }
        else{
            complition(getPostsWhenOffline())
        }
    }
    
    static func deletePost(postId: String,imageName: String,complition: @escaping () -> Void ){
        Database.database().reference().child("posts").child(postId).removeValue(completionBlock: {(error, ref) in
            complition()
        })

        Storage.storage().reference().child("Images/\(imageName)").delete { error in
            if let error = error {
                // Uh-oh, an error occurred!
            } else {
                // File deleted successfully
            }
        }
        
        PostOffline().deletePost(database: SqlPostsModel.database!, postId: postId)
    }
}

