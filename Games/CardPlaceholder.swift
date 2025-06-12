//
//  CardPlaceholder.swift
//  Games
//
//  Created by Gavin Garcia on 4/12/25.
//

import SwiftUI

struct CardPlaceholder: View {
    let faceUp: Bool
    let width: CGFloat
    let label: String?

    var body: some View {
        let height = width * 1.5

        RoundedRectangle(cornerRadius: 6)
            .fill(faceUp ? Color.white : Color.gray)
            .frame(width: width, height: height)
            .overlay(
                Group {
                    if faceUp, let label = label {
                        Text(label)
                            .font(.caption)
                            .foregroundColor(.black)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.black, lineWidth: 1)
            )
            .shadow(radius: 2)
    }
}

#Preview {
    VStack(spacing: 10) {
        CardPlaceholder(faceUp: true, width: 60, label: "7♥")
        CardPlaceholder(faceUp: false, width: 60, label: "2♣")
    }
    .padding()
    .background(Color.green)
}

