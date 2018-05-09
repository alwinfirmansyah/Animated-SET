//
//  SetGame.swift
//  Animated SET
//
//  Created by Alwin Firmansyah on 5/8/18.
//  Copyright © 2018 Alwin Firmansyah. All rights reserved.
//

import Foundation

class SetGame {
    var fullSourceDeck = CardDeck()
    
    var sourceDeck = [Card]()
    var playingCards = [Card]()
    var matchedCards = [Card]()
    
    let defaultNumberOfCardsDealt = 12
    let matchPoints = 10, penaltyPoints = -15
    var matchCounter = 0, penaltyCounter = 0, totalScore = 0
    
    func matchingSetLogic(for firstCard: Card, for secondCard: Card, for thirdCard: Card) {
        penaltyCounter += 1
        let cardArray = [firstCard, secondCard, thirdCard]
        
        let numberSet: Set = [firstCard.number, secondCard.number, thirdCard.number]
        let symbolSet: Set = [firstCard.symbol, secondCard.symbol, thirdCard.symbol]
        let shadingSet: Set = [firstCard.shading, secondCard.shading, thirdCard.shading]
        let colorSet: Set = [firstCard.color, secondCard.color, thirdCard.color]
        
        if numberSet.count == 3 || numberSet.count == 1 {
            if symbolSet.count == 3 || symbolSet.count == 1 {
                if shadingSet.count == 3 || shadingSet.count == 1 {
                    if colorSet.count == 3 || colorSet.count == 1 {
                        for card in cardArray {
                            matchedCards.append(card)
                        }
                        matchCounter += 1
                        penaltyCounter -= 1
                    }
                }
            }
        }
    }
    
    func shufflePlayingCards() {
        var shuffledDeck = [Card]()
        for _ in playingCards.indices {
            let shuffledIndex = playingCards.count.arc4random
            shuffledDeck.append(playingCards.remove(at: shuffledIndex))
        }
        playingCards += shuffledDeck
    }
}
