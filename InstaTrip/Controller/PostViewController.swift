//
//  PostViewController.swift
//  InstaTrip
//
//  Created by Eden Ben Shoshan on 12/27/17.
//  Copyright © 2017 Eden Ben Shoshan. All rights reserved.
//


// TODO : check if user did not pick an image - if he didnt pick do not let him post!!!! BAD!!
// TODO: add a message that says that upload is done, if done user needs to say ok. only then go to the next page.
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import ProgressHUD
import SystemConfiguration
import SQLite
import ReachabilitySwift

class PostViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate,UITextFieldDelegate {
    
    
    @IBOutlet weak var contentTextField: UITextView!
    @IBOutlet weak var tagsTextField: UITextField!
    
    
    var imageFileName = ""
    
    var selectedImage: UIImage?
    
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var selectImageButton: UIButton!
    var database: Connection!
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
       /* do {
            let documentDirectory = try  FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true )
            let fileUrl = documentDirectory.appendingPathComponent("posts").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
            // createTable()
        } catch {
            print (error)
        }*/
        
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
        if let uid =  Auth.auth().currentUser?.uid {
            if let tags = tagsTextField.text {
                if let content = contentTextField.text {
                    
                    let post = Post()
                    post.uid = uid
                    post.tags = tags
                    post.content = content
                    post.image = PhotoIdString+".jpg"
                    
                    post.insertNewPost(image: selectedImage!, complition: {
                        ProgressHUD.showSuccess("Uploaded successfully", interaction: true)
                        self.tabBarController?.selectedIndex = 0
                    })
                 
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
    
    
    
    //TODO:
    // Change to UUID!!!!! LIKE THIS:
    // let a = NSUUID().uuidString
   /* func randomStringWithLength(length: Int) -> NSString{
        // Casting to NSstring
        let chars : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString : NSMutableString = NSMutableString(capacity: length)
        
        for i in 0..<length {
            var len = UInt32(chars.length)
            
            var rand = arc4random_uniform(len)
            
            randomString.appendFormat("%C", chars.character(at: Int(rand)))
        }
        
        return randomString
    }*/
    
    // The image picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Run after user picks pic
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.previewImageView.image = pickedImage
            
            // Hides the Button after the user pickes an image. consider removing, what is the user wants to change?!
          // self.selectImageButton.isEnabled = false
            
            // Hides the Button after the user pickes an image. consider removing, what is the user wants to change?!
           // self.selectImageButton.isHidden = true
            
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
        if( contentTextField.text == "Describe Your Scene...")
      {  contentTextField.text = ""}
    }
    
   
    
    
    internal override func viewDidAppear(_ animated: Bool) {
        if (OfflineHelper.isOnline() == false) {
            let alertController = UIAlertController(title: "iOScreator", message:
                "YOU ARE NOT CONNECTED TO THE INTERNET!!!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
   
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.previewImageView.image = UIImage()
        self.tagsTextField.text = ""
        if(contentTextField.text != "Describe Your Scene...")
       { self.contentTextField.text = ""}
        
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
