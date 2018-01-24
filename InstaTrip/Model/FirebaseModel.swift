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
    
    static func getPosts(complition: @escaping (Any?) -> Void ){
        var posts = [Post]()
        print("in get Users")
        do {
            Database.database().reference().child("posts").observeSingleEvent(of: .value, with:{(snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    var tempPost = Post()
                    
                    for post in dictionary{
                        
                        print("this is total shit \(post.value["content"])")
                        // post.setValuesForKeys(posta)
                        //  users[user.key] = user.value
                        // print(user.value["username"])
                        tempPost.content = post.value["content"] as? String
                        
                        tempPost.image =  post.value["image"] as? String
                        tempPost.tags =  post.value["tags"] as? String
                        tempPost.uid =  post.value["uid"] as? String
                        posts.append(tempPost)
                        tempPost = Post()
                    }
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
    
    
    
}
