//
//  OnboardingView.swift
//  dafoma_66
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var animationOffset: CGFloat = 0
    @State private var opacity: Double = 0
    @Binding var showOnboarding: Bool
    
    private let pages = [
        OnboardingPage(
            title: "Track your spending effortlessly",
            subtitle: "Keep track of every expense with simple, intuitive tools",
            icon: "chart.line.uptrend.xyaxis",
            gradient: [Color.finoraPrimary.opacity(0.3), Color.finoraAccent.opacity(0.1)]
        ),
        OnboardingPage(
            title: "Plan your goals and watch them grow",
            subtitle: "Set savings targets and monitor your progress in real-time",
            icon: "target",
            gradient: [Color.finoraAccent.opacity(0.3), Color.finoraPrimary.opacity(0.1)]
        ),
        OnboardingPage(
            title: "Stay on top of your finances",
            subtitle: "Simply and beautifully manage your money with Finora",
            icon: "leaf.fill",
            gradient: [Color.finoraPrimary.opacity(0.4), Color.finoraAccent.opacity(0.2)]
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Animated background
                LinearGradient(
                    gradient: Gradient(colors: pages[currentPage].gradient),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.8), value: currentPage)
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Content area
                    VStack(spacing: 40) {
                        // Icon with animation
                        Image(systemName: pages[currentPage].icon)
                            .font(.system(size: 80, weight: .light))
                            .foregroundColor(.finoraPrimary)
                            .scaleEffect(opacity)
                            .animation(.spring(response: 0.8, dampingFraction: 0.6), value: opacity)
                        
                        // Text content
                        VStack(spacing: 16) {
                            Text(pages[currentPage].title)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .opacity(opacity)
                                .offset(x: animationOffset)
                            
                            Text(pages[currentPage].subtitle)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                                .opacity(opacity)
                                .offset(x: animationOffset)
                        }
                    }
                    .frame(maxWidth: min(geometry.size.width - 64, 400))
                    
                    Spacer()
                    
                    // Bottom section
                    VStack(spacing: 32) {
                        // Page indicator
                        HStack(spacing: 12) {
                            ForEach(0..<pages.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentPage ? Color.finoraPrimary : Color.finoraSecondary)
                                    .frame(width: 10, height: 10)
                                    .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                    .animation(.easeInOut(duration: 0.3), value: currentPage)
                            }
                        }
                        
                        // Action buttons
                        HStack(spacing: 16) {
                            if currentPage < pages.count - 1 {
                                // Next button
                                Button(action: nextPage) {
                                    HStack {
                                        Text("Next")
                                            .font(.headline)
                                        Image(systemName: "arrow.right")
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.finoraPrimary)
                                    .cornerRadius(25)
                                }
                                
                                // Skip button
                                Button(action: skipOnboarding) {
                                    Text("Skip")
                                        .fontWeight(.medium)
                                        .foregroundColor(.finoraPrimary)
                                        .frame(width: 80, height: 50)
                                }
                            } else {
                                // Get Started button
                                Button(action: skipOnboarding) {
                                    HStack {
                                        Text("Get Started")
                                            .font(.headline)
                                        Image(systemName: "arrow.right.circle.fill")
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.finoraPrimary)
                                    .cornerRadius(25)
                                }
                            }
                        }
                        .padding(.horizontal, 32)
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            startAnimation()
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < -50 && currentPage < pages.count - 1 {
                        nextPage()
                    } else if value.translation.width > 50 && currentPage > 0 {
                        previousPage()
                    }
                }
        )
    }
    
    private func startAnimation() {
        withAnimation(.easeOut(duration: 0.8)) {
            opacity = 1
            animationOffset = 0
        }
    }
    
    private func nextPage() {
        guard currentPage < pages.count - 1 else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            animationOffset = -50
            opacity = 0.3
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            currentPage += 1
            animationOffset = 50
            
            withAnimation(.easeOut(duration: 0.5)) {
                animationOffset = 0
                opacity = 1
            }
        }
    }
    
    private func previousPage() {
        guard currentPage > 0 else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            animationOffset = 50
            opacity = 0.3
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            currentPage -= 1
            animationOffset = -50
            
            withAnimation(.easeOut(duration: 0.5)) {
                animationOffset = 0
                opacity = 1
            }
        }
    }
    
    private func skipOnboarding() {
        withAnimation(.easeInOut(duration: 0.5)) {
            showOnboarding = false
        }
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: [Color]
}

#Preview {
    OnboardingView(showOnboarding: .constant(true))
}
