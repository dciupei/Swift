//
//  PuzzleView.swift
//  Sudoku
//
//  Created by David Ciupei on 3/3/17.
//  Copyright © 2017 David Ciupei. All rights reserved.
//

import UIKit

class PuzzleView: UIView {

    var selectedSquare = (row : -1, col : -1)

    required override init(frame: CGRect) {
        super.init(frame: frame)
        NSLog("ChessView:init(frame)")
        addMyTapGestureRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSLog("PuzzleView:init(decoder)")
        addMyTapGestureRecognizer()
    }
    
    func addMyTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PuzzleView.handleTap(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func handleTap(_ sender : UIGestureRecognizer?) {
        NSLog("tap")
        if let location = sender?.location(in: self) {
            NSLog("tap \(location)")
            let boardRect = self.boardRect()
            
            if (boardRect.contains(location)) {
                NSLog("inside board!")
                let squareSize = boardRect.size.width/9
                let col = Int((location.x - boardRect.origin.x)/squareSize)
                let row = Int((location.y - boardRect.origin.y)/squareSize)
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let puzzle = appDelegate.sudoku // fetch model data
                
                if 0 <= col && col < 9 && 0 <= row && row < 9 {
                    if (!puzzle!.numberIsFixedAtRow(row: row, column: col)) {
                        selectedSquare.col = col
                        selectedSquare.row = row
                        self.setNeedsDisplay()
                    }

                }
                
            }
        }
    }
    
    func boardRect() -> CGRect {
        let margin : CGFloat = 10
        let size = ceil((min(self.bounds.width, self.bounds.height) - margin/2.5))
        let center = CGPoint(x: self.bounds.width/2,
                             y :self.bounds.height/2)
        let boardRect = CGRect(x: center.x - size/2,
                               y: center.y - size/2,
                               width: size, height: size)
        return boardRect
    }
    
    override func draw(_ rect: CGRect) {
        NSLog("puzzleView.draw")
        let boardRect = self.boardRect()
        let squareSize = boardRect.size.width / 9
        let bigSquare = boardRect.size.width / 3

        if let context = UIGraphicsGetCurrentContext() {
            
            
            context.setLineWidth(3.0)
            UIColor(red: 82.0/255.0, green: 85.0/255.0, blue: 100.0/255.0, alpha: 1.0).setStroke()
            
            context.stroke(boardRect)
            
            for row in 0 ..< 3 {
                for col in 0 ..< 3 {
                    context.stroke(CGRect(x: boardRect.origin.x + CGFloat(col) * bigSquare,
                                          y: boardRect.origin.y + CGFloat(row) * bigSquare,
                                          width: bigSquare, height: bigSquare))
                }
            }
            
            context.setLineWidth(1);

            for row in 0 ..< 9 {
                for col in 0 ..< 9 {
                    context.stroke(CGRect(x: boardRect.origin.x + CGFloat(col) * squareSize,
                                          y: boardRect.origin.y + CGFloat(row) * squareSize,
                                          width: squareSize, height: squareSize))
                }
            }

            
            if selectedSquare.row >= 0 && selectedSquare.col >= 0 {
                UIColor.lightGray.setFill()
                let x = boardRect.origin.x + CGFloat(selectedSquare.col)*squareSize
                let y = boardRect.origin.y + CGFloat(selectedSquare.row)*squareSize
                context.fill(CGRect(x: x + 1, y: y + 1, width: squareSize - 2 , height: squareSize - 2))
            }
            
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let puzzle = appDelegate.sudoku
        
        let empty = 0
        for row in 0 ..< 9{
            for col in 0 ..< 9 {
                
                let number = puzzle!.numberAtRow(row: row, column: col)
                
                if number != empty {
                    if (puzzle?.numberIsFixedAtRow(row: row, column: col))!{
                        
                        //draw fixed values from plist file
                        let boldFont = UIFont(name: "Helvetica-Bold", size: 30)
                        let fixedAttributes = [NSFontAttributeName : boldFont!, NSForegroundColorAttributeName : UIColor(red: 82.0/255.0, green: 85.0/255.0, blue: 100.0/255.0, alpha: 1.0)]
                        let text : NSString = "\(number)" as NSString
                        let textSize = text.size(attributes: fixedAttributes)
                        let x = boardRect.origin.x + CGFloat(col)*squareSize + 0.5*(squareSize - textSize.width)
                        let y = boardRect.origin.y + CGFloat(row)*squareSize + 0.5*(squareSize - textSize.height)
                        let textRect = CGRect(x: x, y: y, width: textSize.width, height: textSize.height)
                        text.draw(in: textRect, withAttributes: fixedAttributes)
                        
                    }else{
                        
                        let boldFont = UIFont(name: "Helvetica-Bold", size: 30)
                        let fixedAttributes = [NSFontAttributeName : boldFont!, NSForegroundColorAttributeName : UIColor(red: 254.0/255.0, green: 246.0/255.0, blue: 235.0/255.0, alpha: 1.0)]
                        let text : NSString = "\(number)" as NSString
                        let textSize = text.size(attributes: fixedAttributes)
                        let x = boardRect.origin.x + CGFloat(col)*squareSize + 0.5*(squareSize - textSize.width)
                        let y = boardRect.origin.y + CGFloat(row)*squareSize + 0.5*(squareSize - textSize.height)
                        let textRect = CGRect(x: x, y: y, width: textSize.width, height: textSize.height)
                        text.draw(in: textRect, withAttributes: fixedAttributes)
                        
                        //check for win
                        if (puzzle?.checkWin())! {
                            NSLog("WINNER WINNER")
                            let alert = UIAlertController(title: "You Won!", message: "Try another puzzle!", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler: nil))
                            let window = UIApplication.shared.keyWindow
                            var vc = window?.rootViewController
                            while vc!.presentedViewController != nil{
                                vc = vc!.presentedViewController
                            }
                            vc?.present(alert, animated: true, completion: nil)
                            break
                        }
                    }
                } else {
                    
                    //pencil values
                    if puzzle!.anyPencilSetAtRow(row: row, column: col) {
                        var i = 0
                        for pencilRow in 0 ..< 3 {
                            for pencilCol in 0 ..< 3{
                                
                                if puzzle!.isSetPencil(n: i, row: row, column: col) {
                                    
                                    let boldFont = UIFont(name: "Helvetica-Bold", size: 10)
                                    let fixedAttributes = [NSFontAttributeName : boldFont!, NSForegroundColorAttributeName : UIColor.gray]
                                    let pencilNum = i + 1
                                    let text : NSString = "\(pencilNum)" as NSString
                                    let textSize = text.size(attributes: fixedAttributes)
                                    let x = boardRect.origin.x + CGFloat(col)*squareSize + CGFloat(pencilCol)*(squareSize/3)
                                        + 0.5*(squareSize/3 - textSize.width)
                                    let y = boardRect.origin.y + CGFloat(row)*squareSize + CGFloat(pencilRow)*(squareSize/3)
                                        + 0.5*(squareSize/3 - textSize.height)
                                    let textRect = CGRect(x: x, y: y, width: textSize.width, height: textSize.height)
                                    text.draw(in: textRect, withAttributes: fixedAttributes)
                                    
                                }
                                i += 1
                            }
                        }
                        
                    }
                }
                
            }
        }
    }
    

}
