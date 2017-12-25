//
//  RegisterViewController.swift
//  InstaTrip
//
//  Created by Eden Ben Shoshan on 12/25/17.
//  Copyright © 2017 Eden Ben Shoshan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class RegisterViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func createAccountTapped(_ sender: Any) {
        let username = usernameTextField.text
        let password = passwordTextField.text
        
        Auth.auth().createUser(withEmail: username!, password: password!) { (user, err) in
            if (err != nil) {
                // Error creating account
                let errorMsg = err?.localizedDescription
                let alert = UIAlertController(title: "Error", message: errorMsg, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertController(title: "Success", message: "Account Created!!", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
