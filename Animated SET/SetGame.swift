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
    
    var shuffledDeck = [Card]()
    var playingCards = [Card]()
    var dealtCards = [Card]()
    var matchedCards = [Card]()
    var selectedCards = [Card]()
    
    let defaultNumberOfCardsDealt = 12
    var selectedCardCount = 0
    let matchPoints = 11, penaltyPoints = -1
    var matchCounter = 0, penaltyCounter = 0, totalScore = 0
    
    func generateInitialDeck() {
        fullSourceDeck = CardDeck()
        
        shuffledDeck.removeAll()
        playingCards.removeAll()
        dealtCards.removeAll()
        matchedCards.removeAll()
        selectedCards.removeAll()
        
        selectedCardCount = 0
        totalScore = 0
        matchCounter = 0
        penaltyCounter = 0
        
        shuffledDeck = fullSourceDeck.shuffleDeck()
        
        for index in 0..<defaultNumberOfCardsDealt {
            if let shuffledDeckIndex = shuffledDeck.index(of: shuffledDeck[index]){
                playingCards.append(shuffledDeck.remove(at: shuffledDeckIndex))
            }
        }
        
        for index in 0..<defaultNumberOfCardsDealt {
            dealtCards.append(playingCards[index])
        }
        
    }
    
    func replaceMatchingCards() {
        for card in matchedCards {
            if let indexOfMatchedCardInDealtCards = dealtCards.index(of: card) {
                dealtCards.remove(at: indexOfMatchedCardInDealtCards)
            }
            
            if let indexOfMatchedCardInShuffledDeck = shuffledDeck.index(of: card) {
                shuffledDeck.remove(at: indexOfMatchedCardInShuffledDeck)
            }
            
            if let indexOfMatchedCardInPlayingCards = playingCards.index(of: card) {
                if let newCard = shuffledDeck.first {
                    dealtCards.append(newCard)
                    playingCards.remove(at: indexOfMatchedCardInPlayingCards)
                    playingCards.insert(newCard, at: indexOfMatchedCardInPlayingCards)
                    shuffledDeck.removeFirst()
                } else {
                    playingCards.remove(at: indexOfMatchedCardInPlayingCards)
                }
            }
        }
    }
    
    func selectCards(at index: Int) {
        penaltyCounter += 1
        selectedCardCount += 1
        
        if selectedCards.count < 3 {
            if selectedCards.contains(playingCards[index]) {
                if let indexInSelectedCards = selectedCards.index(of: playingCards[index]){
                    selectedCards.remove(at: indexInSelectedCards)
                    selectedCardCount -= 2
                }
            } else {
                selectedCards.append(playingCards[index])
            }
        }
        
        if selectedCardCount == 3 {
            //                for selectedCard in selectedCards {
            //                    matchedCards.append(selectedCard)
            //                }
            matchingSetLogic(for: selectedCards[0], for: selectedCards[1], for: selectedCards[2])
        }
        
        if selectedCardCount > 3 {
            replaceMatchingCards()
            selectedCardCount = 1
            selectedCards.removeAll()
            if index > playingCards.count - 1 {
                selectedCards.append(playingCards[index-3])
            } else {
                selectedCards.append(playingCards[index])
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
    
    func shuffleCards() {
        var shuffledDeck = [Card]()
        for _ in playingCards.indices {
            let shuffledIndex = playingCards.count.arc4random
            shuffledDeck.append(playingCards.remove(at: shuffledIndex))
        }
        playingCards += shuffledDeck
    }
}
