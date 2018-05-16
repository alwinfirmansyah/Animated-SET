//
//  Concentration.swift
//  Concentration
//
//  Created by Alwin Firmansyah on 4/9/18.
//  Copyright © 2018 Alwin Firmansyah. All rights reserved.
//

import Foundation

class Concentration
{
    var cards = [ConcentrationCard]()
    var chosenCardPairs: Int
    
    var indexofOneAndOnlyFaceUpCard: Int? {
        get {
            return cards.indices.filter { cards[$0].isFaceUp }.oneAndOnly
        }
        set {
            for index in cards.indices {
                cards[index].isFaceUp = (index == newValue)
            }
        }
    }
    
    var matchPoints = 2
    var matchCounter = 0
    var penaltyPoints = -1
    var penaltyCounter = 0
    var multipleFlippedIndexValues = [Int]()
    var totalScore = 0
    
    init(numberOfPairsOfCards: Int) {
        chosenCardPairs = numberOfPairsOfCards
        populateCardSet(of: chosenCardPairs)
        shuffledCards()
    }
    
    func populateCardSet(of chosenCardPairs: Int) {
        cards.removeAll()
        for _ in 1...chosenCardPairs {
            let card = ConcentrationCard()
            cards += [card, card]
        }
    }
    
    func chooseCard(at index: Int) {
        if !cards[index].isMatched {
            if let matchIndex = indexofOneAndOnlyFaceUpCard, matchIndex != index {
                //check if cards match
                if cards[matchIndex].identifier == cards[index].identifier {
                    cards[matchIndex].isMatched = true
                    cards[index].isMatched = true
                    matchCounter += 1
                }
                if cards[matchIndex].identifier == cards[index].identifier && multipleFlippedIndexValues.contains(index) {
                    penaltyCounter -= 1
                }
                if multipleFlippedIndexValues.contains(index) {
                    penaltyCounter += 1
                } else {
                    // if index value is not in array of first flipped index values
                    multipleFlippedIndexValues += [index]
                }
                cards[index].isFaceUp = true
            } else {
                // either no cards or 2 cards are face up
                indexofOneAndOnlyFaceUpCard = index
                multipleFlippedIndexValues += [index]
            }
        }
    }
    
    func shuffledCards(){
        var shuffledCards = [ConcentrationCard]()
        for _ in cards {
            shuffledCards.append(cards.remove(at: cards.count.arc4random))
        }
        cards += shuffledCards
    }
}

extension Collection {
    var oneAndOnly: Element? {
        return count == 1 ? first : nil
        
    }
}
