//
//  MineSweeperWinScreenView.swift
//  Games
//
//  Created by Gavin Garcia on 7/3/25.
//

import SwiftUI


/// Call this view when the game is won.  Provide the final score, moves, and time.
struct MineSweeperWinScreenView: View {
    // MARK: – Inputs
    let bombs: Int
    let cols: Int
    let rows: Int
    let seconds: Int
    let playAgain: () -> Void
    let share: () -> Void

    // MARK: – Helpers
    private var timeString: String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    // MARK: – Body
        var body: some View {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.indigo.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Confetti overlay (Lottie)
                LottieView(name: "confetti", loopMode: .loop)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .blendMode(.plusLighter)

                // Content stack
                VStack(spacing: 32) {
                    Text("You Win!")
                        .font(.system(size: 48, weight: .heavy))
                        .foregroundColor(.white)
                        .shadow(radius: 4)
                        .padding(.top, 80)
                    
                    Spacer(minLength: 120) // big gap where the card fan would have been

                    // Horizontal stats card
                    HStack(spacing: 0) {
                        statColumn(title: "Time",  value: timeString)
                        Divider()
                            .frame(height: 48)
                            .background(Color.black.opacity(0.1))
                        statColumn(title: "Size", value: "\(rows)x\(cols)")
                        Divider()
                            .frame(height: 48)
                            .background(Color.black.opacity(0.1))
                        statColumn(title: "Bombs", value: "\(bombs)")
                    }
                    .padding(.vertical, 15)
                    .frame(maxWidth: 280)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(radius: 3)
                    .padding(.horizontal, 24)

                    // Buttons
                    VStack(spacing: 12) {
                        Button(action: playAgain) {
                            Text("Play Again")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.white)
                                .foregroundColor(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .accessibilityLabel("Play again")

                        Button(action: share) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share")
                            }
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.white.opacity(0.9), lineWidth: 2)
                        )
                        .accessibilityLabel("Share your victory")
                    }
                    .frame(maxWidth: 280)
                }
                .padding(.bottom, 60)
            }
        }

        // MARK: – Private helpers
        private func statColumn(title: String, value: String) -> some View {
            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.6))
                Text(value)
                    .font(.title3.bold())
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: – Preview
    #Preview {
        MineSweeperWinScreenView(bombs: 10, cols: 16, rows: 16, seconds: 135) {
            // Play again tap
        } share: {
            // Share tap
        }
        .previewDevice("iPhone 15 Pro")
    }
