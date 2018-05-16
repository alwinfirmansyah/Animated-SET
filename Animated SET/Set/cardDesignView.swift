//
//  cardDesignView.swift
//  Animated SET
//
//  Created by Alwin Firmansyah on 5/8/18.
//  Copyright © 2018 Alwin Firmansyah. All rights reserved.
//

import UIKit

class cardDesignView: UIView {
    // default variables for a specific card
    var color: String = "red" { didSet { setNeedsDisplay(); setNeedsLayout() } }
    var symbol: String = "diamond" { didSet { setNeedsDisplay(); setNeedsLayout() } }
    var shading: String = "striped" { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    // neeed to do isSelected and isMatched design implementation
    var isSelected: Bool = false { didSet { setNeedsDisplay() } }
    var isMatched: Bool = false { didSet { setNeedsDisplay() } }
    
    func drawSquiggle() -> UIBezierPath {
        // draw and return plain squiggle
        let squigglePath = UIBezierPath()
        squigglePath.move(to: squiggleStartPoint)
        squigglePath.addCurve(to: squiggleEndPoint, controlPoint1: squiggleStartControlPoint1, controlPoint2: squiggleEndControlPoint1)
        squigglePath.addCurve(to: squiggleStartPoint, controlPoint1: squiggleEndControlPoint2, controlPoint2: squiggleStartControlPoint2)
        squigglePath.lineWidth = generalSizeRatios.lineWidth
        squigglePath.addClip()
        return squigglePath
    }
    
    func drawOval() -> UIBezierPath {
        // draw and return plain oval
        let ovalPath = UIBezierPath(ovalIn: ovalRect)
        ovalPath.lineWidth = generalSizeRatios.lineWidth
        ovalPath.addClip()
        return ovalPath
    }
    
    func drawDiamond() -> UIBezierPath {
        // draw and return plain diamond
        let diamondPath = UIBezierPath()
        diamondPath.move(to: diamondLeftOffset)
        diamondPath.addLine(to: diamondTopOffset)
        diamondPath.addLine(to: diamondRightOffset)
        diamondPath.addLine(to: diamondBottomOffset)
        diamondPath.close()
        diamondPath.lineWidth = generalSizeRatios.lineWidth
        diamondPath.addClip()
        return diamondPath
    }
    
    func generateCardDesignWithoutMultiplier() {
        var cardDesign: UIBezierPath
        
        switch symbol {
        case "squiggle":
            cardDesign = drawSquiggle()
        case "oval":
            cardDesign = drawOval()
        case "diamond":
            cardDesign = drawDiamond()
        default:
            cardDesign = drawDiamond()
        }
        
        switch shading {
        case "striped":
            let arrayOfPoints = generateArrayOfStripePoints()
            for stripeNumber in 0..<stripeSizeRatio.numberOfStripes {
                cardDesign.move(to: arrayOfPoints.0[stripeNumber])
                cardDesign.addLine(to: arrayOfPoints.1[stripeNumber])
            }
            cardDesign.lineWidth = generalSizeRatios.lineWidth / 2
            switch color {
            case "red": UIColor.red.setStroke()
            case "green": UIColor.green.setStroke()
            case "purple": UIColor.purple.setStroke()
            default: UIColor.white.setStroke()
            }
            cardDesign.stroke()
        case "solid":
            switch color {
            case "red": UIColor.red.setFill()
            case "green": UIColor.green.setFill()
            case "purple": UIColor.purple.setFill()
            default: UIColor.white.setFill()
            }
            cardDesign.fill()
        case "open":
            switch color {
            case "red": UIColor.red.setStroke()
            case "green": UIColor.green.setStroke()
            case "purple": UIColor.purple.setStroke()
            default: UIColor.white.setStroke()
            }
            cardDesign.stroke()
        default:
            break
        }
    }
    
    override func draw(_ rect: CGRect) {
        generateCardDesignWithoutMultiplier()
    }
    
}

extension cardDesignView {
    //MARK: Diamond Constants Below
    private struct generalSizeRatios {
        static let lineWidth: CGFloat = 1.0
    }
    
    private struct DiamondSizeRatio {
        static let leftOffsetFromBounds: CGFloat = 0.1
        static let rightOffsetFromBounds: CGFloat = 0.9
        static let topOffsetFromBounds: CGFloat = 0.1
        static let bottomOffsetFromBounds: CGFloat = 0.9
    }
    
    
    private var diamondRightOffset: CGPoint {
        return CGPoint(x: bounds.width * DiamondSizeRatio.rightOffsetFromBounds , y: bounds.midY)
    }
    
