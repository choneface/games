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
    
    func define(cardDto: CardDTO) {
        self.cardDto = cardDto;
        
        self.fillColor = cardDto.color
        self.strokeColor = SKColor.yellow
        self.lineWidth = 0
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
    case hearts = "Hearts"
    case diamonds = "Diamonds"
    case clubs = "Clubs"
    case spades = "Spades"
}

struct CardDTO {
    var suit: Suit = .none
    var color: SKColor = .blue
    var number: Int = -1
}
