//
//  ProfileViewController.swift
//  InstaTrip
//
//  Created by Dana Tsirulnik on 26/01/2018.
//  Copyright © 2018 Eden Ben Shoshan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
class ProfileViewController: UIViewController {
    @IBOutlet weak var usernameLable: UILabel!
    override func viewDidLoad() {
    
     super.viewDidLoad()
    print("in view did load")
    if Auth.auth().currentUser == nil {
        // user is loggedin
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
        self.present(vc!, animated: false, completion:nil )
        
    }
    else{
        usernameLable.text = Auth.auth().currentUser?.email
        print("\(Auth.auth().currentUser?.email)")
    }
}
}
