//
//  DataManager.swift
//  dafoma_66
//
//  Created by IGOR on 13/10/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class DataManager: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var budget: Budget = Budget(monthlyGoal: 1000, currentSavings: 0)
    @Published var gameScore: GameScore = GameScore(highScore: 0, totalBadges: 0, hasFinancialFocusTitle: false)
    @Published var achievements: [Achievement] = []
    
    private let transactionsKey = "finora_transactions"
    private let budgetKey = "finora_budget"
    private let gameScoreKey = "finora_game_score"
    private let achievementsKey = "finora_achievements"
    
    init() {
        loadData()
        createDefaultAchievements()
    }
    
    // MARK: - Computed Properties
    var currentBalance: Double {
        let income = transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let expenses = transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        return income - expenses
    }
    
    var monthlyIncome: Double {
        let calendar = Calendar.current
        let now = Date()
        return transactions.filter { transaction in
            transaction.type == .income &&
            calendar.isDate(transaction.date, equalTo: now, toGranularity: .month)
        }.reduce(0) { $0 + $1.amount }
    }
    
    var monthlyExpenses: Double {
        let calendar = Calendar.current
        let now = Date()
        return transactions.filter { transaction in
            transaction.type == .expense &&
            calendar.isDate(transaction.date, equalTo: now, toGranularity: .month)
        }.reduce(0) { $0 + $1.amount }
    }
    
    var monthlySavings: Double {
        return monthlyIncome - monthlyExpenses
    }
    
    // MARK: - Transaction Management
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        updateBudgetSavings()
        checkAchievements()
        saveData()
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        transactions.removeAll { $0.id == transaction.id }
        updateBudgetSavings()
        saveData()
    }
    
    // MARK: - Budget Management
    func updateBudgetGoal(_ newGoal: Double) {
        budget.monthlyGoal = newGoal
        saveData()
    }
    
    private func updateBudgetSavings() {
        budget.currentSavings = monthlySavings
    }
    
    // MARK: - Game Management
    func updateGameScore(_ newScore: Int) {
        if newScore > gameScore.highScore {
            gameScore.highScore = newScore
        }
        gameScore.totalBadges += 1
        
        if gameScore.totalBadges >= 10 && !gameScore.hasFinancialFocusTitle {
            gameScore.hasFinancialFocusTitle = true
            unlockAchievement(title: "Financial Focus")
        }
        
        checkAchievements()
        saveData()
    }
    
    // MARK: - Achievement Management
    private func createDefaultAchievements() {
        if achievements.isEmpty {
            achievements = [
                Achievement(title: "Budget Master", description: "Create your first budget goal", icon: "target", isUnlocked: false, unlockedDate: nil),
                Achievement(title: "Planner of the Week", description: "Track expenses for 7 days", icon: "calendar.badge.checkmark", isUnlocked: false, unlockedDate: nil),
                Achievement(title: "Savings Hero", description: "Reach your monthly savings goal", icon: "star.fill", isUnlocked: false, unlockedDate: nil),
                Achievement(title: "Financial Focus", description: "Earn 10 badges in the mini-game", icon: "gamecontroller.fill", isUnlocked: false, unlockedDate: nil),
                Achievement(title: "Income Tracker", description: "Add your first income", icon: "plus.circle.fill", isUnlocked: false, unlockedDate: nil),
                Achievement(title: "Expense Monitor", description: "Add your first expense", icon: "minus.circle.fill", isUnlocked: false, unlockedDate: nil)
            ]
            saveData()
        }
    }
    
    private func checkAchievements() {
        // Budget Master
        if budget.monthlyGoal > 0 {
            unlockAchievement(title: "Budget Master")
        }
        
        // Income Tracker
        if transactions.contains(where: { $0.type == .income }) {
            unlockAchievement(title: "Income Tracker")
        }
        
        // Expense Monitor
        if transactions.contains(where: { $0.type == .expense }) {
            unlockAchievement(title: "Expense Monitor")
        }
        
        // Savings Hero
        if budget.progress >= 1.0 {
            unlockAchievement(title: "Savings Hero")
        }
        
        // Planner of the Week
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentTransactions = transactions.filter { $0.date >= weekAgo }
        if recentTransactions.count >= 5 {
            unlockAchievement(title: "Planner of the Week")
        }
    }
    
    private func unlockAchievement(title: String) {
        if let index = achievements.firstIndex(where: { $0.title == title && !$0.isUnlocked }) {
            let oldAchievement = achievements[index]
            achievements[index] = Achievement(
                title: oldAchievement.title,
                description: oldAchievement.description,
                icon: oldAchievement.icon,
                isUnlocked: true,
                unlockedDate: Date()
            )
            saveData()
        }
    }
    
    // MARK: - Category Statistics
    func expensesByCategory() -> [TransactionCategory: Double] {
        let expenses = transactions.filter { $0.type == .expense }
        var categoryTotals: [TransactionCategory: Double] = [:]
        
        for expense in expenses {
            categoryTotals[expense.category, default: 0] += expense.amount
        }
        
        return categoryTotals
    }
    
    // MARK: - Data Persistence
    private func saveData() {
        // Save transactions
        if let transactionsData = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(transactionsData, forKey: transactionsKey)
        }
        
        // Save budget
        if let budgetData = try? JSONEncoder().encode(budget) {
            UserDefaults.standard.set(budgetData, forKey: budgetKey)
        }
        
        // Save game score
        if let gameScoreData = try? JSONEncoder().encode(gameScore) {
            UserDefaults.standard.set(gameScoreData, forKey: gameScoreKey)
        }
        
        // Save achievements
        if let achievementsData = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(achievementsData, forKey: achievementsKey)
        }
    }
    
    private func loadData() {
        // Load transactions
        if let transactionsData = UserDefaults.standard.data(forKey: transactionsKey),
           let loadedTransactions = try? JSONDecoder().decode([Transaction].self, from: transactionsData) {
            transactions = loadedTransactions
        }
        
        // Load budget
        if let budgetData = UserDefaults.standard.data(forKey: budgetKey),
           let loadedBudget = try? JSONDecoder().decode(Budget.self, from: budgetData) {
            budget = loadedBudget
        }
        
        // Load game score
        if let gameScoreData = UserDefaults.standard.data(forKey: gameScoreKey),
           let loadedGameScore = try? JSONDecoder().decode(GameScore.self, from: gameScoreData) {
            gameScore = loadedGameScore
        }
        
        // Load achievements
        if let achievementsData = UserDefaults.standard.data(forKey: achievementsKey),
           let loadedAchievements = try? JSONDecoder().decode([Achievement].self, from: achievementsData) {
            achievements = loadedAchievements
        }
    }
    
    // MARK: - Reset Data
    func resetAllData() {
        transactions.removeAll()
        budget = Budget(monthlyGoal: 1000, currentSavings: 0)
        gameScore = GameScore(highScore: 0, totalBadges: 0, hasFinancialFocusTitle: false)
        achievements.removeAll()
        createDefaultAchievements()
        saveData()
    }
}
