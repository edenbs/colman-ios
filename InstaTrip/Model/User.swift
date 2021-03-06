//
//  User.swift
//  InstaTrip
//
//  Created by Dana Tsirulnik on 13/01/2018.
//  Copyright © 2018 Eden Ben Shoshan. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
class User: NSObject {
    var username: String?
    var email: String?
    var uid: String?

 static func getUsers(complition: @escaping (Any?) -> Void ){
    var users = [User]()
    do {
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let usersDictionary = snapshot.value as? [String: AnyObject]{

                for user in usersDictionary{
                    var tempUser  = User()
                    tempUser.email = user.value["email"] as? String
                    tempUser.username = user.value["username"] as? String
                    tempUser.uid = user.key
                    users.append(tempUser)

                }
                
                complition(users)
            }
        })
    } catch {
        complition(nil)
    }
}


}


