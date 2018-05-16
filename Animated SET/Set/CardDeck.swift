//
//  CardDeck.swift
//  Animated SET
//
//  Created by Alwin Firmansyah on 5/8/18.
//  Copyright © 2018 Alwin Firmansyah. All rights reserved.
//

import Foundation

struct CardDeck {
    var cards = [Card]()
    
    init () {
        for number in Card.Number.allNumbers {
            for symbol in Card.Symbol.allSymbols {
                for shading in Card.Shading.allShading {
                    for color in Card.Color.allColor {
                        cards.append(Card(number: number, symbol: symbol, shading: shading, color: color))
                    }
                }
            }
        }
    }
    
    mutating func shuffleDeck() -> [Card] {
        var shuffledDeck = [Card]()
        for _ in cards.indices {
            let shuffledIndex = cards.count.arc4random
            shuffledDeck.append(cards.remove(at: shuffledIndex))
        }
        return shuffledDeck
    }
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}

