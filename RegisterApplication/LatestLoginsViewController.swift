//
//  LatestLoginsViewController.swift
//  Pods
//
//  Created by Qin An on 15/10/14.
//
//

import UIKit

class LatestLoginsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Data structure that saves latest logins as String
    var latestLogins: String = ""

    @IBOutlet weak var latestLoginLabel: UILabel! {
        didSet {
            latestLoginLabel.text = latestLogins
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
