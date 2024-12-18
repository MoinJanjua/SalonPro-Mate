//
//  StartViewViewController.swift
//  SalonPro Mate
//
//  Created by Unique Consulting Firm on 16/12/2024.
//

import UIKit

class StartViewViewController: UIViewController {

    @IBOutlet weak var startbtn:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

    
    @IBAction func LetStartButton(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
       // self.tabBarController?.selectedIndex = 3
        newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }

}
