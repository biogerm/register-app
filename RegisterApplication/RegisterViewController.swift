//
//  RegisterViewController.swift
//  RegisterApplication
//
//  Created by Qin An on 15/10/15.
//  Copyright (c) 2015年 BiOgErM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RegisterViewController: UIViewController, UITextFieldDelegate {

    // MARK: - MVC Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        println(username)
        println(password)
        usernameTextField.text = username
        passwordTextField.text = password
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Member fields
    var username: String = ""
    var password: String = ""
    var loginTimestamp = ""
    
    // MARK: - Outlets
    @IBOutlet weak var usernameTextField: UITextField! {
        didSet {
            usernameTextField.delegate = self
        }
    }
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.delegate = self
        }
    }
   
    // MARK: - Text Field Delegate Functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == usernameTextField {
            username = textField.text
        } else {
            password = textField.text
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
        if segue.identifier == "finishRegisterShowLogins" {
            (segue.destinationViewController as! LatestLoginsViewController).latestLogins = "UTC\n\(loginTimestamp)"
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if usernameTextField.text == "" {
            showAlert(title: "Username Is Empty", message: "Please fill in username", button: "OK")
        }
        username = usernameTextField.text
        if passwordTextField.text == "" {
            showAlert(title: "Password Is Empty", message: "Please fill in password", button: "OK")
        }
        password = passwordTextField.text
        var finishFlag = 0
        var createSuccess = false
        let credentialData = "\(username):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
        let base64Credentials = credentialData.base64EncodedStringWithOptions(nil)
        let headers = ["Authorization": "Basic \(base64Credentials)"]
        var log = NSDate().timeIntervalSince1970 * 1000
        let parameter: [String: AnyObject] = [
            "username" : username,
            "password" : password,
            "login1" : Int(NSDate().timeIntervalSince1970 * 1000),
            "login2" : 0,
            "login3" : 0,
            "login4" : 0,
            "login5" : 0
        ]
        Alamofire.request(.POST, "http://127.0.0.1:8080/user", parameters: parameter, encoding: .JSON , headers: headers).responseJSON {
            request, response, data, error in
            let responseCode = response?.statusCode
            if responseCode == 409 {
                createSuccess = false
                finishFlag = 1
                return
            }
            let json = JSON(data!)
            self.loginTimestamp = (json["login1"].double == nil) ? "" : (NSDate(timeIntervalSince1970: json["login1"].double!/1000)).description
            finishFlag = 1
            createSuccess = true
        }
        while finishFlag == 0 {
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate.distantFuture() as! NSDate)
        }
        if createSuccess {
            return true
        }
        return false
    }

    // MARK: - Private Helper Funcitons
    func showAlert(#title: String, message: String, button: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: button, style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
