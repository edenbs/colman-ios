//
//  SqlPostsModel.swift
//  InstaTrip
//
//  Created by Dana Tsirulnik on 24/01/2018.
//  Copyright © 2018 Eden Ben Shoshan. All rights reserved.
//

import Foundation
import SQLite
import ReachabilitySwift

class SqlPostsModel{
    
    static var database: Connection!
    static  let offlinePostsTable = Table("offlinePostsTable")
    static  var posts = [Post]()
    static let uid = Expression<String>("uid")
    static   let tags = Expression<String>("tags")
    static let content = Expression<String>("content")
    static  let imageData = Expression<String>("imageData")
    static  let id = Expression<Int>("id")
    
    static func connectDB(){
        do {
            let documentDirectory = try  FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true )
            let fileUrl = documentDirectory.appendingPathComponent("offlinePostsTable").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
            // createTable()
        } catch {
            print (error)
        }
    }
    static func createTable(){
        posts.removeAll()
        
        
        
        let createTable = offlinePostsTable.create(ifNotExists: true)  { (table) in
            table.column(uid, unique: true)
            table.column(imageData)
            table.column(tags)
            table.column(content)
            table.column(id, primaryKey: true)
        }
        do {
            try self.database.run(createTable)
            print("Successfull!")
           
            
        }catch {
            print("Error!!!: \(error)")
        }
    }
    
    static func delAll(){
     /* do{
            try database.run("DELETE FROM posts")
            
            
        }catch{
            print("THIS IS SHIIIIIT")
        }*/
    }
    
    static func insertPost(){
       
        //post: Post
        FirebaseModel.getPosts{ (response) in
            print("in get Posts...")
            
            guard  let postsA = response as? [Post] else {return}
            print("after guard")
            //  print("This is the users list and response\(usersList) \(response)")
            posts = postsA
            print("real original posts \(posts.count)")
            var count = 0
            print("those are the posts : \(posts)")
            print( "THIS IS THE AMOUNT \(listPosts().count)")
            do{
                try database.run("DELETE FROM offlinePostsTable")
                
                
            }catch{
                print("THIS IS SHIIIIIT")
            }
            for post in posts {
                count = count+1
                print("infor \(post.content)")
              
                let insertPost = offlinePostsTable.insert(self.uid <- post.uid!, self.content <- post.content!, self.tags <- post.tags!, self.imageData <- post.image!)
                do {
                    
                    try self.database.run(insertPost)
                  
                    print("inserted successfully")
                }catch{
                    print("did not insert")
                }
            }
            print ("amount is \(count)" )
            if ( count > 0){
                //listPosts()
            }
            
        }

        
        /* */
    }
    static func listPosts() -> [Post]{
        print("in listposts")
        
        var tempPost = Post()
        var tempPostArr = [Post]()
        var a = 0
        do {
        for post in  try database.prepare(offlinePostsTable) {
            a = a+1
            print("id: \(post)")
            // id: 1, name: Optional("Alice"), email: alice@mac.com
        }
        }catch{
            
        }
        print("THIS IS A MESS \(a)")
        
        
        
        do {
            
            print("in  DO listposts")
            let postsList = try database.prepare(self.offlinePostsTable)
            
            print("in LET listposts\(postsList)")
            for post in postsList {
                 tempPost = Post()
                print("in FOR listposts")
                tempPost.content = post[self.content]
                tempPost.image = post[self.imageData]
                tempPost.tags = post[self.tags]
                tempPost.uid = post[self.content]
                tempPostArr.append(tempPost)
                print("post UID: \(post[self.content])")
            }
            for post in tempPostArr {
                print("in the sql")
               print(post.content)
            }
            return tempPostArr
        } catch {
            print("ERRRRORRR")
            return [Post]()
        }
        
        
        
    }
}
