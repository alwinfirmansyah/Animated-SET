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
    var selectedCards = [Card]()
    
    let defaultNumberOfCardsDealt = 12
    let matchPoints = 11, penaltyPoints = -1
    var matchCounter = 0, penaltyCounter = 0, totalScore = 0
    
    func generateInitialDeck() {
        fullSourceDeck = CardDeck()
        
        sourceDeck.removeAll()
        playingCards.removeAll()
        matchedCards.removeAll()
        selectedCards.removeAll()
        
        totalScore = 0
        matchCounter = 0
        penaltyCounter = 0
        
        sourceDeck = fullSourceDeck.shuffleDeck()
        
        for index in 0..<defaultNumberOfCardsDealt {
            if let shuffledDeckIndex = sourceDeck.index(of: sourceDeck[index]){
                playingCards.append(sourceDeck.remove(at: shuffledDeckIndex))
            }
        }
        
    }
    
    func matchingSetLogic(for firstCard: Card, for secondCard: Card, for thirdCard: Card) {
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
