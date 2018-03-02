//
//  FirstViewController.swift
//  InstaTrip
//
//  Created by Eden Ben Shoshan on 12/24/17.
//  Copyright © 2017 Eden Ben Shoshan. All rights reserved.
//

import UIKit



class FirstViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        view.addGestureRecognizer(tap)
        //Check if user is already signed in.
        if AuthUser.isUserConnected() != nil {
            // user is loggedin
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC")
            self.present(vc!, animated: false, completion:nil )
            
        }
        super.viewDidAppear(animated)
        
        // Show keyboard by default
        
        if (!OfflineHelper.isOnline()) {
            let alertController = UIAlertController(title: "iOScreator", message:
                "YOU ARE NOT CONNECTED TO THE INTERNET!!!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
        }

    }

    @IBAction func signInTapped(_ sender: Any) {
        let username = usernameTextField.text
        let password = passwordTextField.text
        
        AuthUser.signin(username: username!, password: password!, complition: { (user, error) in
            if (error != nil) {
                // error logging in user
                let alert = UIAlertController(title: "Error", message: "Incorrect password/username", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                // success
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC")
                self.tabBarController?.selectedIndex = 0
                self.present(vc!, animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func backFromRegister(unwindSegue: UIStoryboardSegue) {
        // Rewind from register screen
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
  
    

    
}

