//
//  ViewController.swift
//  Animated SET
//
//  Created by Alwin Firmansyah on 5/8/18.
//  Copyright © 2018 Alwin Firmansyah. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        updateViewFromModel()
    }
    
    lazy var game = SetGame()
    
    func generateInitialDeck() {
        game.fullSourceDeck = CardDeck()
        
        game.sourceDeck.removeAll()
        game.playingCards.removeAll()
        game.matchedCards.removeAll()
        game.selectedCards.removeAll()
        
        game.totalScore = 0
        game.matchCounter = 0
        game.penaltyCounter = 0
        
        game.sourceDeck = game.fullSourceDeck.shuffleDeck()
        
        for index in 0..<game.defaultNumberOfCardsDealt {
            if let shuffledDeckIndex = game.sourceDeck.index(of: game.sourceDeck[index]){
                game.playingCards.append(game.sourceDeck.remove(at: shuffledDeckIndex))
            }
        }
    }
    
    @IBOutlet weak var groupOfCards: UIView! {
        didSet {
            generateInitialDeck()
            updateViewFromModel()
            
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownForMoreCards))
            swipeDown.direction = .down
            groupOfCards.addGestureRecognizer(swipeDown)
            
            let rotate = UIRotationGestureRecognizer(target: self, action: #selector(shuffleCard(_:)))
            rotate.rotation = CGFloat.pi
            groupOfCards.addGestureRecognizer(rotate)
        }
    }
    
    @objc func swipeDownForMoreCards() {
        let newCards = game.sourceDeck.filter { !game.playingCards.contains($0) && !game.matchedCards.contains($0) }
        
        if newCards.count > 0 {
            for index in 0...2 {
                game.playingCards.append(newCards[index])
                if let shuffledDeckIndex = game.sourceDeck.index(of: newCards[index]){
                    game.sourceDeck.remove(at: shuffledDeckIndex)
                }
            }
        }
        updateViewFromModel()
    }
    
    @objc func selectCard(_ recognizer: UITapGestureRecognizer) {
        if game.playingCards.count > 0 {
            if let tappedView = recognizer.view {
                if let cardIndex = groupOfCards.subviews.index(of: tappedView){
                    if !game.matchedCards.contains(game.playingCards[cardIndex]) {
                        cardSelectionLogic(at: cardIndex)
                    } else {
                        replaceMatchingCards()
                    }
                }
            }
            updateViewFromModel()
            game.totalScore = (game.matchPoints * game.matchCounter) + (game.penaltyCounter * game.penaltyPoints)
            scoreLabel.text = "Points: \(game.totalScore)"
        }
    }
    
    var selectedCardCount = 0

    func cardSelectionLogic(at index: Int) {
        selectedCardCount += 1
        
        if game.selectedCards.count < 3 {
            if game.selectedCards.contains(game.playingCards[index]) {
                if let indexInSelectedCards = game.selectedCards.index(of: game.playingCards[index]){
                    game.selectedCards.remove(at: indexInSelectedCards)
                    selectedCardCount -= 2
                }
            } else {
                game.selectedCards.append(game.playingCards[index])
            }
        }
        
        if selectedCardCount == 3 {
//            for selectedCard in game.selectedCards {
//                game.matchedCards.append(selectedCard)
//            }
            game.matchingSetLogic(for: game.selectedCards[0], for: game.selectedCards[1], for: game.selectedCards[2])
        }
        
        if selectedCardCount > 3 {
            selectedCardCount = 1
            game.selectedCards.removeAll()
            game.selectedCards.append(game.playingCards[index])
            replaceMatchingCards()
        }
    }
    
    @objc func shuffleCard(_ sender: UIRotationGestureRecognizer) {
        switch sender.state {
        case .ended:
            game.shufflePlayingCards()
            updateViewFromModel()
        default: break
        }
    }
    
    @IBAction func dealMore(_ sender: UIButton) {
        swipeDownForMoreCards()
    }
    
    @IBAction func newGame(_ sender: UIButton) {
        generateInitialDeck()
        resetCardView()
        updateViewFromModel()
        selectedCardCount = 0
        scoreLabel.text = "Points: \(game.totalScore)"
    }
    
    @IBOutlet weak var scoreLabel: UILabel! {
        didSet { scoreLabel.text = "Points: \(game.totalScore)" }
    }
    
    func resetCardView() {
        for subview in groupOfCards.subviews {
            subview.removeFromSuperview()
        }
    }
    
    func replaceMatchingCards() {
        for card in game.matchedCards {
            if let indexOfMatchedCardInShuffledDeck = game.sourceDeck.index(of: card) {
                game.sourceDeck.remove(at: indexOfMatchedCardInShuffledDeck)
            }
            
            if let indexOfMatchedCardInPlayingCards = game.playingCards.index(of: card) {
                if let newCard = game.sourceDeck.first {
                    game.playingCards.remove(at: indexOfMatchedCardInPlayingCards)
                    game.playingCards.insert(newCard, at: indexOfMatchedCardInPlayingCards)
                    game.sourceDeck.removeFirst()
                } else {
                    game.playingCards.remove(at: indexOfMatchedCardInPlayingCards)
                }
            }
        }
    }
    
    func updateViewFromModel() {
        resetCardView()
        
        for index in game.playingCards.indices {
            let specificCard = playingCardView()
            groupOfCards.addSubview(specificCard)
            
            // .number represents the number of symbols per card
            specificCard.number = game.playingCards[index].number.rawValue
            
            let cardDesignCopies = [specificCard.cardDesign, specificCard.cardDesignCopy, specificCard.cardDesignCopy2]
            
            // for loop below assigns all the design copies with the appropriate properties from the model
            for designCopies in cardDesignCopies {
                designCopies.color = game.playingCards[index].color.rawValue
                designCopies.symbol = game.playingCards[index].symbol.rawValue
                designCopies.shading = game.playingCards[index].shading.rawValue
            }
            
            specificCard.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            specificCard.layer.borderColor = #colorLiteral(red: 0.9060194547, green: 0.9060194547, blue: 0.9060194547, alpha: 1)
            specificCard.layer.borderWidth = 0.5
            
            if game.selectedCards.contains(game.playingCards[index]) {
                specificCard.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                specificCard.layer.borderWidth = 2.0
            }
            if game.matchedCards.contains(game.playingCards[index]) {
                specificCard.layer.borderColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
                specificCard.layer.borderWidth = 2.0
            }
        }
        
        playingCardView.gridOfCards.frame = groupOfCards.bounds
        playingCardView.gridOfCards.cellCount = groupOfCards.subviews.count
        
        for subviews in groupOfCards.subviews {
            if let indexOfSubview = groupOfCards.subviews.index(of: subviews) {
                if let cardGridCell = playingCardView.gridOfCards[indexOfSubview] {
                    let cardFrame = cardGridCell.insetBy(dx: 1.0, dy: 1.0)
                    subviews.frame = cardFrame
                }
            }
            let tap = UITapGestureRecognizer(target: self, action: #selector(selectCard(_:)))
            subviews.addGestureRecognizer(tap)
        }
    }
}

