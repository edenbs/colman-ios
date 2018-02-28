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
import ProgressHUD
import SystemConfiguration
import ReachabilitySwift

class PostViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate,UITextFieldDelegate,NetworkStatusListener {
    
    
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
        if let uid =  AuthUser.isUserConnected()  {
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
        if( contentTextField.text == "Describe Your Scene...")
        {  contentTextField.text = ""}
    }
    
    internal override func viewDidAppear(_ animated: Bool) {
        if (!OfflineHelper.isOnline()) {
            let alertController = UIAlertController(title: "iOScreator", message:
                "YOU ARE NOT CONNECTED TO THE INTERNET!!!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
           
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         ReachabilityManager.shared.addListener(listener: self)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
         ReachabilityManager.shared.removeListener(listener: self)
        self.previewImageView.image = UIImage()
        self.tagsTextField.text = ""
        if(contentTextField.text != "Describe Your Scene...")
        { self.contentTextField.text = ""}
        
    }
    
    
    
    // When connected to internet delete sql posts.
    func networkStatusDidChange(status: Reachability.NetworkStatus) {
        print("in net change!!")
        switch status {
        case .notReachable:
          
            debugPrint("ViewController: Network became unreachable")
            
            let alertController = UIAlertController(title: "iOScreator", message:
                "Hey travler you are not online! you can not post."
                , preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
                self.tabBarController?.selectedIndex = 0
        case .reachableViaWiFi:
            print("this is WIFI ")
           
            
        case .reachableViaWWAN:
            debugPrint("ViewController: Network reachable through Cellular Data")
            
            
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
