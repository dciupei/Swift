//
//  SudokuPuzzle.swift
//  Sudoku
//
//  Created by David Ciupei on 3/3/17.
//  Copyright © 2017 David Ciupei. All rights reserved.
//

import Foundation

func getPuzzles(name : String) -> [String] {
    let path = Bundle.main.path(forResource: name, ofType: "plist")
    let array = NSArray(contentsOfFile: path!)
    return array as! [String]
}

class SudokuPuzzle {

    struct Cell{
        var number : Int
        var isFixed : Bool
        var pencilMask : [Bool]
        
        init(numbers : Int = 0, fixed : Bool = false){
            number = numbers
            isFixed = fixed
            pencilMask = [false,false,false,false,false,false,false,false,false]
        }

    }
    
    var puzzle = [[Cell]]()

    
    init(){
        for _ in 0 ..< 9 {
            var subArray = [Cell]()
            for _ in 0 ..< 9{
                subArray.append(Cell())
            }
            puzzle.append(subArray)
        }
        
    }
    

    func savedState() -> NSArray{
        var arciveName: [[String : [Int]]] = []
        var savedCell: Dictionary<String, [Int]> = [:]

        for row in 0 ..< 9 {
            for col in 0 ..< 9 {
                savedCell["number"] = [puzzle[row][col].number]
                
                if(puzzle[row][col].isFixed){
                    savedCell["isFixed"] = [1]        // if it is fixed
                }else{
                    savedCell["isFixed"] = [0]
                }
                
                var pencilVals : [Int] = []
                
                for i in 0 ..< 9 {
                    if puzzle[row][col].pencilMask[i] {
                        pencilVals.append(1)        //if there is a pencil value
                    }else {
                        pencilVals.append(0)
                    }
                }
                
                savedCell["pencilMask"] = pencilVals
                arciveName.append(savedCell)

                
            }
        }
        return arciveName as NSArray
    }

    func setState(puzzleArray: NSArray){
        var savedCell: Dictionary<String, [Int]> = [:]

        var i : Int = 0

        for row in 0 ..< 9 {
            for col in 0 ..< 9 {
                
                savedCell = puzzleArray[i] as! [String : [Int]]
                puzzle[row][col].number = savedCell["number"]![0]
                
                if(savedCell["isFixed"]![0] == 1){
                    puzzle[row][col].isFixed = true
                }else{
                    puzzle[row][col].isFixed = false
                }
                
                for j in 0 ..< 9 {
                    if (savedCell["pencilMask"]![j] == 1){
                        puzzle[row][col].pencilMask[j] = true
                    }else{
                        puzzle[row][col].pencilMask[j] = false
                    }
                }
                i += 1
                
            }
        }
    
    }

    func loadPuzzle(_ puzzleString: String){
        var puzzleArray = [Int]()       // array that stores the puzzle
        
        for ch in puzzleString.characters {
            if ch == "." {
                puzzleArray.append(0)
            }else{
                let string = String(ch)
                let num = Int(string)
                puzzleArray.append(num!)
            }
        }
        
        var i = 0
        for row in 0 ..< 9 {
            for col in 0 ..< 9 {
                if puzzleArray[i] == 0{
                    puzzle[row][col].number = puzzleArray[i]
                    puzzle[row][col].isFixed = false
                    i += 1
                }else{
                    puzzle[row][col].number = puzzleArray[i]
                    puzzle[row][col].isFixed = true
                    i += 1
                }
                puzzle[row][col].pencilMask = [false,false,false,false,false,false,false,false,false]
            }
        }
    }
    


    func numberAtRow(row: Int, column: Int) -> Int{
        return puzzle[row][column].number

    }

    func setNumber(number: Int, row: Int, column: Int){
        puzzle[row][column].number = number
    }

    func numberIsFixedAtRow(row: Int, column: Int) -> Bool {
        return puzzle[row][column].isFixed
    }

    func isConflictingEntryAtRow(row: Int, column: Int) -> Bool{
        NSLog("row \(row) col \(column)")
        if puzzle[row][column].isFixed{

            return false
        }
        
        let number = puzzle[row][column].number
        
        if number == 0{
            return false
        }
        //check the row
        for col in 0 ..< 9 {
            if col == column{
                continue
            }
            let n = puzzle[row][col].number
            if n == number{
                return true
            }
        }
        
        //check the column
        for row_ in 0 ..< 9 {
            if row_ == row{
                continue
            }
            let n = puzzle[row_][column].number
            NSLog("n = \(n)")
            if n == number{
                return true
            }
        }
        
        //scan 3x3 block
        let blockRow = (row/3)*3
        let blockCol = (column/3)*3
        
        for j in 0 ..< 3 {
            for i in 0 ..< 3 {     
                let row1 = blockRow + j
                let col1 = blockCol + i
                if row1 == row && col1 == column{
                    continue
                }
                let n = puzzle[row1][col1].number
                if n == number {
                    return true
                }
            }
        }
        return false
    }
    
    func checkWin() -> Bool {
        NSLog("INSIDE CHECK FOR WIN")
        for row in 0 ..< 9 {
            for col in 0 ..< 9 {
                if puzzle[row][col].number == 0 {
                    //Still black sqaures that need to be filled
                    return false
                }
            }
        }
        //No Zero's left on the board. WINNER
        return true
    }
    

    func anyPencilSetAtRow(row: Int, column: Int) -> Bool{
        for i in 0 ..< 9 {
            if isSetPencil(n: i, row: row, column: column) {
                return true
            }
        }
        return false
    }

    func numberOfPencilsSetAtRow(row: Int, column: Int) -> Int{
        var pencils = 0
        
        for i in 0 ..< 9 {
            if isSetPencil(n: i, row: row, column: column) {
                pencils += 1
            }
        }
        
        return pencils

    }

    func isSetPencil(n: Int, row: Int, column: Int) -> Bool{
        return puzzle[row][column].pencilMask[n]
    }

    func setPencil(n: Int, row: Int, column: Int){
        puzzle[row][column].pencilMask[n] = true

    }

    func clearPencil(n: Int, row: Int, column: Int) {
        puzzle[row][column].pencilMask[n] = false
    }

    func clearAllPencils(row: Int, column: Int) {
        for i in 0 ..< 9 {
            puzzle[row][column].pencilMask[i] = false
        }
    }
}





