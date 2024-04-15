//
//  GLinkedList.swift
//  Games
//
//  Created by Gavin Garcia on 4/14/24.
//

import Foundation

class GLinkedList<T>: Sequence {
    var head: GListNode<T>?
    var tail: GListNode<T>?

    // Add value to the end of the list
    func append(value: T) {
        let newNode = GListNode(value: value)
        if let tailNode = tail {
            tailNode.next = newNode
        } else {
            head = newNode
        }
        tail = newNode
    }

    // Remove all nodes
    func removeAll() {
        head = nil
        tail = nil
    }

    // Print all nodes
    func printList() {
        var currentNode = head
        while let node = currentNode {
            print(node.value)
            currentNode = node.next
        }
    }
    
    func makeIterator() -> GLinkedListIterator<T> {
        return GLinkedListIterator(current: head)
    }
}

class GListNode<T> {
    var value: T
    var next: GListNode?

    init(value: T) {
        self.value = value
        self.next = nil
    }
}

class GLinkedListIterator<T>: IteratorProtocol {
    var current: GListNode<T>?

    init(current: GListNode<T>?) {
        self.current = current
    }

    func next() -> T? {
        defer { current = current?.next }
        return current?.value
    }
}

