//
//  SolitaireView.swift
//  Solitaire
//
//  Created by David Ciupei on 4/28/17.
//  Copyright © 2017 David Ciupei. All rights reserved.
//

import UIKit

var FAN_OFFSET : CGFloat = 0.2

class SolitaireView: UIView {

    
    var stockLayer : CALayer!
    var wasteLayer : CALayer!
    var foundationLayers : [CALayer]! // four foundation layers
    var tableauLayers : [CALayer]! // seven tableau layers
    
    var topZPosition : CGFloat = 0 // "highest" z-value of all card layers
    var cardToLayerDictionary : [Card : CardLayer]! // map card to it’s layer
    
    var draggingCardLayer : CardLayer? = nil // card layer dragged (nil => no drag)
    var draggingFan : [Card]? = nil // fan of cards dragged
    var touchStartPoint : CGPoint = CGPoint.zero
    var touchStartLayerPosition : CGPoint = CGPoint.zero
    
    lazy var solitaire : Solitaire! = { // reference to model in app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.solitaire
    }()
    
    
    override func awakeFromNib() {
        self.layer.name = "background"
        
        stockLayer = CALayer()
        stockLayer.name = "stock"
        stockLayer.backgroundColor =
            UIColor(colorLiteralRed: 0.0, green: 0.5, blue: 0.1, alpha: 0.3).cgColor
        self.layer.addSublayer(stockLayer)
        
        //waste layer
        wasteLayer = CALayer()
        wasteLayer.name = "waste"
        wasteLayer.backgroundColor =
            UIColor(colorLiteralRed: 0.0, green: 0.5, blue: 0.1, alpha: 0.3).cgColor
        self.layer.addSublayer(wasteLayer)
        
        
        //foundation layer
        foundationLayers = []
        for _ in 0 ..< 4 {
            let foundationLayer = CALayer()
            foundationLayer.name = "foundation"
            foundationLayer.backgroundColor =
                UIColor(colorLiteralRed: 0.0, green: 0.5, blue: 0.1, alpha: 0.3).cgColor
            self.layer.addSublayer(foundationLayer)
            foundationLayers.append(foundationLayer)
        }
        
        //tableau layer
        tableauLayers = []
        for _ in 0 ..< 7 {
            let tableauLayer = CALayer()
            tableauLayer.name = "tableau"
            tableauLayer.backgroundColor =
                UIColor(colorLiteralRed: 0.0, green: 0.5, blue: 0.1, alpha: 0.3).cgColor
            self.layer.addSublayer(tableauLayer)
            tableauLayers.append(tableauLayer)
        }
        
        let deck = Card.deck()  // deck of poker cards
        cardToLayerDictionary = [:]
        for card in deck {
            let cardLayer = CardLayer(card: card)
            cardLayer.name = "card"
            self.layer.addSublayer(cardLayer)
            cardToLayerDictionary[card] = cardLayer
        }
    }

    
    override func layoutSublayers(of layer: CALayer) {
        draggingCardLayer = nil // deactivate any dragging
        layoutTableAndCards()
    }
    
    func layoutTableAndCards() {
        let width = bounds.size.width
        let height = bounds.size.height
        let portrait = width < height
        
    
        var m : CGFloat
        var t : CGFloat
        var d : CGFloat
        var s : CGFloat
        
        var w : CGFloat
        var h : CGFloat
        
        let ratio : CGFloat = 215/150
        
        if portrait {
            FAN_OFFSET = 0.25
            m = 8.0
            t = 8.0
            d = 4.0
            s = 16.0
            w = (width - 2*m - 6*d)/7
            h = w*ratio
            
            
        } else {
            FAN_OFFSET = 0.15
            m = 64.0
            t = 8.0
            s = 12.0
            h = (height - 2*t - s)/4.7
            w = h / ratio
            d = (width - 2*m - 7*w)/6
        }
        
        
        // stock
        stockLayer.bounds = CGRect(x: 0, y: 0, width: w, height: h)
        stockLayer.position = CGPoint(x: m + w/2, y: t + h/2)
        
        
        // waste
        wasteLayer.bounds = CGRect(x: 0, y: 0, width: w, height: h)
        wasteLayer.position = CGPoint(x: m + d + w + w/2, y: t + h/2)
        
        
        // foundation
        for i in 0 ..< 4 {
            foundationLayers[i].bounds = CGRect(x: 0,y: 0,width: w,height: h)
            foundationLayers[i].position = CGPoint(
                x: 3*w + m + 3*d + w * CGFloat(i) + d * CGFloat(i) + w/2,
                y: t + h/2)
        }
        
        
        // tableau
        for i in 0 ..< 7 {
            tableauLayers[i].bounds = CGRect(x: 0,y: 0,width: w,height: h)
            tableauLayers[i].position = CGPoint(
                x: CGFloat(i)*w + m + d*CGFloat(i) + w/2,
                y: t + s + h + h/2)
        }
        
        layoutCards()
    }
    
    
    func layoutCards() {
        var z : CGFloat = 1.0
        let stock = solitaire.stock
        for card in stock {
            let cardLayer = cardToLayerDictionary[card]!
            cardLayer.frame = stockLayer.frame
            cardLayer.faceUp = solitaire.isCardFaceUp(card)
            cardLayer.zPosition = z; z = z + 1
        }
        //... layout cards in waste and foundation stacks ...
        
        let waste = solitaire.waste
        for card in waste {
            let cardLayer = cardToLayerDictionary[card]!
            cardLayer.frame = wasteLayer.frame
            cardLayer.faceUp = solitaire.isCardFaceUp(card)
            cardLayer.zPosition = z
            z = z + 1
        }
        
        let foundation = solitaire.foundation
        for i in 0 ..< 4 {
            for card in foundation[i] {
                let cardLayer = cardToLayerDictionary[card]!
                cardLayer.frame = foundationLayers[i].frame
                cardLayer.faceUp = solitaire.isCardFaceUp(card)
                cardLayer.zPosition = z
                z = z + 1
            }
        }
        
        let cardSize = stockLayer.bounds.size
        let fanOffset = FAN_OFFSET * cardSize.height
        for i in 0 ..< 7 {
            let tableau = solitaire.tableau[i]
            let tableauOrigin = tableauLayers[i].frame.origin
            var j : CGFloat = 0
            for card in tableau {
                let cardLayer = cardToLayerDictionary[card]!
                cardLayer.frame =
                    CGRect(x: tableauOrigin.x, y: tableauOrigin.y + j*fanOffset,
                           width: cardSize.width, height: cardSize.height)
                cardLayer.faceUp = solitaire.isCardFaceUp(card)
                cardLayer.zPosition = z; z = z + 1
                j = j + 1
            }
        }
        topZPosition = z // remember "highest position"
    }
    
