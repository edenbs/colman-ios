//
//  FirebaseModel.swift
//  InstaTrip
//
//  Created by Dana Tsirulnik on 24/01/2018.
//  Copyright © 2018 Eden Ben Shoshan. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
class FirebaseModel
{
    
    var usersListUp = User()
    
   
    
    static func getUsers(complition: @escaping (Any?) -> Void ){
        var users = [String:AnyObject]()
        print("in get Users")
        do {
            Database.database().reference().child("users").observeSingleEvent(of: .value, with: {(snapshot) in
                print("in users?")
                
                if let usersDictionary = snapshot.value as? [String: AnyObject]{
                    var usersList = [String]()
                    
                    for user in usersDictionary{
                        
                        users[user.key] = user.value
                        print(user.value["username"])
                        
                        
                    }
                    
                    complition(users)
                }
            })
        } catch {
            print("error")
            complition(nil)
        }
    }
    
    
    
    private static func getPostsWhenOffline()-> [Post]{
        return PostOffline().listPosts(database: SqlPostsModel.database!)
        
    }
    
    private static func getPostsWhenOnline(complition: @escaping (Any?) -> Void ){
        var posts = [Post]()
        print("in get Users")
        do {
            Database.database().reference().child("posts").observeSingleEvent(of: .value, with:{(snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    
                    
                    for post in dictionary{
                        var tempPost = Post()
                        
                        print("this is total shit \(post.value["content"])")
                        // post.setValuesForKeys(posta)
                        //  users[user.key] = user.value
                        // print(user.value["username"])
                        tempPost.content = post.value["content"] as? String
                        tempPost.image =  post.value["image"] as? String
                        tempPost.tags =  post.value["tags"] as? String
                        tempPost.uid =  post.value["uid"] as? String
                        tempPost.postId = post.key
                        //                        tempPost.postId = post.key
                        posts.append(tempPost)
                        PostOffline().insert(post: tempPost, database: SqlPostsModel.database!)
                       // SqlPostsModel.insertPost(posta: tempPost)
                        
                        
                        
                    }
                    print("after insert  \( PostOffline().listPosts(database: SqlPostsModel.database!).count)")
                    complition(posts)
                    //   post.setValuesForKeys(dictionary)
                    
                    //
                    
                }
                
                
            })
        } catch {
            print("error")
            complition(nil)
        }
    }
    
    
    static func getPosts(complition: @escaping (Any?) -> Void ){
        if (OfflineHelper.isOnline()){
            getPostsWhenOnline(complition: complition)
        }
        else{
            complition(getPostsWhenOffline())
        }
    }
    
    
    
}
