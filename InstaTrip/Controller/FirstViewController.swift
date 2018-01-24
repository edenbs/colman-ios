//
//  FirstViewController.swift
//  InstaTrip
//
//  Created by Eden Ben Shoshan on 12/24/17.
//  Copyright © 2017 Eden Ben Shoshan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class FirstViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        FirebaseModel.getUsers { (response) in
            
        
         
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        //Check if user is already signed in.
        if Auth.auth().currentUser != nil {
            // user is loggedin
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC")
            self.present(vc!, animated: false, completion:nil )
            
        }
        super.viewDidAppear(animated)
        
        // Show keyboard by default
        
        
    }

    @IBAction func signInTapped(_ sender: Any) {
        let username = usernameTextField.text
        let password = passwordTextField.text
        Auth.auth().signIn(withEmail: username!, password: password!) { (user, error) in
            if (error != nil) {
                // error logging in user
                let alert = UIAlertController(title: "Error", message: "Incorrect password/username", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                // success
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC")
                self.present(vc!, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func backFromRegister(unwindSegue: UIStoryboardSegue) {
        // Rewind from register screen
    }
    
}

