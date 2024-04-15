//
//  GameScene.swift
//  Games
//
//  Created by Gavin Garcia on 4/13/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var card: SKCard?
    private var column: SKShapeNode?
    private var columns: [SKShapeNode] = []
    
    override func didMove(to view: SKView) {
        let h = (self.size.height * 0.7)
        let w = (self.size.width + self.size.height) * 0.047
        var x = (-self.size.width / 2) + (w/2)
        for _ in 0...6 {
            // Make column
            let col = SKColumn.init(rectOf: CGSize.init(width: w, height: h), cornerRadius: w * 0.3)
            col.position = CGPoint(
                    x: x,
                    y: (-self.size.height / 2) + (h/2)
                )
            col.lineWidth = 5
            col.strokeColor = SKColor.blue
            
            // Make card
            let cardSize = CGSize.init(width: w, height: w*1.4)
            let cardCornerRadius = w * 0.1
            
            let cdata = CardDTO(suit: Suit.hearts, color: SKColor.red, number: 2)
            let c1data = CardDTO(suit: Suit.spades, color: SKColor.black, number: 2)
            
            let c = SKCard.init(cardDto: cdata, size: cardSize, radius: cardCornerRadius, imageName: getCardImageName(cardDto: cdata))
            let c1 = SKCard.init(cardDto: c1data, size: cardSize, radius: cardCornerRadius, imageName: getCardImageName(cardDto: c1data))
            
            col.append(card: c)
            col.append(card: c1)
            self.addChild(col)
            self.columns.append(col)
            x += w*1.1
        }
        
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            for col in self.columns {
                if col.contains(location) == true {
                    col.touchesBegan(touches, with: event)
                }
            }
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    // in a perfect world, this isn't gere, welcome to hell 
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
}
