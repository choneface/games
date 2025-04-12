//
//  ContentView.swift
//  Games
//
//  Created by Gavin Garcia on 4/12/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: GameView()) {
                    Text("Solitaire")
                }
                // Add more games here later
            }
            .navigationTitle("Games")
        }
    }
}

#Preview {
    ContentView()
}
