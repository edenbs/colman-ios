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
import ProgressHUD
class PostViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate,UITextFieldDelegate {
    @IBOutlet weak var contentTextField: UITextView!
    @IBOutlet weak var tagsTextField: UITextField!

    var imageFileName = ""
    
    var selectedImage: UIImage?
    
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var selectImageButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentTextField.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // User wants to post
    @IBAction func postTapped(_ sender: Any) {
        let PhotoIdString = NSUUID().uuidString
        let uploadRef = Storage.storage().reference().child("Images/\(PhotoIdString).jpg")
        if let uid = Auth.auth().currentUser?.uid {
            if let tags = tagsTextField.text {
                if let content = contentTextField.text {

        if let imageData = UIImageJPEGRepresentation(selectedImage!, 0.1) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            let uploadTask = uploadRef.putData(imageData, metadata:metadata, completion: {
               (metadata,error) in
                if let metadata = metadata{
                    // A link to the photo
                  print(metadata.downloadURL())
                    
                    print("GOOOOOODD")
                   // ProgressHUD.dismiss()
                    ProgressHUD.showSuccess()
                    let postObject: Dictionary<String, Any> = [
                        "uid" : uid,
                        "tags" : tags,
                        "content" : content,
                        "image" : PhotoIdString+".jpg",
                    ]
                     Database.database().reference().child("posts").childByAutoId().setValue(postObject)
                }
                else{
                   print ("BYE")
                    ProgressHUD.showError()
                }
            })
            uploadTask.observe(.progress, handler: { (snapshot) in
                guard let progress = snapshot.progress else {
                    return
                }
                
                let percentage = (Double(progress.completedUnitCount) / Double(progress.totalUnitCount)) * 100
                print(percentage)
                ProgressHUD.show("Uploading", interaction: false)
            })
        }
        else {
            print("error")
        }
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
        print("INNNNN")
        let uuid = randomStringWithLength(length: 10)
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let uploadRef = Storage.storage().reference().child("Images/\(uuid).jpg")
        let uploadTask = uploadRef.putData(imageData!,  metadata: nil) {
            metadata, error in
            if (error == nil) {
                // SUCCESS
                print("Successful!")
                
                self.imageFileName = "\(uuid as String).jpg"
                ProgressHUD.showSuccess("Successfuly uploaded!")
            }
            else {
                // ERROR
                return
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
            
            self.tagsTextField.isEnabled = true
            
            self.selectedImage = pickedImage
            
           // uploadImage(image: pickedImage)
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Will Run after user hits cancel
        picker.dismiss(animated: true, completion: nil)
        
    }
    internal func textViewDidBeginEditing(_ textView: UITextView) {
         print("THIS IS SHIT!!!!!!!!!")
        contentTextField.text = ""
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
