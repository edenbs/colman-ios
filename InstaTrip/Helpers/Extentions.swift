//
//  Extentions.swift
//  InstaTrip
//
//  Created by Dana Tsirulnik on 13/01/2018.
//  Copyright © 2018 Eden Ben Shoshan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
let imageCache = NSCache<AnyObject, AnyObject>()
extension UIImageView{
    func downloadImageToCache(imageName: String, post: Post){
        self.image = nil
        //check if iamge is in cache
         if let cachedImage = imageCache.object(forKey: imageName as AnyObject) as? UIImage{
            self.image  = cachedImage
            return
        }
        let imageRef = Storage.storage().reference().child("Images/\(imageName)")
        imageRef.getData(maxSize: 25 * 1024 * 1024, completion: {(data, err) -> Void in
            if err == nil {
                //GOOD
                if let downloadedImage = UIImage(data: data!){
                    
                  
                        imageCache.setObject(downloadedImage, forKey: imageName as AnyObject)
                        self.image = downloadedImage
                    
              
                 
                    
                    //SqlPostsModel.updatePostImage(image: downloadedImage, uid: uid)
                     //   SqlPostsModel.insertPost(posta: post, image: downloadedImage)
                       
                      
                            
               
                    
                    
                }
                
               
               
                
            }else {
                // error
                print("Error downloading image\(err?.localizedDescription)")
             }
        
        })
    }
    
    
}
