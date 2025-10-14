//
//  MiniGameView.swift
//  dafoma_66
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI
import Combine

struct MiniGameView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var gameState: GameState = .ready
    @State private var walletVerticalPosition: CGFloat = 0
    @State private var walletVelocity: CGFloat = 0
    @State private var isJumping = false
    @State private var obstacles: [Obstacle] = []
    @State private var score = 0
    @State private var gameSpeed: Double = 1.8
    @State private var backgroundOffset: CGFloat = 0
    @State private var showingGameOver = false
    @State private var lastObstacleSpawnX: CGFloat = 0
    
    private let walletSize: CGFloat = 40
    private let obstacleWidth: CGFloat = 20
    private let obstacleHeight: CGFloat = 25
    private let jumpForce: CGFloat = -12.0
    private let gravity: CGFloat = 0.6
    private let groundLevel: CGFloat = 100
    private let minObstacleDistance: CGFloat = 180
    private let maxObstacleDistance: CGFloat = 280
    
    enum GameState {
        case ready, playing, paused, gameOver
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.finoraBackground.ignoresSafeArea()
            
            if gameState == .ready {
                // Стартовый экран - максимально простая верстка
                VStack {
                    // Заголовок с кнопками управления
                    HStack {
                        Text("Budget Jump")
                            .font(.largeTitle)
                            .font(.headline)
                            .foregroundColor(.finoraPrimary)
                        Spacer()
                        
                        // Кнопки управления всегда видны
                        HStack(spacing: 8) {
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .frame(width: 32, height: 32)
                                    .background(.gray)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    Spacer()
                    
                    // Центральный контент
                    VStack(spacing: 20) {
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.finoraPrimary)
                        
                        Text("Help your wallet jump over unnecessary expenses!")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        VStack(spacing: 8) {
                            Text("• Tap anywhere to jump")
                                .font(.subheadline)
                            Text("• Avoid coffee cups and shopping bags")
                                .font(.subheadline)
                            Text("• Earn badges every 10 points")
                                .font(.subheadline)
                        }
                        .foregroundColor(.secondary)
                        
                        Button(action: startGame) {
                            Text("Start Game")
                                .font(.title2)
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color.finoraPrimary)
                                .cornerRadius(30)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        // Дополнительные кнопки управления
                        HStack(spacing: 16) {
                            Button(action: { 
                                // Показать инструкции
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "questionmark.circle")
                                    Text("Help")
                                }
                                .font(.subheadline)
                                .foregroundColor(.finoraPrimary)
                                .frame(height: 40)
                                .frame(maxWidth: .infinity)
                                .background(Color.finoraPrimary.opacity(0.1))
                                .cornerRadius(20)
                            }
                            
                            Button(action: { dismiss() }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.left")
                                    Text("Back")
                                }
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(height: 40)
                                .frame(maxWidth: .infinity)
                                .background(Color.finoraSecondary.opacity(0.3))
                                .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            } else {
                // Игровой экран
                GeometryReader { geometry in
                    ZStack {
                        // Game background
                        gameBackground(geometry: geometry)
                        
                        // Game elements
                        if gameState != .ready {
                            gameElements(geometry: geometry)
                        }
                        
                        // Плавающие кнопки управления - ВСЕГДА ВИДНЫ
                        VStack {
                            HStack {
                                // Score
                                VStack(alignment: .leading) {
                                    Text("Score: \(score)")
                                        .font(.headline)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
                                    
                                    Text("Badges: \(score / 10)")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(12)
                                
                                Spacer()
                                
                                // Большие заметные кнопки управления
                                VStack(spacing: 8) {
                                    if gameState == .playing {
                                        Button(action: pauseGame) {
                                            Image(systemName: "pause.fill")
                                                .font(.title2)
                                                .foregroundColor(.white)
                                                .frame(width: 44, height: 44)
                                                .background(Color.finoraPrimary)
                                                .clipShape(Circle())
                                                .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)
                                        }
                                    } else if gameState == .paused {
                                        Button(action: resumeGame) {
                                            Image(systemName: "play.fill")
                                                .font(.title2)
                                                .foregroundColor(.white)
                                                .frame(width: 44, height: 44)
                                                .background(Color.finoraPrimary)
                                                .clipShape(Circle())
                                                .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)
                                        }
                                    }
                                    
                                    if gameState == .playing || gameState == .paused {
                                        Button(action: stopGame) {
                                            Image(systemName: "stop.fill")
                                                .font(.title2)
                                                .foregroundColor(.white)
                                                .frame(width: 44, height: 44)
                                                .background(.red)
                                                .clipShape(Circle())
                                                .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)
                                        }
                                    }
                                    
                                    Button(action: { dismiss() }) {
                                        Image(systemName: "xmark")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .frame(width: 44, height: 44)
                                            .background(.gray)
                                            .clipShape(Circle())
                                            .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                            
                            Spacer()
                            
                            // Pause screen overlay
                            if gameState == .paused {
                                pauseOverlay
                            }
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if gameState != .paused {
                            jump()
                        }
                    }
                }
            }
        }
        .onReceive(Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()) { _ in
            if gameState == .playing {
                updateGame()
            }
        }
        .alert("Game Over!", isPresented: $showingGameOver) {
            Button("Play Again") {
                resetGame()
            }
            Button("Close") {
                dismiss()
            }
        } message: {
            Text("Score: \(score)\nBadges earned: \(score / 10)")
        }
    }
    
    private func gameBackground(geometry: GeometryProxy) -> some View {
        ZStack {
            // Animated background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.finoraPrimary.opacity(0.1),
                    Color.finoraAccent.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Moving background elements
            HStack(spacing: 50) {
                ForEach(0..<10, id: \.self) { _ in
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.finoraPrimary.opacity(0.2))
                }
            }
            .offset(x: backgroundOffset)
            .animation(.linear(duration: 0.016), value: backgroundOffset)
            
            // Ground
            Rectangle()
                .fill(Color.finoraSecondary.opacity(0.3))
                .frame(height: 4)
                .position(x: geometry.size.width / 2, y: geometry.size.height - groundLevel + 20)
        }
    }
    
    private func gameElements(geometry: GeometryProxy) -> some View {
        ZStack {
            // Wallet (player)
            Image(systemName: "creditcard.fill")
                .font(.system(size: walletSize))
                .foregroundColor(.finoraPrimary)
                .position(
                    x: 80,
                    y: geometry.size.height - groundLevel + walletVerticalPosition
                )
            
            // Obstacles
            ForEach(obstacles) { obstacle in
                Image(systemName: obstacle.icon)
                    .font(.system(size: obstacleHeight))
                    .foregroundColor(obstacle.color)
                    .position(x: obstacle.x, y: geometry.size.height - groundLevel)
            }
        }
    }
    
    
    
    private func startGame() {
        gameState = .playing
        score = 0
        obstacles.removeAll()
        gameSpeed = 1.8
        walletVerticalPosition = 0
        walletVelocity = 0
        isJumping = false
        lastObstacleSpawnX = 400
        spawnObstacle()
    }
    
    private func resetGame() {
        gameState = .ready
        score = 0
        obstacles.removeAll()
        gameSpeed = 1.8
        walletVerticalPosition = 0
        walletVelocity = 0
        isJumping = false
        showingGameOver = false
        lastObstacleSpawnX = 0
    }
    
    private func updateGame() {
        // Update wallet physics
        updateWalletPhysics()
        
        // Move background
        backgroundOffset -= gameSpeed
        if backgroundOffset <= -400 {
            backgroundOffset = 0
        }
        
        // Move obstacles
        for i in obstacles.indices {
            obstacles[i].x -= gameSpeed
        }
        
        // Remove off-screen obstacles and add score
        obstacles.removeAll { obstacle in
            if obstacle.x < -obstacleWidth {
                score += 1
                return true
            }
            return false
        }
        
        // Spawn new obstacles with proper spacing
        spawnObstacleIfNeeded()
        
        // Check collisions
        checkCollisions()
        
        // Increase game speed gradually
        gameSpeed += 0.002
    }
    
    private func updateWalletPhysics() {
        // Apply gravity
        walletVelocity += gravity
        
        // Update position
        walletVerticalPosition += walletVelocity
        
        // Ground collision
        if walletVerticalPosition >= 0 {
            walletVerticalPosition = 0
            walletVelocity = 0
            isJumping = false
        }
    }
    
    private func spawnObstacleIfNeeded() {
        // Check if we need to spawn a new obstacle
        let screenWidth: CGFloat = 400
        let shouldSpawn = obstacles.isEmpty || 
                         (obstacles.last!.x < screenWidth - minObstacleDistance)
        
        if shouldSpawn {
            spawnObstacle()
        }
    }
    
    private func spawnObstacle() {
        let obstacleTypes = [
            ("cup.and.saucer.fill", Color.orange),
            ("bag.fill", Color.purple),
            ("gamecontroller.fill", Color.blue),
            ("car.fill", Color.red)
        ]
        
        let randomType = obstacleTypes.randomElement()!
        let randomDistance = CGFloat.random(in: minObstacleDistance...maxObstacleDistance)
        
        let spawnX = obstacles.isEmpty ? 400 + obstacleWidth : 
                    max(obstacles.last!.x + randomDistance, 400 + obstacleWidth)
        
        let obstacle = Obstacle(
            x: spawnX,
            icon: randomType.0,
            color: randomType.1
        )
        obstacles.append(obstacle)
        lastObstacleSpawnX = spawnX
    }
    
    private func checkCollisions() {
        let walletRect = CGRect(
            x: 80 - walletSize/2,
            y: 600 - groundLevel + walletVerticalPosition - walletSize/2,
            width: walletSize * 0.8, // Slightly smaller hitbox for better gameplay
            height: walletSize * 0.8
        )
        
        for obstacle in obstacles {
            let obstacleRect = CGRect(
                x: obstacle.x - obstacleWidth/2,
                y: 600 - groundLevel - obstacleHeight/2,
                width: obstacleWidth * 0.8, // Slightly smaller hitbox
                height: obstacleHeight * 0.8
            )
            
            if walletRect.intersects(obstacleRect) {
                gameOver()
                return
            }
        }
    }
    
    private func gameOver() {
        gameState = .gameOver
        dataManager.updateGameScore(score)
        showingGameOver = true
    }
    
    private func jump() {
        if gameState == .playing && walletVerticalPosition >= -5 {
            // Only allow jump if wallet is on or near ground
            walletVelocity = jumpForce
            isJumping = true
        } else if gameState == .ready {
            startGame()
        } else if gameState == .paused {
            resumeGame()
        }
    }
    
    // MARK: - Game Control Functions
    private func pauseGame() {
        gameState = .paused
    }
    
    private func resumeGame() {
        gameState = .playing
    }
    
    private func stopGame() {
        gameState = .ready
        score = 0
        obstacles.removeAll()
        walletVerticalPosition = 0
        walletVelocity = 0
        isJumping = false
        lastObstacleSpawnX = 0
    }
    
    // MARK: - Pause Overlay
    private var pauseOverlay: some View {
        VStack(spacing: 20) {
            Text("Game Paused")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.finoraPrimary)
            
            Text("Tap anywhere or press play to continue")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 20) {
                Button(action: resumeGame) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                        Text("Resume")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(width: 120, height: 44)
                    .background(Color.finoraPrimary)
                    .cornerRadius(22)
                }
                .buttonStyle(ScaleButtonStyle())
                
                Button(action: stopGame) {
                    HStack(spacing: 8) {
                        Image(systemName: "stop.fill")
                        Text("Stop")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(width: 120, height: 44)
                    .background(.red)
                    .cornerRadius(22)
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 30)
        .onTapGesture {
            resumeGame()
        }
    }
}

struct Obstacle: Identifiable {
    let id = UUID()
    var x: CGFloat
    let icon: String
    let color: Color
}


#Preview {
    NavigationView {
        MiniGameView(dataManager: DataManager())
    }
}
