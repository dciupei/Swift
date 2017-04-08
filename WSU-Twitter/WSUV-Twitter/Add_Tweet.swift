//
//  Add_Tweet.swift
//  WSUV-Twitter
//
//  Created by David Ciupei on 4/6/17.
//  Copyright © 2017 David Ciupei. All rights reserved.
//

import UIKit
import Alamofire

class Add_Tweet: UITableViewController,UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var characterNum: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor.init(red: (163.0/255.0), green: (30.0/255.0), blue: (53.0/255.0), alpha: 1.0)
        textView.layer.borderWidth = 2.0
        textView.layer.borderColor = UIColor.black.cgColor
        textView.delegate = self
        self.characterNum.text = "\(textView.text.characters.count)/140"

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textViewDidChange(_ textView: UITextView) {
        self.characterNum.text = "\(textView.text.characters.count)/140"
        if(textView.text.characters.count <= 140){
            textView.textColor = UIColor.black
        }else{
            textView.textColor = UIColor.red

        }

    }


    @IBAction func Finished_Tweet(_ sender: Any) {
        
        if(textView.text.characters.count <= 140){

        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let urlString = kBaseURLString + "/add-tweet.cgi"
        let parameters = [
            "username" : appDelegate.username!,  // username and password
            "session_token" : SSKeychain.password(forService: kWazzuTwitterPassword, account: appDelegate.username!+"token")!,  // obtained from user
            "tweet" : textView.text
            
        ] as [String : Any]
        
        Alamofire.request(urlString, method: .post, parameters: parameters)
            .responseJSON(completionHandler: {response in
                switch(response.result) {
                case .success( _):
                    NotificationCenter.default.post(NSNotification(name: NSNotification.Name(rawValue: kWazzuTwitterPassword), object: nil) as Notification)

                case .failure(let error):
                    let ErrorMessage : String
                    if let statusCode = response.response?.statusCode {
                        
                        switch (statusCode){
                        case 500:
                            ErrorMessage = "Internal Service Error"
                        case 400:
                            ErrorMessage = "Bad Request"
                        case 401:
                            ErrorMessage = "Wrong Password"
                        case 404:
                            ErrorMessage = "No such user"
                        default:
                            ErrorMessage = "\(statusCode)"
                            
                        }
                    }else {
                        ErrorMessage = error.localizedDescription
                    }
                    // inform user of error
                    let alertController = UIAlertController(title: "Error", message: ErrorMessage, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    
                    
                }
            })
            
            self.dismiss(animated: true, completion: nil)
        }else{
            let alertController = UIAlertController(title: "To many Characters", message: "Max of 140 characters Allowed!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func Cancel_Tweet(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
   
}
