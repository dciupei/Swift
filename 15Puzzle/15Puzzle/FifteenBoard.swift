//
//  FifteenBoard.swift
//  15Puzzle
//
//  Created by David Ciupei on 2/12/17.
//  Copyright © 2017 David Ciupei. All rights reserved.
//

import UIKit
import Foundation

class FifteenBoard {
   
    var state : [[Int]] = [
        [1, 2, 3, 4],
        [5, 6, 7, 8],
        [9, 10, 11, 12],
        [13, 14, 15, 0] // 0 => empty slot
    ]
    
    func scramble(numTimes n : Int) {
        var r:Int
        var c:Int
        var temp: Int = n
        while temp > 0 {
            //for index in stride(from: n, to: 0, by: -1) {  //had to switch to while loop this wouldnt scramble good enough
            r = Int(arc4random() % 4)
            c = Int(arc4random() % 4)
            if (canSlideTileUp(atRow: r, Column: c) || canSlideTileDown(atRow: r, Column: c) ||
                canSlideTileLeft(atRow: r, Column: c) || canSlideTileRight(atRow: r, Column: c)) {
                canSlideTile(atRow: r, Column: c)
                temp -= 1
            }
            
            
        }
    }
    
    func getTile(atRow r:Int, atColumn c:Int) -> Int{
        return state[r][c]
    }
    
    func getRowAndColumn(forTile tile: Int) -> (row: Int, column: Int)? {
        
        for r in 0 ..< 4 {
            for c in 0 ..< 4 {
                if (state[r][c] == tile) {
                    return (r,c)
                }
            }
        }
        return nil
    }
    
    
    
    func isSolved() -> Bool{
        var result: Int
        var temp = [Int]()
        var spot: Int = 0
        let solved_Puzzle: [Int] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0]
        
        for r in 0 ..< 4 {
            for c in 0 ..< 4 {
                result = state[r][c]
                temp.insert(result, at: spot)
                spot += 1
            }
        }
        
        if (temp == solved_Puzzle){
            return true
        }
        
        return false
    }
    
    
    
    func canSlideTileUp(atRow r : Int, Column c : Int) -> Bool{
        if(r != 0 && state[r-1][c] == 0){
            return true
        }
        return false
        
        
    }
    
    func canSlideTileDown(atRow r : Int, Column c : Int) -> Bool{
        if(r != 3 && state[r+1][c] == 0){
            return true
        }
        return false
        
        
    }
    
    func canSlideTileLeft(atRow r : Int, Column c : Int) -> Bool{
        if(c != 0 && state[r][c-1] == 0){
            return true
        }
        return false
        
    }
    
    func canSlideTileRight(atRow r : Int, Column c : Int) -> Bool{
        if(c != 3 && state[r][c+1] == 0){
            return true
        }
        return false
        
    }
    
    func canSlideTile(atRow r : Int, Column c : Int) -> Bool{
        var original:Int = state[r][c]
        var temp:Int
        if(canSlideTileUp(atRow: r, Column: c)){
            temp = state[r-1][c]
            state[r][c] = temp
            state[r-1][c] = original
            return true
            
        } else if(canSlideTileDown(atRow: r, Column: c)){
            temp = state[r+1][c]
            state[r][c] = temp
            state[r+1][c] = original
            return true
            
        } else if(canSlideTileLeft(atRow: r, Column: c)){
            temp = state[r][c-1]
            state[r][c] = temp
            state[r][c-1] = original
            return true
            
        } else if(canSlideTileRight(atRow: r, Column: c)){
            temp = state[r][c+1]
            state[r][c] = temp
            state[r][c+1] = original
            return true
            
        }
        return false
    }


}
