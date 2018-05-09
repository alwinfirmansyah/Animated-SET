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
    
    lazy var game = SetGame()
    
    func generateInitialDeck() {
        game.fullSourceDeck = CardDeck()
        playingCardView.gridOfCards.frame = groupOfCards.bounds
        
        groupOfPlayingCardViews.removeAll()
        game.sourceDeck.removeAll()
        game.playingCards.removeAll()
        game.selectedCards.removeAll()
        game.matchedCards.removeAll()
        
        game.totalScore = 0
        game.matchCounter = 0
        game.penaltyCounter = 0
        
        game.sourceDeck = game.fullSourceDeck.shuffleDeck()
        
        for index in 0..<game.defaultNumberOfCardsDealt {
            if let shuffledDeckIndex = game.sourceDeck.index(of: game.sourceDeck[index]){
                game.playingCards.append(game.sourceDeck.remove(at: shuffledDeckIndex))
                groupOfPlayingCardViews.append(playingCardView())
            }
        }
        
        for index in game.playingCards.indices {
            updateViewFromModel(for: index)
        }
    }
    
    var groupOfPlayingCardViews = [playingCardView]() {
        didSet {
            resetCardView()
            
            for view in groupOfPlayingCardViews {
                groupOfCards.addSubview(view)
            }
        }
    }
    
    @IBOutlet weak var groupOfCards: UIView! {
        didSet {
            generateInitialDeck()
            
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownForMoreCards))
            swipeDown.direction = .down
            groupOfCards.addGestureRecognizer(swipeDown)
            
//            let rotate = UIRotationGestureRecognizer(target: self, action: #selector(shuffleCard(_:)))
//            rotate.rotation = CGFloat.pi
//            groupOfCards.addGestureRecognizer(rotate)
        }
    }
    
    @objc func swipeDownForMoreCards() {
        let newCards = game.sourceDeck.filter { !game.playingCards.contains($0) && !game.matchedCards.contains($0) }
        
        if newCards.count > 0 {
            for index in 0...2 {
                game.playingCards.append(newCards[index])
                groupOfPlayingCardViews.append(playingCardView())
                if let shuffledDeckIndex = game.sourceDeck.index(of: newCards[index]){
                    game.sourceDeck.remove(at: shuffledDeckIndex)
                }
            }
        }
        
        for index in game.playingCards.indices {
            updateViewFromModel(for: index)
        }
    }
    
    @objc func selectCard(_ recognizer: UITapGestureRecognizer) {
        if game.playingCards.count > 0 {
            if let tappedView = recognizer.view as? playingCardView {
                if let cardIndex = groupOfPlayingCardViews.index(of: tappedView){
                    if !game.matchedCards.contains(game.playingCards[cardIndex]) {
                        cardSelectionLogic(at: cardIndex)
                    }
                }
            }
        }
        for index in game.playingCards.indices {
            updateViewFromModel(for: index)
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
            for card in game.selectedCards {
                game.matchedCards.append(card)
            }
//            game.matchingSetLogic(for: game.playingCards[selectedCardIndices[0]], for: game.playingCards[selectedCardIndices[1]], for: game.playingCards[selectedCardIndices[2]])
        }
        
        if selectedCardCount > 3 {
            selectedCardCount = 1
            game.selectedCards.removeAll()
            game.selectedCards.append(game.playingCards[index])
            replaceMatchingCards()
        }
    }
    
//    @objc func shuffleCard(_ sender: UIRotationGestureRecognizer) {
//        switch sender.state {
//        case .ended:
//            game.shufflePlayingCards()
//            updateViewFromModel()
//        default: break
//        }
//    }
    
    @IBAction func dealMore(_ sender: UIButton) {
        swipeDownForMoreCards()
    }
    
    @IBAction func newGame(_ sender: UIButton) {
        resetCardView()
        generateInitialDeck()
        selectedCardCount = 0
        layoutAnimationDelayIncrement = 0
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
                    groupOfPlayingCardViews.remove(at: indexOfMatchedCardInPlayingCards)
                    
                    game.playingCards.insert(newCard, at: indexOfMatchedCardInPlayingCards)
                    groupOfPlayingCardViews.insert(playingCardView(), at: indexOfMatchedCardInPlayingCards)
                    
                    game.sourceDeck.removeFirst()
                } else {
                    game.playingCards.remove(at: indexOfMatchedCardInPlayingCards)
                    groupOfPlayingCardViews.remove(at: indexOfMatchedCardInPlayingCards)
                }
            }
        }
    }
    
    var layoutAnimationDelayIncrement: Double = 0.0
    
    func updateViewFromModel(for index: Int) {
        playingCardView.gridOfCards.cellCount = game.playingCards.count

        let specificCard = groupOfPlayingCardViews[index]
        
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
        
        if let cardGridCell = playingCardView.gridOfCards[index] {
            let cardFrame = cardGridCell.insetBy(dx: 1.0, dy: 1.0)
            // need to add placeholder frame for each subview (bounds of the deck of cards)
            
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.6,
                delay: layoutAnimationDelayIncrement,
                options: UIViewAnimationOptions.curveEaseInOut,
                animations: { specificCard.frame =  cardFrame }
                //                        completion: { subviews.frame = cardFrame }
            )
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectCard(_:)))
        specificCard.addGestureRecognizer(tap)
    }
}

