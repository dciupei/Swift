//
//  AppDelegate.swift
//  Sudoku
//
//  Created by David Ciupei on 3/1/17.
//  Copyright © 2017 David Ciupei. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var sudoku : SudokuPuzzle?
    
    

    lazy var simplePuzzles = getPuzzles(name: "simple")
    lazy var hardPuzzles = getPuzzles(name: "hard")

    
    
    func archivePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true)
        
        let sandBoxDir : NSString = paths[0] as NSString
        let archiveName = sandBoxDir.appendingPathComponent("sudoku.plist")
        return archiveName
    }
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let archiveName = archivePath()
        if(FileManager.default.fileExists(atPath: archiveName)){
            let archive = NSArray(contentsOfFile: archiveName)
            
            self.sudoku = SudokuPuzzle()
            sudoku?.setState(puzzleArray: archive!)
        }else{
            self.sudoku = SudokuPuzzle()
            self.sudoku?.loadPuzzle(simplePuzzles[Int(arc4random_uniform(UInt32(simplePuzzles.count)))])
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
        let archive = sudoku?.savedState()
        archive?.write(toFile: archiveName, atomically: true)

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

