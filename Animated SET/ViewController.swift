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
//        for index in game.playingCards.indices {
//            cardDealingAnimationDelays.append(0)
//            if index > 0 {
//                cardDealingAnimationDelays[index] = cardDealingAnimationDelays[index-1] + 0.4
//            }
//        }
//        updateViewFromModel()
    }
    
    lazy var game = SetGame()
    
    lazy var animator = UIDynamicAnimator(referenceView: groupOfCards)
    lazy var cardBehavior = CardBehavior(in: animator)
    
    lazy var collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(behavior)
        return behavior
    }()
    
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
                groupOfPlayingCardViews[index].backgroundColor = DesignConstants.faceDownCardBackgroundColor
                groupOfPlayingCardViews[index].alpha = 0
            }
            cardDealingAnimationDelays.append(0)
            if index > 0 {
                cardDealingAnimationDelays[index] = cardDealingAnimationDelays[index-1] + 0.3
            }
        }
        updateViewFromModel()
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
                groupOfPlayingCardViews.last?.frame = cardFrameBeforeBeingAdded
                groupOfPlayingCardViews.last?.backgroundColor = DesignConstants.faceDownCardBackgroundColor
                groupOfPlayingCardViews.last?.alpha = 0
                if let shuffledDeckIndex = game.sourceDeck.index(of: newCards[index]){
                    game.sourceDeck.remove(at: shuffledDeckIndex)
                }
            }
        }
        for index in game.playingCards.indices {
            cardDealingAnimationDelays.append(0)
            if index == game.playingCards.count - 3 {
                cardDealingAnimationDelays[index] = 0.6
            } else if index > game.playingCards.count - 3 {
                cardDealingAnimationDelays[index] = cardDealingAnimationDelays[index-1] + 0.3
            }
        }
        updateViewFromModel()
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
            cardDealingAnimationDelays.append(0.0)
            for matchIndex in recentlyReplacedMatchedIndices {
                if index == matchIndex {
                    cardDealingAnimationDelays[index] += 0.3 * animationCounterMultiplier
                    animationCounterMultiplier += 1.0
                }
            }
        }
        updateViewFromModel()
        setCountLabel.text = "SETS: \(game.matchCounter)"
    }
    
    var selectedCardCount = 0
//    var arrayOfCurrentSelectedCardIndices = [Int]()

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
            game.matchCounter += 1
            
