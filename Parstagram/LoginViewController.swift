//
//  LoginViewController.swift
//  Parstagram
//
//  Created by Matthew Piedra on 10/7/21.
//

import UIKit
import Parse
import AlamofireImage

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let userIsSignedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        
        if userIsSignedIn {
            self.performSegue(withIdentifier: "loginSegue", sender: self)
        }
    }
    
    @IBAction func signIn(_ sender: Any) {
        let username = usernameField.text!
        let password = passwordField.text!
        
        PFUser.logInWithUsername(inBackground: username, password: password) {
            (user, error) in
            if user != nil {
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
            else {
                print("Error found: \(error!.localizedDescription)")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // reset form
        usernameField.text = ""
        passwordField.text = ""
    }
    
    @IBAction func signUp(_ sender: Any) {
        let user = PFUser()
        user.username = usernameField.text!
        user.password = passwordField.text!
        
        user.signUpInBackground { (success, error) in
            if success {
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
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
