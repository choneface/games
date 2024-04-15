//
//  SKColumn.swift
//  Games
//
//  Created by Gavin Garcia on 4/14/24.
//

import Foundation
import SpriteKit

class SKColumn : SKShapeNode, Sequence {
    // vars for linked list behavior
    private var head : SKCard?
    private var tail : SKCard?
    
    // vars for rendering behavior
    private var nextPosition: CGPoint = CGPoint(x: 0, y: 0)
    
    // Add value to the end of the list
    func append(card: SKCard) {
        // linked list append
        if let tailNode = tail {
            tailNode.nextCard = card
        } else {
            head = card
        }
        tail = card
        
        // rendering append
        calcNextCardPosition(card: card)
        card.position = nextPosition
        self.addChild(card)
    }

    // Remove all nodes
    func removeAll() {
        head = nil
        tail = nil
    }

    // Print all nodes
    func printList() {
        var currentCard = head
        while let card = currentCard {
            card.printSelf()
            currentCard = card.nextCard
        }
    }
    
    func calcNextCardPosition(card: SKCard){
        if(nextPosition.y == 0) {
            nextPosition.y = (self.frame.height / 2) - (card.height / 2)
        } else {
            nextPosition.y -= (card.height / 5)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            var top : SKCard?
            for card in self {
                if card.contains(location) == true {
                    top = card
                }
            }
            top?.tap()
        }
    }
    
    func makeIterator() -> SKColumnIterator<SKCard> {
        return SKColumnIterator(current: head)
    }
}

class SKColumnIterator<T>: IteratorProtocol {
    var current: SKCard?

    init(current: SKCard?) {
        self.current = current
    }

    func next() -> SKCard? {
        defer { current = current?.nextCard }
        return current
    }
}
