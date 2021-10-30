//
//  ProfileViewController.swift
//  Parstagram
//
//  Created by Matthew Piedra on 10/29/21.
//

import UIKit
import Parse
import AlamofireImage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var username: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        profilePic.roundedImage()
        
        let user = PFUser.current()!
        
        username.text = user.username
        
        let imageFile = user["profile_pic"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        profilePic.af.setImage(withURL: url)
    }
    
    @IBAction func onChangePic(_ sender: Any) {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        picker.sourceType = .photoLibrary
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        // adjust size of image to decrease binary size using Alamofireimage module
        let size = CGSize(width: 128, height: 129)
        let scaledImage = image.af.imageAspectScaled(toFill: size, scale: nil)
        profilePic.image = scaledImage
        
        // set it in database
        let user = PFUser.current()!
        
        let imageData = profilePic.image!.pngData()
        let file = PFFileObject(name: "profile.png", data: imageData!)
        user.setValue(file, forKey: "profile_pic")
        
        user.saveInBackground { (success, error) in
            if success {
                self.dismiss(animated: true, completion: nil)
                print("success")
            }
            else {
                print("Error found: \(error!.localizedDescription)")
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
