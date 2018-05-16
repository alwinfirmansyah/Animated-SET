//
//  ViewController.swift
//  Concentration
//
//  Created by Alwin Firmansyah on 4/9/18.
//  Copyright © 2018 Alwin Firmansyah. All rights reserved.
//

import UIKit

class ConcentrationViewController: VCLLoggingViewController
{
    override var vclLoggingName: String {
        return "Concentration Game"
    }
    
    private lazy var game = Concentration(numberOfPairsOfCards: numberOfPairsOfCards)
    
    var numberOfPairsOfCards: Int {
            return (cardButtons.count+1) / 2
    }
    
    private(set) var flipCount = 0 {
        didSet {
            flipCountLabel.text = "Flips: \(flipCount)"
        }
    }
    
    @IBOutlet private weak var flipCountLabel: UILabel!
    
    @IBOutlet private weak var scoreLabel: UILabel!
    
    @IBOutlet private var cardButtons: [UIButton]!
    
    @IBAction private func startNewButton(_ sender: UIButton) {
        startNew()
        updateViewFromModel()
        flipCount = 0
    }
 
    @IBAction func touchCard(_ sender: UIButton) {
        flipCount += 1
        if let cardNumber = cardButtons.index(of: sender) {
            game.chooseCard(at: cardNumber)
            updateViewFromModel()
        } else {
            print("chosen card was not in cardButtons")
        }
    }
    
    var theme: String? {
        didSet {
            currentEmojiSet = theme ?? ""
            emoji = [:]
            updateViewFromModel()
        }
    }
    
    lazy var currentEmojiSet: String = ""
    var emoji = [Int:String]()
        
    func startNew() {
        game.totalScore = 0
        game.matchCounter = 0
        game.penaltyCounter = 0
        game.multipleFlippedIndexValues.removeAll()
        
        currentEmojiSet.removeAll()
        currentEmojiSet = theme!
        game.populateCardSet(of: game.chosenCardPairs)
        for index in game.cards.indices {
            game.cards[index].isMatched = false
            game.cards[index].isFaceUp = false
        }
        game.shuffledCards()
    }
    
    private func emoji(for card: ConcentrationCard) -> String {
        if emoji[card.identifier] == nil, currentEmojiSet.count > 0 {
            let stringIndex = currentEmojiSet.index(currentEmojiSet.startIndex, offsetBy: currentEmojiSet.count.arc4random)
            emoji[card.identifier] = String(currentEmojiSet.remove(at: stringIndex))
        }
        return emoji[card.identifier] ?? "?"
    }
    
    func updateViewFromModel(){
        if cardButtons != nil {
            for index in cardButtons.indices {
                let button = cardButtons[index]
                let card = game.cards[index]
                if card.isFaceUp {
                    button.setTitle(emoji (for: card), for: UIControlState.normal)
                    button.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                } else {
                    button.setTitle("", for: UIControlState.normal)
                    button.backgroundColor = card.isMatched ? #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 0) : #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
                }
            }
            game.totalScore = (game.matchPoints * game.matchCounter) + (game.penaltyCounter * game.penaltyPoints)
            scoreLabel.text = "Score: \(game.totalScore)"
        }
    }
}


