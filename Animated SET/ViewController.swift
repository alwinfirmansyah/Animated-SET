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
        for index in game.playingCards.indices {
            updateViewFromModel(for: index)
        }
    }
    
    lazy var game = SetGame()
    
    func generateInitialDeck() {
        game.fullSourceDeck = CardDeck()
        
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
                groupOfPlayingCardViews[index].frame = cardFrameBeforeBeingAdded
                groupOfPlayingCardViews[index].backgroundColor = DesignConstants.cardBackgroundColor
                groupOfPlayingCardViews[index].alpha = 0
            }
        }
        
        for index in game.playingCards.indices {
            dealCardsAnimationDelayIncrement += 0.2
            cardTransparencyDelayIncrement += 0.2
            updateViewFromModel(for: index)
        }
        dealCardsAnimationDelayIncrement = 0
        cardTransparencyDelayIncrement = 0
    }
    
    var groupOfPlayingCardViews = [playingCardView]() {
        didSet {
            resetCardView()

            for view in groupOfPlayingCardViews {
                groupOfCards.addSubview(view)
            }
            
            groupOfCards.layoutIfNeeded()
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
                groupOfPlayingCardViews.last?.frame = cardFrameBeforeBeingAdded
                groupOfPlayingCardViews.last?.backgroundColor = DesignConstants.cardBackgroundColor
                groupOfPlayingCardViews.last?.alpha = 0
                if let shuffledDeckIndex = game.sourceDeck.index(of: newCards[index]){
                    game.sourceDeck.remove(at: shuffledDeckIndex)
                }
            }
        }
        
        // adjusts animation delays for appropriate flow of layout / dealing cards
        for index in game.playingCards.indices {
            if index == game.playingCards.count - 3 {
                dealCardsAnimationDelayIncrement += 0.6
                cardTransparencyDelayIncrement += 0.6
            } else if index > game.playingCards.count - 3 {
                dealCardsAnimationDelayIncrement  = 0.4 * animationCounterMultiplier
                cardTransparencyDelayIncrement  = 0.4 * animationCounterMultiplier
                animationCounterMultiplier += 1.0
//                dealCardsAnimationDelayIncrement += 0.3
//                cardTransparencyDelayIncrement += 0.3
            }
            updateViewFromModel(for: index)
        }
        animationCounterMultiplier = 1.0
        dealCardsAnimationDelayIncrement = 0
        cardTransparencyDelayIncrement = 0
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
        setCountLabel.text = "SETS: \(game.matchCounter)"
    }
    
    var selectedCardCount = 0
    var arrayOfCurrentSelectedCardIndices = [Int]()

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
            updateViewFromModel(for: index)
        }
        
        if selectedCardCount == 3 {
            for card in game.selectedCards {
                game.matchedCards.append(card)
            }
            game.matchCounter += 1
            
//            game.matchingSetLogic(for: game.selectedCards[0], for: game.selectedCards[1], for: game.selectedCards[2])
            for card in game.matchedCards {
                if let indexInPlayingCards = game.playingCards.index(of: card) {
                    updateViewFromModel(for: indexInPlayingCards)
                }
            }
        }
        
        if selectedCardCount > 3 {
            selectedCardCount = 1
            for card in game.selectedCards {
                if let indexInPlayingCards = game.playingCards.index(of: card) {
                    arrayOfCurrentSelectedCardIndices.append(indexInPlayingCards)
                }
            }
            game.selectedCards.removeAll()
            game.selectedCards.append(game.playingCards[index])
            
            for index in arrayOfCurrentSelectedCardIndices {
                updateViewFromModel(for: index)
            }
            arrayOfCurrentSelectedCardIndices.removeAll()
            replaceMatchingCards()
        }
    }
    
