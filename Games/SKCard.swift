//
//  Card.swift
//  Games
//
//  Created by Gavin Garcia on 4/13/24.
//

import Foundation
import SpriteKit

class SKCard : SKShapeNode {
    var nextCard: SKCard?
    
    var tapped = false
    var covered = false
    var cardDto : CardDTO?
    var sprite: SKSpriteNode?
    
    func define(cardDto: CardDTO) {
        self.cardDto = cardDto;
        self.sprite = SKSpriteNode(imageNamed: getCardImageName(cardDto: cardDto))
        self.sprite?.size = self.frame.size
        
        self.fillColor = cardDto.color
        self.strokeColor = SKColor.yellow
        self.lineWidth = 0
        self.addChild(self.sprite!)
    }
    
    func move(location : CGPoint) {
        self.position = location
    }
    
    func tap(){
        if(tapped){
            self.lineWidth = 0
        } else {
            self.lineWidth = 5
        }
        tapped = !tapped 
    }
    
    private func getCardImageName(cardDto: CardDTO) -> String {
        if cardDto.suit == .none {
            return "card back side"
        }
        
        var num = ""
        switch cardDto.number {
        case 1:
            num = "A"
            break
        case 11:
            num = "J"
            break
        case 12:
            num = "K"
            break
        default:
            num = String(cardDto.number)
        }
        
        return num + " " + cardDto.suit.rawValue
    }
    
    func printSelf() {
        let number = cardDto?.number ?? 0
        let suit = cardDto?.suit ?? .none
        let tappedStatus = tapped ? "true" : "false"
        let coveredStatus = covered ? "true" : "false"
        let hasNext = next != nil ? "true" : "false"
        print("\(number) of \(suit.rawValue) (tapped: \(tappedStatus), covered: \(coveredStatus), hasNext: \(hasNext))")
    }
}

enum Suit: String {
    case none = "none"
    case hearts = "heart"
    case diamonds = "diamond"
    case clubs = "clubs"
    case spades = "spade"
}

struct CardDTO {
    var suit: Suit = .none
    var color: SKColor = .blue
    var number: Int = -1
}
