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
    let username = Expression<String>("username")
    static let offlinePostsTable = Table("offlinePostsTable")
    
    func insert(post: Post, database: Connection, username: String){
        
        //self.deleteFromSql(database: database)
        let insertPost = PostOffline.offlinePostsTable.insert(self.uid <- post.uid!,
                                                              self.content <- post.content!,
                                                              self.tags <- post.tags!,
                                                              self.image <- post.image!,
                                                              self.postId <- post.postId!,
                                                              self.username <- username)
        
        do {
            try database.run(insertPost)
            
        }catch{
            print("did not insert \(error)")
        }
        
    }
    
     func createTable(database: Connection){
        
        let createTable = PostOffline.offlinePostsTable.create(ifNotExists: true)  { (table) in
            table.column(uid)
            table.column(image)
            table.column(tags)
            table.column(content)
            table.column(postId, unique: true)
            table.column(username)
            table.column(id, primaryKey: true)
        }
        do {
            try database.run(createTable)
            
            
        }catch {
            print("Error: \(error)")
        }
    }
    
    func listPosts(database: Connection) -> [Post]{
        
        var tempPost = Post()
        var tempPostArr = [Post]()
        var a = 0
        do {
            for post in  try database.prepare(PostOffline.offlinePostsTable) {
                a = a+1
            }
        }catch{
            print("this is the error in list:\(error)")
        }
        
        
        
        
        do {
            
           
            let postsList = try database.prepare(PostOffline.offlinePostsTable)

            for post in postsList {
                tempPost = Post()
                tempPost.content = post[self.content]
                tempPost.image = post[self.image]
                tempPost.tags = post[self.tags]
                tempPost.uid = post[self.content]
                tempPost.username = post[self.username]
                tempPostArr.append(tempPost)
                
            }
         
            return tempPostArr
        } catch {
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
                print("Error in update: \(error)")
            }
            
            
        }
        
    }
    
    func deleteFromSql(database: Connection){
        do{
            try  database.run("DROP TABLE offlinePostsTable")
        }catch{
            print(error)
        }
       
    }
    func deletePost(database: Connection, postId: String){
        do{
            try database.run(
                "DELETE FROM  offlinePostsTable WHERE  (postId = \"\(postId)\")")
           
        }catch{
            print("Error in delete: \(error)")
        }
        
    }
}
