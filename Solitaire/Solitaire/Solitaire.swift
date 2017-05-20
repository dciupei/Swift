//
//  Solitaire.swift
//  Solitaire
//
//  Created by David Ciupei on 4/28/17.
//  Copyright © 2017 David Ciupei. All rights reserved.
//

import Foundation

class Solitaire {
    var stock : [Card]
    var waste : [Card]
    var foundation : [[Card]] // Array of 4 card stacks
    var tableau : [[Card]] // Array of 7 card stacks
    fileprivate var faceUpCards : Set<Card>;
    
    init(){
        stock = []
        waste = []
        foundation = [[],[],[],[]]
        tableau = [[],[],[],[],[],[],[]]
        
        faceUpCards = Set()
        freshGame()
    }
   
    
    func freshGame(){
        stock = Card.deck()
        let count = Card.deck().count
        
       //shuffle the cards
        for i in 0 ..< count {
            var rand_Cards = Int(arc4random_uniform(UInt32(count)))
            if rand_Cards == i{
                rand_Cards = Int(arc4random_uniform(UInt32(count)))
            }
            
            swap(&stock[rand_Cards], &stock[i])
        }
    
        waste.removeAll()
        
        for i in 0 ..< foundation.count {
            foundation[i].removeAll()
        }
        
        for i in 0 ..< tableau.count {
            tableau[i].removeAll()
        }
        faceUpCards.removeAll()

        
        for i in 0 ..< 7 {
            for j in 0 ..< i+1 {
                let card : Card = stock.removeLast()
                tableau[i].append(card)
                if j == i {
                    faceUpCards.insert(card)
                }
            }
        }
    }
    
    func gameWon() -> Bool {
        var count = 0
        for i in 0 ..< 7{
            if tableau[i].isEmpty{
                count = count + 1
            }
        }
        if waste.isEmpty && stock.isEmpty{
            count = count + 1
        }
        if count == 8{
            return true
        }
        return false
    }
    
    
    func isCardFaceUp(_ card : Card) -> Bool {
        if faceUpCards.contains(card) {
            return true
        }
        return false
    }
    
    
    func fanBeginningWithCard(_ card : Card) -> [Card]? {
        
        var cards : [Card] = []
        
        for i in 0 ..< 7 {
            for j in 0 ..< tableau[i].count {
                if tableau[i][j] == card {
                    for k in j ..< tableau[i].count {
                        cards.append(tableau[i][k])
                    }
                    break
                }
            }
        }
        
        return cards
    }
    
    func canDropCard(_ card : Card, onFoundation i : Int) -> Bool {
        
        if foundation[i].isEmpty && card.rank == ACE {
            return true
        } else if foundation[i].last?.suit == card.suit && foundation[i].last!.rank == card.rank-1 {
            return true
        }
        
        return false
        
    }

    
    func didDropCard(_ card: Card, onFoundation i : Int) {
        if waste.contains(card) {           // remove from waste
            waste.remove(at: waste.index(of: card)!)
        }
        
        for i in 0 ..< 7 {                  // remove from tableau
            if tableau[i].contains(card) {
                tableau[i].remove(at: tableau[i].index(of: card)!)
                if !tableau[i].isEmpty{
                    faceUpCards.insert(tableau[i].last!)
                }
                break
            }
        }
        
        foundation[i].append(card)
    }
    
    func canDropCard(_ card : Card, onTableau i : Int) -> Bool {
        
        if tableau[i].isEmpty && card.rank == KING{
            return true
        
        } else if !(tableau[i].isEmpty) {
            
            let suit = card.suit
            let t_Suit = tableau[i].last!.suit
            
            if ((suit == .spades || suit == .clubs) && (t_Suit == .diamonds || t_Suit == .hearts))
                || ((suit == .diamonds || suit == .hearts) && (t_Suit == .clubs || t_Suit == .spades)){
                if card.rank == tableau[i].last!.rank-1 {
                    return true
                }
            }
            
    
        }
        return false
    }

    
    func didDropCard(_ card : Card, onTableau i : Int) {
        if waste.contains(card) {       // remove from waste
            waste.remove(at: waste.index(of: card)!)
        }
        
        for i in 0 ..< 4 {              // remove from foundation
            if foundation[i].contains(card) {
                foundation[i].remove(at: foundation[i].index(of: card)!)
            }
        }
        
        for i in 0 ..< 7 {              // remove from tableau
            if tableau[i].contains(card) {
                tableau[i].remove(at: tableau[i].index(of: card)!)
                if !tableau[i].isEmpty {
                    faceUpCards.insert((tableau[i].last!))
                }
                break
            }
        }
        
        tableau[i].append(card)
    }
    
    func canDropFan( _ cards : [Card], onTableau i : Int) -> Bool {
        return self.canDropCard(cards[0], onTableau: i)
    }
    

    
    func didDropFan(_ cards : [Card], onTableau i : Int) {
        
        var previous : Int = 0
        
        for i in 0 ..< 7 {
            if tableau[i].contains(cards.first!) {
                previous = i
            }
        }
        
        for card in cards {
            tableau[previous].remove(at: tableau[previous].index(of: card)!)
            tableau[i].append(card)
        }
        
        if !tableau[previous].isEmpty {
            faceUpCards.insert(tableau[previous].last!)
        }
        
    }
    
    
    func canFlipCard(_ card : Card) -> Bool {
        for i in 0 ..< 7 {
            let card_ = tableau[i].last
            if card_ == card && self.isCardFaceUp(card) == false {
                return true
            }
        }
        return false
    }
    
    func didFlipCard(_ card : Card) {
        faceUpCards.insert(card)
        
    }
    
    
    func canDealCard() -> Bool {
        if stock.isEmpty {
            return false
        }
        return true
    }
    
    
    func didDealCard() {
        let card = stock.last
        stock.removeLast()
        waste.append(card!)
        faceUpCards.insert(card!)
    }


    func collectWasteCardsIntoStock() {
        while !waste.isEmpty {
            let card = waste.last
            waste.removeLast()
            stock.append(card!)
            faceUpCards.remove(card!)
        }
    }
    
}
