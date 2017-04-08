//
//  Tweets_Table.swift
//  WSUV-Twitter
//
//  Created by David Ciupei on 4/3/17.
//  Copyright © 2017 David Ciupei. All rights reserved.
//

import UIKit
import Alamofire

class Tweets_Table: UITableViewController {

    @IBOutlet weak var Add_Tweet: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        navigationController?.navigationBar.barTintColor = UIColor.init(red: (163.0/255.0), green: (30.0/255.0), blue: (53.0/255.0), alpha: 1.0)

        self.title = "WSU Twitter"
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        getTweets()
        
        if(appDelegate.LoggedIn){
            Add_Tweet.isEnabled = true
        }else {
            Add_Tweet.isEnabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func refreshTweets(_ sender: Any) {
        
        getTweets()
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "kAddTweetNotification"),
            object: nil,
            queue: nil) { (note : Notification) -> Void in
                if !self.refreshControl!.isRefreshing {
                    self.refreshControl!.beginRefreshing()
                    self.refreshTweets(self)
                }
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweet_cell", for: indexPath)

        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        let tweet = appDelegate.tweets[indexPath.row]
        
        cell.textLabel?.numberOfLines = 0 // multi-line label
        cell.textLabel?.attributedText = attributedStringForTweet(tweet)

        return cell
    }
 

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        let tweet = appDelegate.tweets[indexPath.row]
        
