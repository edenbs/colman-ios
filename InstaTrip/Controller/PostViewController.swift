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
import FirebaseStorage

class PostViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var contentTextField: UITextView!
    @IBOutlet weak var tagsTextField: UITextField!
    
    var imageFileName = ""
    
    var selectedImage: UIImage?
    
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var selectImageButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // User wants to post
    @IBAction func postTapped(_ sender: Any) {
        ProgressHUUD.show("Waiting", interaction: flase)
        if let uid = Auth.auth().currentUser?.uid {
            if let tags = tagsTextField.text {
                if let content = contentTextField.text {
                    let postObject: Dictionary<String, Any> = [
                            "uid" : uid,
                            "tags" : tags,
                            "content" : content,
                            "image" : imageFileName
                    ]
                    
                    // setValue deprecated?
                    Database.database().reference().child("posts").childByAutoId().setValue(postObject)
                    
                    print("Posted to Database")
                    
                }
            }
        }
    }
    
    
    // User clicked upload image.
    @IBAction func selectImageTapped(_ sender: Any) {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    
    // Upload the image to firebase
    func uploadImage(image: UIImage) {
        let uuid = randomStringWithLength(length: 10)
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let uploadRef = Storage.storage().reference().child("Images/\(uuid).jpg")
        let uploadTask = uploadRef.putData(imageData!,  metadata: nil) {
            metadata, error in
            if (error == nil) {
                // SUCCESS
                print("Successful!")
                
                self.imageFileName = "\(uuid as String).jpg"
            }
            else {
                // ERROR
                print("Error \(error?.localizedDescription)")
            }
        }
        
    }
    
    // Change to UUID!!!!! LIKE THIS:
    // let a = NSUUID().uuidString
    func randomStringWithLength(length: Int) -> NSString{
        // Casting to NSstring
        let chars : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString : NSMutableString = NSMutableString(capacity: length)
        
        for i in 0..<length {
            var len = UInt32(chars.length)
            
            var rand = arc4random_uniform(len)
            
            randomString.appendFormat("%C", chars.character(at: Int(rand)))
        }
        
        return randomString
    }
    
    // The image picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Run after user picks pic
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.previewImageView.image = pickedImage
            
            // Hides the Button after the user pickes an image. consider removing, what is the user wants to change?!
            self.selectImageButton.isEnabled = false
            
            // Hides the Button after the user pickes an image. consider removing, what is the user wants to change?!
            self.selectImageButton.isHidden = true
            
            selectedImage = pickedImage
            
            uploadImage(image: pickedImage)
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Will Run after user hits cancel
        picker.dismiss(animated: true, completion: nil)
        
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
