//
//  Card.swift
//  Concentration
//
//  Created by Alwin Firmansyah on 4/9/18.
//  Copyright © 2018 Alwin Firmansyah. All rights reserved.
//

import Foundation

struct ConcentrationCard
{
    var isFaceUp = false
    var isMatched = false
    var identifier: Int
    
    init(){
    self.identifier = ConcentrationCard.getUniqueIdentifier()
    }
    
    static var identifierFactory = 0
    
    static func getUniqueIdentifier() -> Int {
        identifierFactory += 1
        return identifierFactory
    }
    
}
