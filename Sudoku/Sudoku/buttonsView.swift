//
//  buttonsView.swift
//  Sudoku
//
//  Created by David Ciupei on 3/3/17.
//  Copyright © 2017 David Ciupei. All rights reserved.
//

import UIKit

class buttonsView: UIView {

    let buttonTagsPortrait = [ // 2x6 button layout
        [1, 2, 3, 4, 5, 11], // tags assigned in IB
        [6, 7, 8, 9, 12, 10]
    ]
    let buttonTagsPortraitTall = [
        [1, 2, 3, 10],
        [4, 5, 6, 11],
        [7, 8, 9, 12]
    ] // 3x4 layout
    
    let buttonTagsLandscape = [
        [1, 6],
        [2, 7],
        [3, 8],
        [4, 9],
        [5, 10],
        [11, 12]
    ] // 6x2 layout
    
    let buttonTagsLandscapeTall = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
        [10, 11, 12]
    ] // 4x3 layout
    
    let aspectRatiosForLayouts : [Float] = [
        3.0, // 2 x 6
        4.0/3, // 3 x 4
        1.0/3, // 6 x 2
        3.0/4 // 4 x 3
    ]
    override func layoutSubviews() {
        super.layoutSubviews() // let Auto Layout finish
        let aspectRatio = Float(self.bounds.size.width / self.bounds.size.height)
        var closestLayout = 0
        var closestLayoutDiff = fabsf(aspectRatio - aspectRatiosForLayouts[0])
        for i in 1 ..< 4 {
            let diff = fabsf(aspectRatio - aspectRatiosForLayouts[i])
            if (diff < closestLayoutDiff) {
                closestLayout = i
                closestLayoutDiff = diff
            }
        }
        let buttonTagsFlavors = [
            buttonTagsPortrait, buttonTagsPortraitTall, buttonTagsLandscape, buttonTagsLandscapeTall
        ]
        let buttonTags = buttonTagsFlavors[closestLayout]
        func integersWithSum(sum : Int, count : Int) -> [Int] {
            var ints = [Int](repeating: sum / count, count: count)
            let r = sum % count
            for i in 0 ..< r {ints[i] += 1}
            return ints
        }
        let inset = 1
        let W = Int(self.bounds.width) - 2*inset, H = Int(self.bounds.height) - 2*inset
        let numColumns = buttonTags[0].count, numRows = buttonTags.count
        let widths = integersWithSum(sum: W, count: numColumns)
        let heights = integersWithSum(sum: H, count: numRows)
        var y = CGFloat(inset)
        for r in 0 ..< numRows {
            let h = CGFloat(heights[r])
            var x = CGFloat(inset)
            for c in 0 ..< numColumns {
                let w = CGFloat(widths[c])
                let button = self.viewWithTag(buttonTags[r][c])
                button?.bounds = CGRect(x: 0, y: 0, width: w - 3, height: h - 5)
                button?.center = CGPoint(x: x + w/2, y: y + h/2 - 1.5)
                button?.backgroundColor = UIColor(red: 194.0/255.0, green: 91.0/255.0, blue: 86.0/255.0, alpha: 1.0)
                button?.layer.cornerRadius = 10.0
                button?.layer.borderWidth = 2.0
                button?.layer.borderColor = UIColor.clear.cgColor
                button?.layer.shadowColor = UIColor(red: 100.0/255.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
                button?.layer.shadowOpacity = 1.0
                button?.layer.shadowRadius = 4.0
                button?.layer.shadowOffset = CGSize(width: 0, height: 2)
                x += w
            }
            y += h
        }
    }

}