        if tweet.username == appDelegate.username{
            return true

        }else{
            return false
        }
        
    }
 

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let tweet = appDelegate.tweets[indexPath.row]
            
            let urlString = kBaseURLString + "/del-tweet.cgi"
            
            let parameters : [String:AnyObject] = [
                "username" : appDelegate.username! as AnyObject,
                "session_token" : SSKeychain.password(forService: kWazzuTwitterPassword, account: appDelegate.username!+"token") as AnyObject,
                "tweet_id" : tweet.tweet_id as AnyObject
            ]
            // Delete the row from the data source
            Alamofire.request(urlString, method: .post, parameters: parameters)
                .responseJSON(completionHandler: {response in
                    switch(response.result) {
                    case .success( _):
                        appDelegate.tweets.remove(at: appDelegate.tweets.index(of: tweet)!)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        
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
                            case 403:
                                ErrorMessage = "Forbidded"
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
            
            }

        
    }
 

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    
    func getTweets(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "PST")
        let lastTweetDate = appDelegate.lastTweetDate()
        let dateStr = dateFormatter.string(from: lastTweetDate as Date)
        
        Alamofire.request(kBaseURLString + "/get-tweets.cgi", method: .get, parameters: ["date" : dateStr])
            .responseJSON {response in
                switch(response.result) {
                case .success(let JSON):
                    let dict = JSON as! [String : AnyObject]
                    let tweets = dict["tweets"] as! [[String : AnyObject]]
                    // ... create a new Tweet object for each returned tweet dictionary
                    // ... add new (sorted) tweets to appDelegate.tweets...
                    
                    for i in 0 ..< tweets.count {
                        let Individual_Tweet = tweets[i]
                        
                        let tweet_id = Individual_Tweet["tweet_id"] as! Int
                        let username = Individual_Tweet["username"] as! String
                        let date = dateFormatter.date(from: Individual_Tweet["time_stamp"] as! String)
                        let delete = Individual_Tweet["isdeleted"] as! Bool
                        let tweet_ = Individual_Tweet["tweet"] as! String
                        
                        
                        if !delete {
                            let tweet = Tweet(tweetid: tweet_id, U_name: username, delete: delete, twt: tweet_, date_: date! as NSDate)
                            appDelegate.tweets.insert(tweet, at: 0)
                        } else {
                            for tweet in appDelegate.tweets {
                                if tweet.tweet_id == tweet_id {
                                    appDelegate.tweets.remove(at: appDelegate.tweets.index(of: tweet)!)
                                }
                            }
                        }
                    
                        
                    }
                    self.tableView.reloadData() // force table-view to be updated
                    self.refreshControl?.endRefreshing()
                    
                case .failure(let error):
                    let ErrorMessage : String
                    if let statusCode = response.response?.statusCode {
                        
                        switch (statusCode){
                        case 500:
                            ErrorMessage = "Internal Service Error"
                        case 503:
                            ErrorMessage = "Database Unavailable"
                        default:
                            ErrorMessage = "\(statusCode)"
                            
                        }
                    }else {
                        ErrorMessage = error.localizedDescription
                    }
                    
                    let alertController = UIAlertController(title: "Error", message: ErrorMessage, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    
                
                }
            }
        self.refreshControl?.endRefreshing()
    }
    
    lazy var tweetDateFormatter : DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    let tweetTitleAttributes = [
        NSFontAttributeName : UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline),
        NSForegroundColorAttributeName : UIColor.purple
    ]
    lazy var tweetBodyAttributes : [String : AnyObject] = {
        let textStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        textStyle.lineBreakMode = .byWordWrapping
        textStyle.alignment = .left
        let bodyAttributes = [
            NSFontAttributeName : UIFont.preferredFont(forTextStyle: UIFontTextStyle.body),
            NSForegroundColorAttributeName : UIColor.black,
            NSParagraphStyleAttributeName : textStyle
        ]
        return bodyAttributes
    }()
    var tweetAttributedStringMap : [Tweet : NSAttributedString] = [:]
    func attributedStringForTweet(_ tweet : Tweet) -> NSAttributedString {
        let attributedString = tweetAttributedStringMap[tweet]
        if let string = attributedString { // already stored?
            return string
        }
        let dateString = tweetDateFormatter.string(from: tweet.date as Date)
        let title = String(format: "%@ - %@\n", tweet.username, dateString)
        let tweetAttributedString = NSMutableAttributedString(string: title, attributes: tweetTitleAttributes)
        let bodyAttributedString = NSAttributedString(string: tweet.tweet, attributes: tweetBodyAttributes)
        tweetAttributedString.append(bodyAttributedString)
        tweetAttributedStringMap[tweet] = tweetAttributedString
        return tweetAttributedString
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    override func tableView(_ tableView: UITableView,
                            estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.tweets.count
    }
    
    @IBAction func Account(_ sender: Any) {
            let alertController = UIAlertController(
                title: "Manage Account",
                message: nil,
                preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil))
            
            alertController.addAction(UIAlertAction(
                title: "Login",
                style: .default,
                handler: {(UIAlertAction) -> Void in
                    self.loginUser()}))
            
            alertController.addAction(UIAlertAction(
                title: "Register",
                style: .default,
                handler: {(UIAlertAction) -> Void in
                    self.Register()}))
            
            alertController.addAction(UIAlertAction(
                title: "Logout",
                style: .default,
                handler: {(UIAlertAction) -> Void in
                    self.Logout()}))
            
            self.present(alertController, animated: true, completion: nil)

        
    }
    
    
    
    
    func Logout(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if (appDelegate.username != ""){
        let urlString = kBaseURLString + "/login.cgi"
        
        let parameters = [
            "username" : appDelegate.username!,
            "password" : SSKeychain.password(forService: kWazzuTwitterPassword, account: appDelegate.username)!,
            "action"   : "logout"
        ]
        
        Alamofire.request(urlString, method: .post, parameters: parameters)
            .responseJSON(completionHandler: {response in
                switch(response.result) {
                case .success(let JSON):
                    let dict = JSON as! [String: AnyObject]
                    let token = dict["session_token"] as! String
                    appDelegate.username = ""
                    SSKeychain.setPassword(token, forService: kWazzuTwitterPassword, account: appDelegate.username!+"token")
                    
                    self.title = "WSU Twitter"
                    appDelegate.LoggedIn = false
                    self.Add_Tweet.isEnabled = false
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
                    
                    let alertController = UIAlertController(title: "Error", message: ErrorMessage, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    
                    
                }
            })
        }else{
            let alertController = UIAlertController(title: "Error", message: "Not Logged In!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    func Register_User(username: String, password: String){
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate

                    let urlString = kBaseURLString + "/register.cgi"
                    let parameters = [
                        "username" : username, // username and password
                        "password" : password, // obtained from user
                    ]
                    Alamofire.request(urlString, method: .post, parameters: parameters)
                        .responseJSON(completionHandler: {response in
                            switch(response.result) {
                            case .success(let JSON):
                                let dict = JSON as! [String: AnyObject]
                                let token = dict["session_token"] as! String
                                appDelegate.username = username
                                SSKeychain.setPassword(password, forService: kWazzuTwitterPassword, account: username)
                                SSKeychain.setPassword(token, forService: kWazzuTwitterPassword, account: username+"token")
                            
                                self.title = "\(username)"
                                appDelegate.LoggedIn = true
                                self.Add_Tweet.isEnabled = true
                            // change title of controller to show username, etc...
                            case .failure(let error):
                                let ErrorMessage : String
                                if let statusCode = response.response?.statusCode {

                                switch (statusCode){
                                case 500:
                                    ErrorMessage = "Internal Service Error"
                                case 400:
                                    ErrorMessage = "Bad Request"
                                case 409:
                                    ErrorMessage = "Conflict"
                                default:
                                    ErrorMessage = "\(statusCode)"
                                    
                                }
                                }else{
                                    ErrorMessage = error.localizedDescription
                                }
                                // inform user of error
                                let alertController = UIAlertController(title: "Error", message: ErrorMessage, preferredStyle: .alert)
                                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alertController, animated: true, completion: nil)
                                
                            
                        }
                    })
    
    }

    
    func Register(){
        let alertController = UIAlertController(title: "Register", message: "Please Log in", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Register", style: .default, handler: { _ in
            let usernameTextField = alertController.textFields![0]
            let passwordTextField = alertController.textFields![1]
            
            let username = usernameTextField.text!
            let password = passwordTextField.text!
            
            
            if username.isEmpty || password.isEmpty {
                let alertController1 = UIAlertController(title: "Error", message: "Username or Password is blank!", preferredStyle: .alert)
                alertController1.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in self.Register()}))
                
                self.present(alertController1, animated: true, completion: nil)
                
            }
            
            self.Register_User(username: username, password: password)
            
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addTextField { (textField : UITextField) -> Void in
            textField.placeholder = "Username"
        }
        alertController.addTextField { (textField : UITextField) -> Void in
            textField.isSecureTextEntry = true
            textField.placeholder = "Password"
        }
       
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func loginUser(){
        let alertController = UIAlertController(title: "Login", message: "Please Log in", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Login", style: .default, handler: { _ in
            let usernameTextField = alertController.textFields![0]
            let passwordTextField = alertController.textFields![1]
            
            let username = usernameTextField.text!
            let password = passwordTextField.text!
            
            if username.isEmpty || password.isEmpty {
                let alertController1 = UIAlertController(title: "Error", message: "Username or Password is blank!", preferredStyle: .alert)
                alertController1.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                self.present(alertController1, animated: true, completion: nil)
                
            }
            self.Login_User(username: username, password: password)
            
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addTextField { (textField : UITextField) -> Void in
            textField.placeholder = "Username"
        }
        alertController.addTextField { (textField : UITextField) -> Void in
            textField.isSecureTextEntry = true
            textField.placeholder = "Password"
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    func Login_User(username: String, password: String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let urlString = kBaseURLString + "/login.cgi"
        let parameters = [
            "username" : username, // username and password
            "password" : password, // obtained from user
            "action"   : "login"
        ]
        
        Alamofire.request(urlString, method: .post, parameters: parameters)
            .responseJSON(completionHandler: {response in
                switch(response.result) {
                case .success(let JSON):
                    let dict = JSON as! [String: AnyObject]
                    let token = dict["session_token"] as! String
                    appDelegate.username = username
                    SSKeychain.setPassword(password, forService: kWazzuTwitterPassword, account: username)
                    SSKeychain.setPassword(token, forService: kWazzuTwitterPassword, account: username+"token")
                    
                    self.title = "\(username)"
                    appDelegate.LoggedIn = true
                    self.Add_Tweet.isEnabled = true
                // change title of controller to show username, etc...
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
        
        
    }
    
    
}
