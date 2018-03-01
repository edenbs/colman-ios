//
//  RegisterViewController.swift
//  InstaTrip
//
//  Created by Eden Ben Shoshan on 12/25/17.
//  Copyright © 2017 Eden Ben Shoshan. All rights reserved.
//

import UIKit


class RegisterViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")

        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func createAccountTapped(_ sender: Any) {
        let email = emailTextField.text
        let password = passwordTextField.text
        let username = usernameTextField.text
        
        AuthUser.createUser(email: email!, password: password!) { (user, err) in
            if (err != nil) {
                // Error creating account
                let alert = UIAlertController(title: "Error", message: err?.localizedDescription, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                if let uid = AuthUser.isUserConnected(){
                    AuthUser.setUserName(username: username!, uid: uid)
                   // let userRef = Database.database().reference().child("users").child(uid)
                   // let object = ["username": username]
                   // userRef.setValue(object)
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC")
                    self.present(vc!, animated: true, completion: nil)
                }
                else{
                    print("THIS IS NOT WORKING!!!!!")
                }
                
                
            }
        
        }
        
    }
    

    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
      
        view.endEditing(true)
    }

}
