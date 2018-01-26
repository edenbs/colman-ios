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
 let postAddedNotification = "com.instatrip.postAddedNotification"
class Post: NSObject {
    var content: String?
    var image: String?
    var tags: String?
    var uid: String?
    var postId: String?
   
   private func getPostImageOnline(imageView: UIImageView){
    imageView.image = nil
    //check if iamge is in cache
    if let cachedImage = imageCache.object(forKey: self.image as AnyObject) as? UIImage{
        imageView.image  = cachedImage
        return
    }
    let imageRef = Storage.storage().reference().child("Images/\(self.image!)")
    print("this is the name:\(self.image!)")
    print("this is the ref:\(imageRef)")
    
    imageRef.getData(maxSize: 25 * 1024 * 1024, completion: {(data, err) -> Void in
        if err == nil {
            //GOOD
            if let downloadedImage = UIImage(data: data!){
                
                
                imageCache.setObject(downloadedImage, forKey: self.image as AnyObject)
                imageView.image = downloadedImage
                PostOffline().updatePostImage(image: downloadedImage, database: SqlPostsModel.database!,
                                                postId: self.postId!, completion: {})
               // SqlPostsModel.updatePostImage(image: downloadedImage, postId: self.postId!, completion: {})
                
            }
        }
    })
    }
    
    private func getPostImageOffline(imageView: UIImageView){
        if let cachedImage = imageCache.object(forKey: self.image as AnyObject) as? UIImage{
            imageView.image  = cachedImage
            return
        }
        print("this is self\(self)")
        let dataDecoded : Data = Data(base64Encoded: self.image!, options: .ignoreUnknownCharacters)!
        let decodedimage = UIImage(data: dataDecoded)
        imageCache.setObject(decodedimage!, forKey: self.image as AnyObject)
         imageView.image = decodedimage
    }
    func getPostImage(imageView: UIImageView){
       
        print("in post image")
        if (OfflineHelper.isOnline()){
            getPostImageOnline(imageView: imageView)
        }
        else{
            getPostImageOffline(imageView: imageView)
        }
    }
    static func notify() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: postAddedNotification), object: self)
    }
    
    public static func listenToChange(){
        var refHandle =  Database.database().reference().child("posts").observe(DataEventType.value, with: { (snapshot) in
            //let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            print("inside the thing \(snapshot)")
            DispatchQueue.global(qos: .background).async {
               notify()
            }
        })
    }
}

