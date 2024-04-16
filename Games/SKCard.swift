//
//  Card.swift
//  Games
//
//  Created by Gavin Garcia on 4/13/24.
//

import Foundation
import SpriteKit

class SKCard : SKNode {
    var nextCard: SKCard?
    
    var tapped = false
    var covered = false
    var height : CGFloat
    private var cardDto : CardDTO = CardDTO()
    private var card: SKShapeNode
    
    // Initialization with an image
    init(cardDto: CardDTO, size: CGSize, radius: CGFloat, covered: Bool) {
        self.height = size.height
        self.cardDto = cardDto
        self.card = SKShapeNode(rectOf: size, cornerRadius: radius)
        super.init()
        
        let imageName = covered ? "card back side" : getCardImageName(cardDto: cardDto)
        card.fillColor = .white
        card.fillTexture = SKTexture(imageNamed: imageName)
        addChild(card)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func move(location : CGPoint) {
        self.position = location
    }
    
    func tap(){
        if(tapped){
            card.fillColor = .white
        } else {
            card.fillColor = .lightGray
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
            num = "Q"
            break
        case 13:
            num = "K"
            break
        default:
            num = String(cardDto.number)
        }
        
        return num + " " + cardDto.suit.rawValue
    }
    
    func printSelf() {
        let number = cardDto.number
        let suit = cardDto.suit
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