    func scatterCardsAnimChain(_ i : Int) {
        if (i >= 0) {
            let deck = Card.deck()

            //let clayer = foundationLayers[i]
            let clayer = cardToLayerDictionary[deck[i]]

            CATransaction.begin()
            
            CATransaction.setDisableActions(true)
            clayer?.zPosition = topZPosition
            CATransaction.commit()
            topZPosition = topZPosition + 1
            
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                self.scatterCardsAnimChain(i-1)
            }
            
            CATransaction.setAnimationDuration(0.1)
            
            let x = CGFloat(drand48())*bounds.width
            let y = CGFloat(drand48())*bounds.height
            clayer?.position = CGPoint(x: x, y: y)
            clayer?.transform = CATransform3DIdentity
            CATransaction.commit()
        }

    }
    
    
    func scatterCards() {
        scatterCardsAnimChain(51)
        let alert = UIAlertController(title: "You Won!", message: "Winner Winner Chicken Dinner!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Play Again!", style: UIAlertActionStyle.default, handler:
            {(UIAlertAction) -> Void in
                self.solitaire.freshGame()
                self.layoutSublayers(of: self.layer)}))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let touchPoint = touch.location(in: self)
        let hitTestPoint = self.layer.convert(touchPoint, to: self.layer.superlayer)
        let layer = self.layer.hitTest(hitTestPoint)
        if let layer = layer {
            if layer.name == "card" {
                let cardLayer = layer as! CardLayer
                let card = cardLayer.card
                if solitaire.isCardFaceUp(card) {
                    if touch.tapCount > 1 {
                        
                        // check foundation
                        for i in 0 ..< 4 {
                            if solitaire.canDropCard(card, onFoundation: i){
                                solitaire.didDropCard(card, onFoundation: i)
                                draggingCardLayer = cardLayer
                                dragCardsToPosition(position: foundationLayers[i].position, animate: true)
                                draggingCardLayer = nil
                                if solitaire.gameWon() {
                                    scatterCards()
                                }
                                layoutSublayers(of: self.layer)
                                break
                            }
                        }
                    }else{
                        if solitaire.waste.last == card {
                            cardLayer.zPosition = topZPosition + 1
                            touchStartPoint = touchPoint
                            touchStartLayerPosition = layer.position
                            draggingCardLayer = cardLayer
                        }
                        
                        for i in 0 ..< 7 {
                            if solitaire.tableau[i].last == card {
                                cardLayer.zPosition = topZPosition + 1
                                touchStartPoint = touchPoint
                                touchStartLayerPosition = layer.position
                                draggingCardLayer = cardLayer
                            } else {
                                if solitaire.tableau[i].contains(card) {
                                    if let dragCards = solitaire.fanBeginningWithCard(card) {
                                        
                                        for j in 0 ..< dragCards.count {
                                            let f_Layer = cardToLayerDictionary[dragCards[j]]
                                            f_Layer?.zPosition = topZPosition
                                            topZPosition = topZPosition + 1
                                            
                                        }
                                        self.draggingFan = dragCards
                                        touchStartPoint = touchPoint
                                        touchStartLayerPosition = layer.position
                                        draggingCardLayer = cardLayer
                                    }
                                }
                            }
                        }
                    }
                    
                    for i in 0 ..< 4 {
                        if solitaire.foundation[i].last == card {
                            cardLayer.zPosition = topZPosition + 1
                            touchStartPoint = touchPoint
                            touchStartLayerPosition = layer.position
                            draggingCardLayer = cardLayer
                        }
                    }
                    
                    
                }
                else if solitaire.canFlipCard(card) {
                    flipCard(card, faceUp: true)  // update model and view
                } else if solitaire.stock.last == card {
                    dealCardsFromStockToWaste()
                }
            } else if (layer.name == "stock") {
                collectWasteCardsIntoStock()
            }
        }
    }
    
    func flipCard(_ card : Card, faceUp : Bool) {
        let cardLayer = cardToLayerDictionary[card]!
        cardLayer.faceUp = faceUp
        solitaire.didFlipCard(card)
    }
    
    
    func dealCardsFromStockToWaste() {
        if solitaire.canDealCard() {
            let card = solitaire.stock.last
            solitaire.didDealCard()
            
            let cardLayer = cardToLayerDictionary[card!]
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            cardLayer!.zPosition = topZPosition + 1
            CATransaction.commit()
            cardLayer!.position = wasteLayer.position
            
            layoutSublayers(of: self.layer)
        }
    }
    
    
    func collectWasteCardsIntoStock() {
        solitaire.collectWasteCardsIntoStock()
        layoutSublayers(of: self.layer)
    }
    
    func dragCardsToPosition(position : CGPoint, animate : Bool) {
        if !animate {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
        }
        draggingCardLayer!.position = position
        if let draggingFan = draggingFan {
            let off = FAN_OFFSET*draggingCardLayer!.bounds.size.height
            let n = draggingFan.count
            for i in 1 ..< n {
                let card = draggingFan[i]
                let cardLayer = cardToLayerDictionary[card]!
                cardLayer.position = CGPoint(x: position.x, y: position.y + CGFloat(i)*off)
            }
        }
        if !animate {
            CATransaction.commit()
        }
    }

    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = draggingCardLayer {
            let touch = touches.first
            let touchPoint = touch?.location(in: self)
            let delta = CGPoint(x: touchPoint!.x - touchStartPoint.x, y: touchPoint!.y - touchStartPoint.y)
            let pos = CGPoint(x: touchStartLayerPosition.x + delta.x, y: touchStartLayerPosition.y + delta.y)
            dragCardsToPosition(position: pos, animate: false)
        }
    }
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if draggingCardLayer != nil {
            if draggingFan == nil {
                
                for i in 0 ..< 4 {
                    if draggingCardLayer!.frame.intersects(foundationLayers[i].frame) {
                        if solitaire.canDropCard(draggingCardLayer!.card, onFoundation: i){
                            solitaire.didDropCard(draggingCardLayer!.card, onFoundation: i)
                            if solitaire.gameWon() {
                                scatterCards()
                            }
                            break
                        }
                    }
                }
                
                for i in 0 ..< 7 {
                    if solitaire.tableau[i].isEmpty {
                        if draggingCardLayer!.frame.intersects(tableauLayers[i].frame) {
                            if solitaire.canDropCard(draggingCardLayer!.card, onTableau: i) {
                                solitaire.didDropCard(draggingCardLayer!.card, onTableau: i)
                            }
                        }
                    }else {
                        if let drop = cardToLayerDictionary[solitaire.tableau[i].last!]{
                            if draggingCardLayer!.frame.intersects(drop.frame) {
                                if solitaire.canDropCard(draggingCardLayer!.card, onTableau: i) {
                                    solitaire.didDropCard(draggingCardLayer!.card, onTableau: i)
                                }
                            }
                        }
                    }
                }
                
                layoutSublayers(of: self.layer)
            } else {
                
                for i in 0 ..< 7 {
                    if solitaire.tableau[i].isEmpty {
                        if let f_Layer = cardToLayerDictionary[draggingFan!.first!]{
                            if f_Layer.frame.intersects(tableauLayers[i].frame) {
                                if solitaire.canDropFan(draggingFan!, onTableau: i) {
                                    solitaire.didDropFan(draggingFan!, onTableau: i)
                                }
                            }
                        }
                    }else {
                        if let drop = cardToLayerDictionary[solitaire.tableau[i].last!]{
                            if let f_Layer = cardToLayerDictionary[draggingFan!.first!]{
                                if f_Layer.frame.intersects(drop.frame) {
                                    if solitaire.canDropFan(draggingFan!, onTableau: i) {
                                        solitaire.didDropFan(draggingFan!, onTableau: i)
                                    }
                                }
                            }
                        }
                    }
                }
                
                layoutSublayers(of: self.layer)
            }
            draggingCardLayer = nil
            draggingFan = nil
        }
    }
   
}