    private var diamondLeftOffset: CGPoint {
        return CGPoint(x: bounds.width * DiamondSizeRatio.leftOffsetFromBounds , y: bounds.midY)
    }
    
    private var diamondTopOffset: CGPoint {
        return CGPoint(x: bounds.midX , y: bounds.height * DiamondSizeRatio.topOffsetFromBounds)
    }
    
    private var diamondBottomOffset: CGPoint {
        return CGPoint(x: bounds.midX , y: bounds.height * DiamondSizeRatio.bottomOffsetFromBounds)
    }
    
    //MARK: Oval Constants Below
    private struct OvalSizeRatio {
        static let ovalWidthRatio: CGFloat = 0.8
        static let ovalHeightRatio: CGFloat = 0.8
    }
    
    private var ovalRect: CGRect {
        return CGRect(x: bounds.midX - (bounds.width * OvalSizeRatio.ovalWidthRatio / 2), y: bounds.midY - (bounds.height * OvalSizeRatio.ovalHeightRatio / 2), width: bounds.width * OvalSizeRatio.ovalWidthRatio, height: bounds.height * OvalSizeRatio.ovalHeightRatio)
    }
    
    //MARK: Squiggle Constants Below
    private struct SquiggleSizeRatio {
        static let leftOffsetFromBounds: CGFloat = 0.0
        static let rightOffsetFromBounds: CGFloat = 1.0
        static let topOffsetFromBounds: CGFloat = 0.1
        static let bottomOffsetFromBounds: CGFloat = 0.9
        
        static let topRightControlVerticalOffset: CGFloat = 0.5
        static let bottomRightControlVerticalOffset: CGFloat = 0.5
        
        static let topLeftControlVertictalOffset: CGFloat = 0.5
        static let bottomLeftControlVerticalOffset: CGFloat = 0.7
    }
    
    private var squiggleStartPoint: CGPoint {
        return CGPoint(x: bounds.width * SquiggleSizeRatio.leftOffsetFromBounds, y: bounds.height * SquiggleSizeRatio.topOffsetFromBounds)
    }
    
    private var squiggleEndPoint: CGPoint {
        return CGPoint(x: bounds.width * SquiggleSizeRatio.rightOffsetFromBounds, y: bounds.height * SquiggleSizeRatio.bottomOffsetFromBounds)
    }
    
    private var squiggleStartControlPoint1: CGPoint {
        return CGPoint(x: bounds.width * SquiggleSizeRatio.rightOffsetFromBounds, y: bounds.height * SquiggleSizeRatio.topRightControlVerticalOffset)
    }
    
    private var squiggleEndControlPoint1: CGPoint {
        return CGPoint(x: bounds.width * SquiggleSizeRatio.leftOffsetFromBounds, y: bounds.height * SquiggleSizeRatio.topLeftControlVertictalOffset)
    }
    
    private var squiggleStartControlPoint2: CGPoint {
        return CGPoint(x: bounds.width * SquiggleSizeRatio.rightOffsetFromBounds/2, y: bounds.height * SquiggleSizeRatio.bottomRightControlVerticalOffset)
    }
    
    private var squiggleEndControlPoint2: CGPoint {
        return CGPoint(x: bounds.width * SquiggleSizeRatio.leftOffsetFromBounds/2, y: bounds.height * SquiggleSizeRatio.bottomLeftControlVerticalOffset)
    }
    
    //Mark: Striping constants below
    private struct stripeSizeRatio {
        static let interval: CGFloat = 0.2
        static let numberOfStripes: Int = 10
    }
    
    private var xOffsetInterval: CGFloat {
        return stripeSizeRatio.interval * bounds.width
    }
    
    private var yOffsetInterval: CGFloat {
        return stripeSizeRatio.interval * bounds.height
    }
    
    private func generateArrayOfStripePoints() -> ([CGPoint],[CGPoint]) {
        var arrayOfHorizontalPoints = [CGPoint]()
        var arrayOfVerticalPoints = [CGPoint]()
        for interval in 1...stripeSizeRatio.numberOfStripes {
            let xPoint = CGPoint(x: xOffsetInterval*CGFloat(interval), y: bounds.minY)
            let yPoint = CGPoint(x: bounds.minX, y: yOffsetInterval*CGFloat(interval))
            
            arrayOfHorizontalPoints.append(xPoint)
            arrayOfVerticalPoints.append(yPoint)
        }
        return (arrayOfHorizontalPoints, arrayOfVerticalPoints)
    }
    
}

