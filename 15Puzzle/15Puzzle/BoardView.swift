//
//  BoardView.swift
//  15Puzzle
//
//  Created by David Ciupei on 2/12/17.
//  Copyright © 2017 David Ciupei. All rights reserved.
//

import UIKit

class BoardView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews() // let autolayout engine finish first
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        let board = appDelegate.board // get model from app delegate
        let boardSquare = boardRect() // determine region to hold tiles (see below)
        let tileSize = boardSquare.width / 4.0
        let tileBounds = CGRect(x: 0, y: 0, width: tileSize, height: tileSize)
        for r in 0 ..< 4 { // manually set the bounds, and of each tile
            for c in 0 ..< 4 {
                let tile = board!.getTile(atRow: r, atColumn: c)
                if tile > 0 {
                    let button = self.viewWithTag(tile)
                    button!.layer.cornerRadius = 10
                    button!.layer.borderWidth = 1
                    button!.layer.borderColor = UIColor(red: 0.655, green: 0.957, blue: 0.196, alpha: 1).cgColor
                    button?.backgroundColor = UIColor.clear
                    button!.bounds = tileBounds
                    button!.center = CGPoint(x: boardSquare.origin.x + (CGFloat(c) + 0.5)*tileSize,
                                             y: boardSquare.origin.y + (CGFloat(r) + 0.5)*tileSize)
                }
            }
        }
    }
    
    
    
    func boardRect() -> CGRect { // get square for holding 4x4 tiles buttons
        let W = self.bounds.size.width
        let H = self.bounds.size.height
        let margin : CGFloat = 10
        let size = ((W <= H) ? W : H) - 2*margin
        let boardSize : CGFloat = CGFloat((Int(size) + 7)/8)*8.0 // next multiple of 8
        let leftMargin = (W - boardSize)/2
        let topMargin = (H - boardSize)/2
        return CGRect(x: leftMargin, y: topMargin, width: boardSize, height: boardSize)
    }

}
