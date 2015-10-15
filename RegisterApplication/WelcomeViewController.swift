//
//  WelcomeViewController.swift
//  RegisterApplication
//
//  Created by Qin An on 15/10/14.
//  Copyright (c) 2015年 BiOgErM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class WelcomeViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - MVC Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Member fields
    var username: String = "" {
        didSet {
            usernameTextField.text = username
        }
    }
    var password: String = "" {
        didSet {
            passwordTextField.text = password
        }
    }
    var login1: String = ""
    var login2: String = ""
    var login3: String = ""
    var login4: String = ""
    var login5: String = ""
    
    
    // MARK: - Outlests
    @IBOutlet weak var usernameTextField: UITextField! {
        didSet {
            usernameTextField.delegate = self
            usernameTextField.text = ""
        }
    }
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.delegate = self
        }
    }
    
    @IBAction func loginTapped(sender: AnyObject) {
        if usernameTextField.text == "" {
            showAlert(title: "Username Is Empty", message: "Please fill in username", button: "OK")
        }
        username = usernameTextField.text
        if passwordTextField.text == "" {
            showAlert(title: "Password Is Empty", message: "Please fill in password", button: "OK")
        }
        password = passwordTextField.text
    }
    
    // MARK: - Text Field Delegate functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == usernameTextField {
            username = textField.text
        } else {
            password = textField.text
            loginTapped(self)
            shouldPerformSegueWithIdentifier("showLatestLogins", sender: self)
            performSegueWithIdentifier("showLatestLogins", sender: self)
        }
        return true
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showLatestLogins" {
            var logins = "UTC:\n\(login1)\n\(login2)\n\(login3)\n\(login4)\n\(login5)\n"
            (segue.destinationViewController as! LatestLoginsViewController).latestLogins = logins
        } else if segue.identifier == "showRegister" {
            println("username text field \(usernameTextField.text)")
            println("password text field \(passwordTextField.text)")
            (segue.destinationViewController as! RegisterViewController).username = usernameTextField.text
            (segue.destinationViewController as! RegisterViewController).password = passwordTextField.text
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "showLatestLogins" {
            if login() {
                return true
            } else {
                showAlert(title: "Login Failed", message: "Sorry login was failed. Please check your username/password or register", button: "OK")
                return false
            }
        } else {
            return true
        }
    }
    
    // MARK: - Private helper functions
    
    // Sending REST requests to server for update last login time
    func login() -> Bool {
        var finishFlag = 0
        var loginSuccess = true
        
        let credentialData = "\(username):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
        let base64Credentials = credentialData.base64EncodedStringWithOptions(nil)
        let headers = ["Authorization": "Basic \(base64Credentials)"]
        
        Alamofire.request(.PUT, "http://127.0.0.1:8080/user/\(self.username)", headers: headers).responseJSON {
            request, response, data, error in
            let responseCode = response?.statusCode
            if responseCode == 401 {
                loginSuccess = false
                finishFlag = 1
                return
            }
            let json = JSON(data!)
            self.login1 = (json["login1"].double == nil || json["login1"].double == 0) ? "" : (NSDate(timeIntervalSince1970: json["login1"].double!/1000)).description
            self.login2 = (json["login2"].double == nil || json["login2"].double == 0) ? "" : (NSDate(timeIntervalSince1970: json["login2"].double!/1000)).description
            self.login3 = (json["login3"].double == nil || json["login3"].double == 0) ? "" : (NSDate(timeIntervalSince1970: json["login3"].double!/1000)).description
            self.login4 = (json["login4"].double == nil || json["login4"].double == 0) ? "" : (NSDate(timeIntervalSince1970: json["login4"].double!/1000)).description
            self.login5 = (json["login5"].double == nil || json["login5"].double == 0) ? "" : (NSDate(timeIntervalSince1970: json["login5"].double!/1000)).description
            finishFlag = 1
            
        }
        while finishFlag == 0 {
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate.distantFuture() as! NSDate)
        }
        return loginSuccess
    }
    
    // Show customized Alert window
    func showAlert(#title: String, message: String, button: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: button, style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
