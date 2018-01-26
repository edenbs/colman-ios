//
//  PostOffline.swift
//  InstaTrip
//
//  Created by Dana Tsirulnik on 25/01/2018.
//  Copyright © 2018 Eden Ben Shoshan. All rights reserved.
//

import Foundation
import SQLite
class PostOffline {
    
    let uid = Expression<String>("uid")
    let postId = Expression<String>("postId")
    let tags = Expression<String>("tags")
    let content = Expression<String>("content")
    let image = Expression<String>("image")
    let id = Expression<Int>("id")
    static let offlinePostsTable = Table("offlinePostsTable")
    
    func insert(post: Post, database: Connection){
        let insertPost = PostOffline.offlinePostsTable.insert(self.uid <- post.uid!,
                                                              self.content <- post.content!,
                                                              self.tags <- post.tags!,
                                                              self.image <- post.image!,
                                                              self.postId <- post.postId!)
        do {
            
            try database.run(insertPost)
            print("inserted successfully")
        }catch{
            print("did not insert \(error)")
        }
        
        print ("amount is \(count)" )
    }
     func createTable(database: Connection){
        let createTable = PostOffline.offlinePostsTable.create(ifNotExists: true)  { (table) in
            table.column(uid)
            table.column(image)
            table.column(tags)
            table.column(content)
            table.column(postId, unique: true)
            table.column(id, primaryKey: true)
        }
        do {
            try database.run(createTable)
            print("Successfull!")
            
            
        }catch {
            print("Error!!!: \(error)")
        }
    }
    
    func listPosts(database: Connection) -> [Post]{
        print("in listposts")
        
        var tempPost = Post()
        var tempPostArr = [Post]()
        var a = 0
        do {
            for post in  try database.prepare(PostOffline.offlinePostsTable) {
                a = a+1
                // print("id: \(post)")
                // id: 1, name: Optional("Alice"), email: alice@mac.com
            }
        }catch{
            print("this is the error in list:\(error)")
        }
        
        
        
        
        do {
            
           
            let postsList = try database.prepare(PostOffline.offlinePostsTable)

            for post in postsList {
                tempPost = Post()
                print("in FOR listposts")
                tempPost.content = post[self.content]
                tempPost.image = post[self.image]
                tempPost.tags = post[self.tags]
                tempPost.uid = post[self.content]
                tempPostArr.append(tempPost)
                
            }
         
            return tempPostArr
        } catch {
            print("ERRRRORRR")
            return [Post]()
        }

    }
    
    func updatePostImage(image: UIImage, database: Connection, postId: String, completion: @escaping() -> Void ){
        DispatchQueue.global(qos: .background).async {
            var img = String()
            let imageData:NSData = UIImagePNGRepresentation(image)! as NSData
            img = imageData.base64EncodedString(options: .lineLength64Characters)
            
            
            let post = PostOffline.offlinePostsTable.filter(self.postId == postId)
            
            
            let updatePost = post.update(self.image <- img)
            
            
            do{
                try database.run(
                    "UPDATE offlinePostsTable SET image = \"\(img)\" WHERE (postId = \"\(postId)\")")
                completion()
            }catch{
                print(error)
            }
            
            
        }
        
    }
}