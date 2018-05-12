//
//  playingCardView.swift
//  Animated SET
//
//  Created by Alwin Firmansyah on 5/8/18.
//  Copyright © 2018 Alwin Firmansyah. All rights reserved.
//

import UIKit

class playingCardView: UIView {
    
    var number: Int = 1 { didSet { setNeedsDisplay (); setNeedsLayout() } }
    var cardDesign = cardDesignView() { didSet { setNeedsDisplay(); setNeedsLayout()} }
    var cardDesignCopy = cardDesignView() { didSet { setNeedsDisplay(); setNeedsLayout() } }
    var cardDesignCopy2 = cardDesignView() { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    var isFaceUp: Bool = false { didSet { setNeedsDisplay (); setNeedsLayout() } }
    
    static var gridOfCards = Grid(layout: Grid.Layout.aspectRatio(1.8))
    
    func generateCardDesignWithMultiplier() {
        if isFaceUp {
            
            cardDesign.backgroundColor = UIColor.clear
            cardDesignCopy.backgroundColor = UIColor.clear
            cardDesignCopy2.backgroundColor = UIColor.clear
            
            switch number {
            case 1:
                cardDesign.frame = middleRect
                addSubview(cardDesign)
            case 2:
                cardDesign.frame = leftHalfRect
                cardDesignCopy.frame = rightHalfRect
                addSubview(cardDesign)
                addSubview(cardDesignCopy)
            case 3:
                cardDesign.frame = leftThirdRect
                cardDesignCopy.frame = middleRect
                cardDesignCopy2.frame = rightThirdRect
                addSubview(cardDesign)
                addSubview(cardDesignCopy)
                addSubview(cardDesignCopy2)
            default: print("no number mentioned")
            }
        } 
    }
    
    override func draw(_ rect: CGRect) {
        generateCardDesignWithMultiplier()
        
//
//        if isFaceUp {
//            generateCardDesignWithMultiplier()
//        } else {
//            backgroundColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
//            layer.borderColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
//        }
//        layer.borderWidth = 0.5
    }
}

extension playingCardView {
    //Mark: Card Container Constants Below
    
    private struct RectRatios {
        static let leftThirdRectOffset: CGFloat = 0.2
        static let rightThirdRectOffset: CGFloat = 0.8
        static let leftHalfRectOffset: CGFloat = 0.35
        static let rightHalfRectOffset: CGFloat = 0.65
        
        static let rectWidth: CGFloat = 0.2
        static let rectHeight: CGFloat = 0.4
    }
    
    private var leftThirdRect: CGRect {
        return CGRect(x: (bounds.width * RectRatios.leftThirdRectOffset) - (bounds.width * RectRatios.rectWidth / 2), y: bounds.midY - (bounds.height * RectRatios.rectHeight / 2), width: bounds.width * RectRatios.rectWidth, height: bounds.height * RectRatios.rectHeight)
    }
    
    private var middleRect: CGRect {
        return CGRect(x: bounds.midX - (bounds.width * RectRatios.rectWidth / 2), y: bounds.midY - (bounds.height * RectRatios.rectHeight / 2), width: bounds.width * RectRatios.rectWidth, height: bounds.height * RectRatios.rectHeight)
    }
    
    private var rightThirdRect: CGRect {
        return CGRect(x: (bounds.width * RectRatios.rightThirdRectOffset) - (bounds.width * RectRatios.rectWidth / 2), y: bounds.midY - (bounds.height * RectRatios.rectHeight / 2), width: bounds.width * RectRatios.rectWidth, height: bounds.height * RectRatios.rectHeight)
    }
    
    private var leftHalfRect: CGRect {
        return CGRect(x: (bounds.width * RectRatios.leftHalfRectOffset) - (bounds.width * RectRatios.rectWidth / 2), y: bounds.midY - (bounds.height * RectRatios.rectHeight / 2), width: bounds.width * RectRatios.rectWidth, height: bounds.height * RectRatios.rectHeight)
    }
    
    private var rightHalfRect: CGRect {
        return CGRect(x: (bounds.width * RectRatios.rightHalfRectOffset) - (bounds.width * RectRatios.rectWidth / 2), y: bounds.midY - (bounds.height * RectRatios.rectHeight / 2), width: bounds.width * RectRatios.rectWidth, height: bounds.height * RectRatios.rectHeight)
    }
    
}
