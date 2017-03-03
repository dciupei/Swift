//
//  ViewController.swift
//  15Puzzle
//
//  Created by David Ciupei on 2/12/17.
//  Copyright © 2017 David Ciupei. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var boardview: BoardView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func tileSelected(_ sender: UIButton) {
        let tag = sender.tag
        NSLog("tileSelected: \(tag)")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let board = appDelegate.board // get model from app delegate
        let pos = board!.getRowAndColumn(forTile: sender.tag)
        let buttonBounds = sender.bounds
        var buttonCenter = sender.center
        var slide = true
        if board!.canSlideTileUp(atRow: pos!.row, Column: pos!.column) {
            buttonCenter.y -= buttonBounds.size.height
        } else if board!.canSlideTileDown(atRow: pos!.row, Column: pos!.column) {
            buttonCenter.y += buttonBounds.size.height
        } else if board!.canSlideTileLeft(atRow: pos!.row, Column: pos!.column) {
            buttonCenter.x -= buttonBounds.size.width
        } else if board!.canSlideTileRight(atRow: pos!.row, Column: pos!.column) {
            buttonCenter.x += buttonBounds.size.width
        } else {
            slide = false
        }
        if slide { // update model and view
            board!.canSlideTile(atRow: pos!.row, Column: pos!.column)
            sender.center = buttonCenter // animate later
            if (board!.isSolved()) { throwAPartyOnWin() }
            
        }
        
    }
    
    func throwAPartyOnWin() {
        let alert = UIAlertController(title: "You Won!!!!!!!!!", message: "", preferredStyle: UIAlertControllerStyle.alert)
        let scamble = UIAlertAction(title: "Play Again!", style: UIAlertActionStyle.default) {
            UIAlertAction in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let board = appDelegate.board
            board?.scramble(numTimes: appDelegate.numShuffles)
            self.boardview.setNeedsLayout() // will trigger layoutSubviews to be invoked
            
        }
        alert.addAction(scamble)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func shuffleTiles(_ sender: Any) {
        NSLog("Shuffle Button Pressed")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let board = appDelegate.board
        board?.scramble(numTimes: appDelegate.numShuffles)
        self.boardview.setNeedsLayout() // will trigger layoutSubviews to be invoked
        
    }
}



