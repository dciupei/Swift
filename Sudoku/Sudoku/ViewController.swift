//
//  ViewController.swift
//  Sudoku
//
//  Created by David Ciupei on 3/1/17.
//  Copyright © 2017 David Ciupei. All rights reserved.
//abc

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var ButtonView: buttonsView!
    @IBOutlet weak var puzzleView: PuzzleView!
    
    var pencilEnabled : Bool = false // controller property
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func numberPressed(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let puzzle = appDelegate.sudoku
        
        if pencilEnabled {
            if puzzle!.numberAtRow(row: puzzleView.selectedSquare.row, column: puzzleView.selectedSquare.col) == 0{
                
                if puzzle!.isSetPencil(n: sender.tag-1, row: puzzleView.selectedSquare.row, column: puzzleView.selectedSquare.col){
                    
                    puzzle!.clearPencil(n: sender.tag-1, row: puzzleView.selectedSquare.row, column: puzzleView.selectedSquare.col)
                }else{
                    puzzle!.setPencil(n: sender.tag-1, row: puzzleView.selectedSquare.row, column: puzzleView.selectedSquare.col)
                }
            }
            self.puzzleView.setNeedsDisplay()
        }else {
            
            puzzle?.setNumber(number: sender.tag, row: puzzleView.selectedSquare.row, column: puzzleView.selectedSquare.col)
            self.puzzleView.setNeedsDisplay()
            
            if puzzle!.isConflictingEntryAtRow(row: puzzleView.selectedSquare.row, column: puzzleView.selectedSquare.col){
                
                let alert = UIAlertController(title: "Confliting Number", message: "Number already inside row, column, or block!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler: nil))
                
                self.present(alert, animated: true, completion: nil)

                puzzle?.setNumber(number: 0, row: puzzleView.selectedSquare.row, column: puzzleView.selectedSquare.col)
            }
        }
        

    }

    
    @IBAction func erasePressed(_ sender: UIButton) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let puzzle = appDelegate.sudoku
        
        if pencilEnabled {
            
            let alert = UIAlertController(title: "Delete Pencil Values", message: "Do you want to continue?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler: nil))
            alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default , handler: { (UIAlertAction) -> Void in
                puzzle?.clearAllPencils(row: self.puzzleView.selectedSquare.row, column: self.puzzleView.selectedSquare.col)
                self.puzzleView.setNeedsDisplay()
            }))
            self.present(alert, animated: true, completion: nil)

            
        } else {
            puzzle?.setNumber(number: 0, row: puzzleView.selectedSquare.row, column: puzzleView.selectedSquare.col)
            self.puzzleView.setNeedsDisplay()
        }
        
    }
    
    
    @IBAction func pencilPressed(_ sender: UIButton) {
        pencilEnabled = !pencilEnabled // toggle
        sender.isSelected = pencilEnabled
        if pencilEnabled {
            sender.backgroundColor = UIColor(red: 82.0/255.0, green: 85.0/255.0, blue: 100.0/255.0, alpha: 1.0)

        } else{
            sender.backgroundColor = UIColor(red: 194.0/255.0, green: 91.0/255.0, blue: 86.0/255.0, alpha: 1.0)
        }
    }
    
    
    @IBAction func menuPressed(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let puzzle = appDelegate.sudoku
        let alertController = UIAlertController(
            title: "Main Menu",
            message: nil,
            preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil))
        alertController.addAction(UIAlertAction(
            title: "New Easy Game",
            style: .default,
            handler: { (UIAlertAction) -> Void in
                let puzzleStr = self.randomPuzzle(appDelegate.simplePuzzles)
                puzzle?.loadPuzzle(puzzleStr)
                self.puzzleView.setNeedsDisplay()}))
        alertController.addAction(UIAlertAction(
            title: "New Hard Game",
            style: .default,
            handler: { (UIAlertAction) -> Void in
                let puzzleStr = self.randomPuzzle(appDelegate.hardPuzzles)
                puzzle?.loadPuzzle(puzzleStr)
                self.puzzleView.setNeedsDisplay()}))
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            let popoverPresenter = alertController.popoverPresentationController
            let menuButtonTag = 12
            let menuButton = ButtonView.viewWithTag(menuButtonTag)
            popoverPresenter?.sourceView = menuButton
            popoverPresenter?.sourceRect = (menuButton?.bounds)!
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func randomPuzzle(_ list : [String]) -> String {
        return list[Int(arc4random_uniform(UInt32(list.count)))]
    }
    
}

