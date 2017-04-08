//
//  AppDelegate.swift
//  WSUV-Twitter
//
//  Created by David Ciupei on 4/3/17.
//  Copyright © 2017 David Ciupei. All rights reserved.
//

import UIKit
import AlamofireNetworkActivityIndicator

let kBaseURLString = "https://ezekiel.encs.vancouver.wsu.edu/~cs458/cgi-bin"
//let kBaseURLString = "https://bend.encs.vancouver.wsu.edu/~wcochran/cgi-bin"
let kWazzuTwitterPassword = "WazzuTwitterPassword" // KeyChain service

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    var tweets = [Tweet]()
    var LoggedIn : Bool = false
    var username : String? = ""

    func lastTweetDate() -> NSDate{
        
        if tweets.count == 0 {
            return NSDate.distantPast as NSDate
        } else {
            return tweets.first!.date
        }
    }
    
    func archivePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true)
        
        let sandBoxDir : NSString = paths[0] as NSString
        let archiveName = sandBoxDir.appendingPathComponent("tweets.plist")
        return archiveName
    }
    
    func archivePathUsername() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true)
        
        let sandBoxDir : NSString = paths[0] as NSString
        let archiveName = sandBoxDir.appendingPathComponent("user.plist")
        return archiveName
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        NetworkActivityIndicatorManager.shared.isEnabled = true
        let archiveName = archivePath()
        
        if(FileManager.default.fileExists(atPath: archiveName)){

            let archive = NSArray(contentsOfFile: archiveName)
            
            for i in archive! {
                let tweet = i as! [String:AnyObject]
                
                tweets.append(Tweet(
                    tweetid: tweet["tweet_id"] as! Int,
                    U_name: tweet["username"] as! String,
                    delete: tweet["isDeleted"] as! Bool,
                    twt: tweet["tweet"] as! String,
                    date_: tweet["date"] as! NSDate))
            }
            
        }
        
        let archiveNameUser = archivePath()
        if(FileManager.default.fileExists(atPath: archiveNameUser)){
            
            let archive = NSDictionary(contentsOfFile: archiveNameUser)
            username = archive!["username"] as? String
            LoggedIn = archive!["loggedin"] as! Bool
            
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        let archiveName = archivePath()
        var list : [[String:AnyObject]] = []
        
        
        for tweet in tweets {
            let tweets_ = [
                "tweet_id" : tweet.tweet_id,
                "username" : tweet.username,
                "isDeleted" : tweet.isDeleted,
                "tweet" : tweet.tweet,
                "date" : tweet.date
            ] as [String : Any]
            list.append(tweets_ as [String : AnyObject])
        }
        
        let archive = list as NSArray
        archive.write(toFile: archiveName, atomically: true)

        
        let archiveNameUser = archivePath()

        let userDict : [String: AnyObject] = [
            "username" : username! as AnyObject,
            "loggedin" : LoggedIn as AnyObject
        ]
        let archiveUser = userDict as NSDictionary
        archiveUser.write(toFile: archiveNameUser, atomically: true)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

