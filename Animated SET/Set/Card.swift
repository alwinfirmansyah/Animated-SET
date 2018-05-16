//
//  Card.swift
//  Animated SET
//
//  Created by Alwin Firmansyah on 5/8/18.
//  Copyright © 2018 Alwin Firmansyah. All rights reserved.
//

import Foundation

struct Card: Hashable, Equatable, CustomStringConvertible {
    
    var description: String { return "\(number),\(symbol),\(shading),\(color)" }
    
    enum Number: Int {
        
        case one = 1
        case two = 2
        case three = 3
        
        static var allNumbers = [Number.one,.two,.three]
    }
    
    enum Symbol: String {
        
        case diamond
        case oval
        case squiggle
        
        static var allSymbols = [Symbol.diamond,.oval,.squiggle]
    }
    
    enum Shading: String {
        
        case solid
        case striped
        case open
        
        static var allShading = [Shading.solid,.striped,.open]
    }
    
    enum  Color: String {
        
        case red
        case purple
        case green
        
        static var allColor = [Color.red,.purple,.green]
    }
    
    var number: Number
    var symbol: Symbol
    var shading: Shading
    var color: Color
}

