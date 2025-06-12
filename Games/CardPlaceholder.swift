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
    let isRed: Bool          // supply from Card.isRed

    var body: some View {
        let height = width * 1.5
        let cornerInset: CGFloat = 4      // distance from the edges

        ZStack(alignment: .topTrailing) {
            // Card face / back
            RoundedRectangle(cornerRadius: 6)
                .fill(faceUp ? Color.white : Color.gray)

            // Rank-and-suit in the corner (only if face-up)
            if faceUp, let label {
                Text(label)
                    .font(.caption2.bold())
                    .foregroundColor(isRed ? .red : .black)
                    .padding(.top, cornerInset)
                    .padding(.trailing, cornerInset)
            }

            // Border
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.black, lineWidth: 1)
        }
        .frame(width: width, height: height)
        .shadow(radius: 2)
    }
}

#Preview {
    VStack(spacing: 10) {
        CardPlaceholder(faceUp: true,  width: 60, label: "7♥", isRed: true)
        CardPlaceholder(faceUp: true,  width: 60, label: "K♣", isRed: false)
        CardPlaceholder(faceUp: false, width: 60, label: nil,   isRed: false)
    }
    .padding()
    .background(Color.green)
}


