//
//  SettingsView.swift
//  dafoma_66
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingResetAlert = false
    @State private var showingBudgetGoalSheet = false
    @State private var newBudgetGoal: String = ""
    @State private var animateCards = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // App Statistics
                    appStatisticsSection
                    
                    // Budget Settings
                    budgetSettingsSection
                    
                    // Achievements
                    achievementsSection
                    
                    // Game Statistics
                    gameStatisticsSection
                    
                    // Danger Zone
                    dangerZoneSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .background(Color.finoraBackground.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.finoraPrimary)
                    .font(.headline)
                }
            }
        }
        .onAppear {
            newBudgetGoal = String(format: "%.0f", dataManager.budget.monthlyGoal)
            startAnimations()
        }
        .sheet(isPresented: $showingBudgetGoalSheet) {
            budgetGoalSheet
        }
        .alert("Reset All Data", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                dataManager.resetAllData()
            }
        } message: {
            Text("Are you sure you want to reset all your data? This action cannot be undone and will delete all transactions, budget goals, and achievements.")
        }
    }
    
    private var appStatisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("App Statistics")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                StatisticCard(
                    title: "Total Incomes",
                    value: "\(dataManager.transactions.filter { $0.type == .income }.count)",
                    icon: "arrow.up.circle.fill",
                    color: .green,
                    animate: animateCards
                )
                
                StatisticCard(
                    title: "Total Expenses",
                    value: "\(dataManager.transactions.filter { $0.type == .expense }.count)",
                    icon: "arrow.down.circle.fill",
                    color: .red,
                    animate: animateCards
                )
                
                StatisticCard(
                    title: "Average Savings",
                    value: String(format: "$%.0f", averageSavings),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .finoraPrimary,
                    animate: animateCards
                )
                
                StatisticCard(
                    title: "Days Active",
                    value: "\(daysActive)",
                    icon: "calendar.badge.checkmark",
                    color: .finoraAccent,
                    animate: animateCards
                )
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(animateCards ? 1.0 : 0.9)
        .opacity(animateCards ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.1), value: animateCards)
    }
    
    private var budgetSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Budget Settings")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Monthly Savings Goal")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text("$\(dataManager.budget.monthlyGoal, specifier: "%.0f")")
                            .font(.title2)
                            .font(.headline)
                            .foregroundColor(.finoraPrimary)
                    }
                    
                    Spacer()
                    
                    Button("Edit") {
                        showingBudgetGoalSheet = true
                    }
                    .foregroundColor(.finoraPrimary)
                    .font(.headline)
                }
                
                ProgressView(value: dataManager.budget.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .finoraPrimary))
                    .scaleEffect(y: 2)
                
                HStack {
                    Text("Current: $\(dataManager.budget.currentSavings, specifier: "%.0f")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(dataManager.budget.progress * 100))% Complete")
                        .font(.caption)
                        .foregroundColor(.finoraPrimary)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(animateCards ? 1.0 : 0.9)
        .opacity(animateCards ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.2), value: animateCards)
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVStack(spacing: 12) {
                ForEach(Array(dataManager.achievements.enumerated()), id: \.element.id) { index, achievement in
                    AchievementRow(achievement: achievement, animate: animateCards, delay: 0.3 + Double(index) * 0.1)
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(animateCards ? 1.0 : 0.9)
        .opacity(animateCards ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.3), value: animateCards)
    }
    
    private var gameStatisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Game Statistics")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.yellow)
                    
                    Text("High Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(dataManager.gameScore.highScore)")
                        .font(.title3)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 60)
                
                VStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.finoraPrimary)
                    
                    Text("Total Badges")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(dataManager.gameScore.totalBadges)")
                        .font(.title3)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                
                if dataManager.gameScore.hasFinancialFocusTitle {
                    Divider()
                        .frame(height: 60)
                    
                    VStack(spacing: 8) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.yellow)
                        
                        Text("Special Title")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Financial Focus")
                            .font(.caption)
                            .font(.headline)
                            .foregroundColor(.finoraPrimary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(animateCards ? 1.0 : 0.9)
        .opacity(animateCards ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.4), value: animateCards)
    }
    
    private var dangerZoneSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Danger Zone")
                .font(.headline)
                .foregroundColor(.red)
            
            Button(action: { showingResetAlert = true }) {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Reset All Data")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(.red)
                .cornerRadius(12)
            }
            .buttonStyle(ScaleButtonStyle())
            
            Text("This will permanently delete all your transactions, budget data, achievements, and game progress.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(animateCards ? 1.0 : 0.9)
        .opacity(animateCards ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.5), value: animateCards)
    }
    
    private var budgetGoalSheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "target")
                        .font(.system(size: 60))
                        .foregroundColor(.finoraPrimary)
                    
                    Text("Set Budget Goal")
                        .font(.title2)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Set your monthly savings target to track your progress")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Monthly Goal")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text("$")
                            .font(.title2)
                            .font(.headline)
                            .foregroundColor(.finoraPrimary)
                        
                        TextField("1000", text: $newBudgetGoal)
                            .font(.title2)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.finoraSecondary.opacity(0.3))
                    )
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
            .padding(.top, 20)
            .background(Color.finoraBackground.ignoresSafeArea())
            .navigationTitle("Budget Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingBudgetGoalSheet = false
                    }
                    .foregroundColor(.finoraPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveBudgetGoal()
                    }
                    .foregroundColor(.finoraPrimary)
                    .font(.headline)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var averageSavings: Double {
        guard !dataManager.transactions.isEmpty else { return 0 }
        return dataManager.monthlySavings
    }
    
    private var daysActive: Int {
        guard let firstTransaction = dataManager.transactions.first else { return 0 }
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: firstTransaction.date, to: Date()).day ?? 0
        return max(1, days)
    }
    
    // MARK: - Methods
    private func startAnimations() {
        withAnimation {
            animateCards = true
        }
    }
    
    private func saveBudgetGoal() {
        guard let goalValue = Double(newBudgetGoal), goalValue > 0 else { return }
        dataManager.updateBudgetGoal(goalValue)
        showingBudgetGoalSheet = false
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let animate: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .scaleEffect(animate ? 1.0 : 0.8)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animate)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text(value)
                    .font(.subheadline)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.finoraSecondary.opacity(0.2))
        )
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    let animate: Bool
    let delay: Double
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: achievement.icon)
                .font(.system(size: 20))
                .foregroundColor(achievement.isUnlocked ? .finoraPrimary : .finoraSecondary)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(achievement.isUnlocked ? Color.finoraPrimary.opacity(0.1) : Color.finoraSecondary.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 16))
            } else {
                Image(systemName: "lock.circle.fill")
                    .foregroundColor(.finoraSecondary)
                    .font(.system(size: 16))
            }
        }
        .padding(.vertical, 8)
        .opacity(animate ? 1.0 : 0.0)
        .offset(x: animate ? 0 : -20)
        .animation(.easeOut(duration: 0.4).delay(delay), value: animate)
    }
}

#Preview {
    SettingsView(dataManager: DataManager())
}