//    @objc func shuffleCard(_ sender: UIRotationGestureRecognizer) {
//        switch sender.state {
//        case .ended:
//            game.shufflePlayingCards()
//            for index in game.playingCards.indices {
//                updateViewFromModel(for: index)
//            }
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
        cardTransparencyDelayIncrement = 0
        // need to add other delay increments
    }
    
    @IBOutlet weak var setCountLabel: UILabel! {
        didSet { setCountLabel.text = "SETS: \(game.matchCounter)" }
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
                    groupOfPlayingCardViews[indexOfMatchedCardInPlayingCards].frame = cardFrameBeforeBeingAdded
                    groupOfPlayingCardViews[indexOfMatchedCardInPlayingCards].backgroundColor = DesignConstants.cardBackgroundColor
                    groupOfPlayingCardViews[indexOfMatchedCardInPlayingCards].alpha = 0
                    game.sourceDeck.removeFirst()
                    recentlyReplacedMatchedIndices.append(indexOfMatchedCardInPlayingCards)
                } else {
                    game.playingCards.remove(at: indexOfMatchedCardInPlayingCards)
                    groupOfPlayingCardViews.remove(at: indexOfMatchedCardInPlayingCards)
                }
            }
        }
        
        
        // used for animation adjustments
        for index in game.playingCards.indices {
            dealCardsAnimationDelayIncrement = 0.0
            cardTransparencyDelayIncrement = 0.0
            
            for matchIndex in recentlyReplacedMatchedIndices {
                if index == matchIndex {
                    dealCardsAnimationDelayIncrement += 0.3 * animationCounterMultiplier
                    cardTransparencyDelayIncrement += 0.3 * animationCounterMultiplier
                    animationCounterMultiplier += 1.0
                }
            }
            updateViewFromModel(for: index)
        }
        recentlyReplacedMatchedIndices.removeAll()
        animationCounterMultiplier = 1
    }
    
    var recentlyReplacedMatchedIndices = [Int]()

    // animation adjustments for different situations
    var animationCounterMultiplier: Double = 1.0
    var dealCardsAnimationDelayIncrement: Double = 0.0
    var cardTransparencyDelayIncrement: Double = 0.0
    var matchingAnimationDelayIncrement: Double = 0.0
    
    func updateViewFromModel(for index: Int) {
     
        playingCardView.gridOfCards.frame = groupOfCards.bounds
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
        
//        specificCard.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//        specificCard.layer.borderColor = #colorLiteral(red: 0.9060194547, green: 0.9060194547, blue: 0.9060194547, alpha: 1)
//        specificCard.layer.borderWidth = 0.5

        
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.3,
            delay: cardTransparencyDelayIncrement,
            options: UIViewAnimationOptions.beginFromCurrentState,
            animations: { specificCard.alpha = 1 },
            completion: { finsihed in
                if specificCard.isFaceUp {
                    UIView.transition(with: specificCard,
                                      duration: 5.0,
                                      options: [.transitionFlipFromLeft],
                                      animations: { specificCard.isFaceUp = !specificCard.isFaceUp },
                                      completion: { finished in }
                    )
                }
        }
        )
        
        if game.selectedCards.contains(game.playingCards[index]) {
            specificCard.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            specificCard.layer.borderWidth = 2.0
        }
        if game.matchedCards.contains(game.playingCards[index]) {
//            specificCard.layer.borderColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
//            specificCard.layer.borderWidth = 2.0
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.5,
                delay: matchingAnimationDelayIncrement,
                options: UIViewAnimationOptions.curveEaseInOut,
                animations: { specificCard.alpha = 0 },
                completion: { finsihed in }
            )
        }
        
        if let cardGridCell = playingCardView.gridOfCards[index] {
            let cardFrame = cardGridCell.insetBy(dx: 1.0, dy: 1.0)
            
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.5,
                delay: dealCardsAnimationDelayIncrement,
                options: UIViewAnimationOptions.curveEaseIn,
                animations: { specificCard.frame =  cardFrame },
                completion: { finished in  }
            )
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectCard(_:)))
        specificCard.addGestureRecognizer(tap)
    }
}

extension ViewController {
    private struct DesignConstants {
        static let cardBackgroundColor: UIColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
    }
    
    private var cardFrameBeforeBeingAdded: CGRect {
        return CGRect(x: groupOfCards.bounds.minX, y: groupOfCards.bounds.maxY, width: groupOfCards.bounds.width/4, height: groupOfCards.bounds.height/10)
    }
    
    
}

