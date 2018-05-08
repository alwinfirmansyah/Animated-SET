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

    @IBOutlet weak var groupOfCards: UIView! {
        didSet {
            game.generateInitialDeck()
            
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
        let newCards = game.shuffledDeck.filter { !game.playingCards.contains($0) && !game.matchedCards.contains($0) }
        
        if newCards.count > 0 {
            for index in 0...2 {
                game.dealtCards.append(newCards[index])
                game.playingCards.append(newCards[index])
                if let shuffledDeckIndex = game.shuffledDeck.index(of: newCards[index]){
                    game.shuffledDeck.remove(at: shuffledDeckIndex)
                }
            }
        }
        updateViewFromModel()
    }
    
    @objc func selectCard(_ sender: UITapGestureRecognizer) {
        if game.playingCards.count > 0 {
            if let tappedView = sender.view {
                print("this works")
                if let cardIndex = groupOfCards.subviews.index(of: tappedView){
                    game.selectCards(at: cardIndex)
                }
            }
            updateViewFromModel()
            game.totalScore = (game.matchPoints * game.matchCounter) + (game.penaltyCounter * game.penaltyPoints)
            scoreLabel.text = "Points: \(game.totalScore)"
        }
    }
    
    @objc func shuffleCard(_ sender: UIRotationGestureRecognizer) {
        switch sender.state {
        case .ended:
            game.shuffleCards()
            updateViewFromModel()
        default: break
        }
    }
    
    @IBAction func dealMore(_ sender: UIButton) {
        swipeDownForMoreCards()
    }
    
    @IBAction func newGame(_ sender: UIButton) {
        game.generateInitialDeck()
        resetCardView()
        updateViewFromModel()
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
    
    func updateViewFromModel() {
        resetCardView()
        
        playingCardView.gridOfCards.frame = groupOfCards.bounds
        playingCardView.gridOfCards.cellCount = game.playingCards.count
        
        for index in game.playingCards.indices {
            let specificCard = playingCardView()
            
            specificCard.number = game.playingCards[index].number.rawValue
            
            specificCard.cardDesign.color = game.playingCards[index].color.rawValue
            specificCard.cardDesignCopy.color = game.playingCards[index].color.rawValue
            specificCard.cardDesignCopy2.color = game.playingCards[index].color.rawValue
            
            specificCard.cardDesign.symbol = game.playingCards[index].symbol.rawValue
            specificCard.cardDesignCopy.symbol = game.playingCards[index].symbol.rawValue
            specificCard.cardDesignCopy2.symbol = game.playingCards[index].symbol.rawValue
            
            specificCard.cardDesign.shading = game.playingCards[index].shading.rawValue
            specificCard.cardDesignCopy.shading = game.playingCards[index].shading.rawValue
            specificCard.cardDesignCopy2.shading = game.playingCards[index].shading.rawValue
            
            if let cardGridCell = playingCardView.gridOfCards[index] {
                let cardFrame = cardGridCell.insetBy(dx: 1.0, dy: 1.0)
                specificCard.frame = cardFrame
                specificCard.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                specificCard.layer.borderColor = #colorLiteral(red: 0.9060194547, green: 0.9060194547, blue: 0.9060194547, alpha: 1)
                specificCard.layer.borderWidth = 0.5
            }
            if game.selectedCards.contains(game.playingCards[index]) {
                specificCard.backgroundColor = #colorLiteral(red: 0.9067332872, green: 0.9067332872, blue: 0.9067332872, alpha: 1)
            }
            if game.matchedCards.contains(game.playingCards[index]) {
                specificCard.backgroundColor = #colorLiteral(red: 0.785152839, green: 0.9719939011, blue: 0.9567258977, alpha: 1)
            }
            groupOfCards.addSubview(specificCard)
        }
        
        for subviews in groupOfCards.subviews {
            let tap = UITapGestureRecognizer(target: self, action: #selector(selectCard(_:)))
            subviews.addGestureRecognizer(tap)
        }
    }
}

