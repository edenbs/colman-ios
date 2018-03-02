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
import ReachabilitySwift

class PostViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate,UITextFieldDelegate,NetworkStatusListener {
    
    
    @IBOutlet weak var contentTextField: UITextView!
    @IBOutlet weak var tagsTextField: UITextField!
    
    
    var imageFileName = ""
    var isImgSelected: Bool? = false
    var isContent: Bool? = false
    var selectedImage: UIImage?
    
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var selectImageButton: UIButton!
   
    @IBOutlet weak var postButton: UIButton!
    
    
    override func viewDidLoad() {
        self.postButton.isEnabled = false
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        
        view.addGestureRecognizer(tap)
        
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
           
            self.tagsTextField.isEnabled = true
           // self.postButton.isEnabled = true
            self.isImgSelected = true
            self.selectedImage = pickedImage
            
            // uploadImage(image: pickedImage)
            picker.dismiss(animated: true, completion: nil)
            validateForm()
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
    internal func textViewDidEndEditing(_ textView: UITextView) {
        if(contentTextField.text.trimmingCharacters(in: .whitespacesAndNewlines) != ""){
            self.isContent = true
        }else{
            self.isContent = false
        }
        validateForm()
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
        { self.contentTextField.text = "Describe Your Scene..."}
        self.postButton.isEnabled = false
    }
    
    
    
    // When connected to internet delete sql posts.
    func networkStatusDidChange(status: Reachability.NetworkStatus) {
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
            debugPrint("this is WIFI ")
        case .reachableViaWWAN:
            debugPrint("ViewController: Network reachable through Cellular Data")
            
            
        }
        
    }
  
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    internal func validateForm(){
        if(isContent! && isImgSelected!){
            self.postButton.isEnabled = true
        }else{
            self.postButton.isEnabled = false
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
