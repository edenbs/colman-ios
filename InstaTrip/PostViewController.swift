//
//  PostViewController.swift
//  InstaTrip
//
//  Created by Eden Ben Shoshan on 12/27/17.
//  Copyright © 2017 Eden Ben Shoshan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class PostViewController: UIViewController {
    @IBOutlet weak var contentTextField: UITextView!
    @IBOutlet weak var tagsTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func postTapped(_ sender: Any) {
        if let uid = Auth.auth().currentUser?.uid {
            if let tags = tagsTextField.text {
                if let content = contentTextField.text {
                    let postObject: Dictionary<String, Any> = [
                            "uid" : uid,
                            "tags" : tags,
                            "content" : content
                    ]
                    
                    // setValue deprecated?
                    Database.database().reference().child("posts").childByAutoId().setValue(postObject)
                    
                    print("Posted to Database")
                    
                }

                
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
