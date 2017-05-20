//
//  CardLayer.swift
//  Solitaire
//
//  Created by David Ciupei on 4/28/17.
//  Copyright © 2017 David Ciupei. All rights reserved.
//

import UIKit

func imageForCard(_ card : Card) -> UIImage {
    let suits = ["spades", "clubs", "diamonds", "hearts"]
    let ranks = ["", "a", "2", "3", "4", "5", "6", "7", "8",
                 "9", "10", "j", "q", "k"]
    let r : Int = Int(card.rank)
    let s : Int = Int(card.suit.rawValue)
    let imageName = "\(suits[s])-\(ranks[r])-150"
    let image = UIImage(named: imageName)
    return image!

}

class CardLayer: CALayer {
    let card : Card
    var faceUp : Bool {
        didSet {
            if faceUp != oldValue {
                let image = faceUp ? frontImage : CardLayer.backImage
                self.contents = image?.cgImage
            }
        }
    }
    let frontImage : UIImage
    static let backImage = UIImage(named: "back-red-150-3.png")
    
    init(card : Card) {
        self.card = card
        faceUp = true
        frontImage = imageForCard(card) // load associated image from main bundle
        super.init()
        self.contents = frontImage.cgImage
        self.contentsGravity = kCAGravityResizeAspect
    }
    
    override init(layer: Any) {
        self.card = Card(suit: .hearts, rank: 7)
        self.faceUp = false
        self.frontImage = UIImage()
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.card = Card(suit: .hearts, rank: 7)
        self.faceUp = false
        self.frontImage = UIImage()
        super.init(coder: aDecoder)    }
}
