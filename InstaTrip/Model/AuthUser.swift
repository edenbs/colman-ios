//
//  Auth.swift
//  InstaTrip
//
//  Created by Dana Tsirulnik on 27/01/2018.
//  Copyright © 2018 Eden Ben Shoshan. All rights reserved.
//

import Foundation
import FirebaseAuth
class AuthUser{
    
    //TODO:
    
    // returns the current connected user.
    static func isUserConnected() ->  String?{
        //(Auth.auth().currentUser)
        if (Auth.auth().currentUser == nil){
            return nil
        }else{
            return Auth.auth().currentUser?.uid
        }
        
    }
    static func signout(){
        do {
            try Auth.auth().signOut()
            
        } catch{
            print("ERROR SIGNING OUT USER!")
            
        }
    }
    
    static func signin(username: String, password:String,complition: @escaping (Any?,Any?) -> Void )  {
     
        
        
        
        
        Auth.auth().signIn(withEmail: username, password: password) { (user, error) in
          complition(user,error)
        }
        
        
    }
    
}