//            game.matchingSetLogic(for: game.selectedCards[0], for: game.selectedCards[1], for: game.selectedCards[2])
            replaceMatchingCards()
        }
        
        if selectedCardCount > 3 {
            selectedCardCount = 1
            game.selectedCards.removeAll()
            game.selectedCards.append(game.playingCards[index])
//            replaceMatchingCards()
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
        // need to add other delay increments
        
        setCountLabel.text = "SETS: \(game.matchCounter)"
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
                    recentlyReplacedMatchedCardViews.append(groupOfPlayingCardViews[indexOfMatchedCardInPlayingCards])
                    game.playingCards.remove(at: indexOfMatchedCardInPlayingCards)
                    groupOfPlayingCardViews.remove(at: indexOfMatchedCardInPlayingCards)
                    game.playingCards.insert(newCard, at: indexOfMatchedCardInPlayingCards)
                    groupOfPlayingCardViews.insert(playingCardView(), at: indexOfMatchedCardInPlayingCards)
                    groupOfPlayingCardViews[indexOfMatchedCardInPlayingCards].frame = cardFrameBeforeBeingAdded
                    groupOfPlayingCardViews[indexOfMatchedCardInPlayingCards].backgroundColor = DesignConstants.faceDownCardBackgroundColor
                    groupOfPlayingCardViews[indexOfMatchedCardInPlayingCards].alpha = 0
                    game.sourceDeck.removeFirst()
                    recentlyReplacedMatchedIndices.append(indexOfMatchedCardInPlayingCards)
                } else {
                    recentlyReplacedMatchedCardViews.append(groupOfPlayingCardViews[indexOfMatchedCardInPlayingCards])
                    game.playingCards.remove(at: indexOfMatchedCardInPlayingCards)
                    groupOfPlayingCardViews.remove(at: indexOfMatchedCardInPlayingCards)
                }
            }
        }
    }
    
    var recentlyReplacedMatchedCardViews = [playingCardView]()
    
    // animation adjustments for different situations
    var cardDealingAnimationDelays = [Double]()
    var recentlyReplacedMatchedIndices = [Int]()
    var animationCounterMultiplier: Double = 1.0
    var matchingReturnDelayIncrement: Double = 0.0
    
    func updateViewFromModel() {
     
        playingCardView.gridOfCards.frame = groupOfCards.bounds
        playingCardView.gridOfCards.cellCount = game.playingCards.count
        
        for index in game.playingCards.indices {
            
            let specificCard = groupOfPlayingCardViews[index]
            
            // .number represents the number of symbols per card
            specificCard.number = game.playingCards[index].number.rawValue
            
            let copyOfMatchedCardDesigns = [specificCard.cardDesign, specificCard.cardDesignCopy, specificCard.cardDesignCopy2]
            
            // for loop below assigns all the design copies with the appropriate properties from the model
            for designCopies in copyOfMatchedCardDesigns {
                designCopies.color = game.playingCards[index].color.rawValue
                designCopies.symbol = game.playingCards[index].symbol.rawValue
                designCopies.shading = game.playingCards[index].shading.rawValue
            }
            
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.3,
                delay: 0.1,
                options: UIViewAnimationOptions.transitionCrossDissolve,
                animations: { specificCard.alpha = 1 }
            )
            
            if let cardGridCell = playingCardView.gridOfCards[index] {
                let cardFrame = cardGridCell.insetBy(dx: 1.0, dy: 1.0)
                
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.5,
                    delay: cardDealingAnimationDelays[index],
                    options: UIViewAnimationOptions.curveEaseIn,
                    animations: { specificCard.frame =  cardFrame },
                    completion: { finished in
                        if !specificCard.isFaceUp {
                            specificCard.backgroundColor = DesignConstants.faceUpCardBackgroundColor
                            specificCard.layer.borderColor = DesignConstants.faceUpCardBorderColor
                            specificCard.layer.borderWidth = DesignConstants.faceUpCardBorderWidth
                            
                            UIView.transition(with: specificCard,
                                              duration: 1.0,
                                              options: .transitionFlipFromLeft,
                                              animations: { specificCard.isFaceUp = !specificCard.isFaceUp }
                            )
                        }
                }
                )
            }
            
            if game.selectedCards.contains(game.playingCards[index]) {
                specificCard.layer.borderColor = DesignConstants.selectedCardBorderColor
                specificCard.layer.borderWidth = DesignConstants.selectedCardBorderWidth
            } else {
                specificCard.layer.borderColor = DesignConstants.faceUpCardBorderColor
                specificCard.layer.borderWidth = DesignConstants.faceUpCardBorderWidth
            }
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(selectCard(_:)))
            specificCard.addGestureRecognizer(tap)
        }
        
        for view in recentlyReplacedMatchedCardViews {
            groupOfCards.addSubview(view)
            cardBehavior.addItem(view)
            view.rotate360Degrees()
            view.layer.zPosition = 1
            
            for subview in view.subviews {
                subview.autoresizingMask = [.flexibleTopMargin,.flexibleBottomMargin,.flexibleLeftMargin,.flexibleRightMargin]
            }
            
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.2,
                delay: 1.0,
                options: UIViewAnimationOptions.transitionCrossDissolve,
                animations: { view.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1) },
                completion: { finished in
                    UIView.transition(with: view,
                                      duration: 1.0,
                                      options: UIViewAnimationOptions.transitionCrossDissolve,
                                      animations: { view.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) },
                                      completion: { finished in
                                        self.cardBehavior.removeItem(view)
                                        UIViewPropertyAnimator.runningPropertyAnimator(
                                            withDuration: 1.5,
                                            delay: self.matchingReturnDelayIncrement,
                                            options: UIViewAnimationOptions.curveEaseInOut,
                                            animations: { view.frame = self.cardFrameAfterBeingMatched },
                                            completion: { finished in
                                                UIViewPropertyAnimator.runningPropertyAnimator(
                                                    withDuration: 0.6,
                                                    delay: 0.6,
                                                    options: UIViewAnimationOptions.transitionCrossDissolve,
                                                    animations: { view.alpha = 0 }
                                                )
                                        }
                                        )
                    }
                    )
            }
            )
            matchingReturnDelayIncrement += 0.5
        }
        
        // for clean up after animations
        animationCounterMultiplier = 1.0
        cardDealingAnimationDelays.removeAll()
        recentlyReplacedMatchedIndices.removeAll()
        recentlyReplacedMatchedCardViews.removeAll()
        matchingReturnDelayIncrement = 0
    }
}

extension ViewController {
    private struct DesignConstants {
        static let faceDownCardBackgroundColor: UIColor = #colorLiteral(red: 0.911333541, green: 0.911333541, blue: 0.911333541, alpha: 1)
        static let faceUpCardBackgroundColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        static let faceUpCardBorderColor: CGColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        static let faceUpCardBorderWidth: CGFloat = 0.5
        
        static let selectedCardBorderColor: CGColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        static let selectedCardBorderWidth: CGFloat = 2.0
        
    }
    
    private var cardFrameBeforeBeingAdded: CGRect {
        return CGRect(x: groupOfCards.bounds.minX, y: groupOfCards.bounds.maxY, width: groupOfCards.bounds.width/3, height: 50.0)
    }
    
    private var cardFrameAfterBeingMatched: CGRect {
        return CGRect(x: groupOfCards.bounds.minX + groupOfCards.bounds.width/3, y: groupOfCards.bounds.maxY, width: groupOfCards.bounds.width/3, height: 50.0)
    }
}

extension CGFloat {
    var arc4random: CGFloat {
        return self * (CGFloat(arc4random_uniform(UInt32.max))/CGFloat(UInt32.max))
    }
}

extension UIView {
    func rotate360Degrees(duration: CFTimeInterval = 2.0, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = 4*CGFloat.pi
        rotateAnimation.duration = duration
        
        if let delegate: CAAnimationDelegate = completionDelegate as! CAAnimationDelegate? {
            rotateAnimation.delegate = delegate
        }
        self.layer.add(rotateAnimation, forKey: nil)
    }
}

