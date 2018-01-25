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
    
  
   static var database: Connection?
    
    
    
    static func connectDB(){
        
        do {
            let documentDirectory = try  FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true )
            let fileUrl = documentDirectory.appendingPathComponent("offlinePostsTable").appendingPathExtension("sqlite3")
             database = try Connection(fileUrl.path)
          
            PostOffline().createTable(database: database!)
        } catch {
            print (error)
        }
        
        /*do{
            
            try database?.run("DROP TABLE offlinePostsTable")
             print("this is  working. 1")
            
        } catch {
            print("this is not working. 1")
        }*/
   
        
    }
    
    
    
    
   
  
   
    
}
