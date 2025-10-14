//
//  Models.swift
//  dafoma_66
//
//  Created by IGOR on 13/10/2025.
//

import Foundation
import SwiftUI

// MARK: - Transaction Models
struct Transaction: Identifiable, Codable {
    let id = UUID()
    let amount: Double
    let description: String
    let category: TransactionCategory
    let date: Date
    let type: TransactionType
}

enum TransactionType: String, Codable, CaseIterable {
    case income = "Income"
    case expense = "Expense"
}

enum TransactionCategory: String, Codable, CaseIterable {
    case food = "Food"
    case transport = "Transport"
    case entertainment = "Entertainment"
    case savings = "Savings"
    case salary = "Salary"
    case freelance = "Freelance"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .entertainment: return "gamecontroller.fill"
        case .savings: return "banknote"
        case .salary: return "briefcase.fill"
        case .freelance: return "laptopcomputer"
        case .other: return "ellipsis.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .food: return .orange
        case .transport: return .blue
        case .entertainment: return .purple
        case .savings: return Color(hex: "#21A038")
        case .salary: return Color(hex: "#007B3C")
        case .freelance: return .cyan
        case .other: return .gray
        }
    }
}

// MARK: - Budget Model
struct Budget: Codable {
    var monthlyGoal: Double
    var currentSavings: Double
    
    var progress: Double {
        guard monthlyGoal > 0 else { return 0 }
        return min(currentSavings / monthlyGoal, 1.0)
    }
}

// MARK: - Achievement Model
struct Achievement: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let isUnlocked: Bool
    let unlockedDate: Date?
}

// MARK: - Game Score Model
struct GameScore: Codable {
    var highScore: Int
    var totalBadges: Int
    var hasFinancialFocusTitle: Bool
}

// MARK: - App Colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    static let finoraBackground = Color(hex: "#F6F8F5")
    static let finoraPrimary = Color(hex: "#21A038")
    static let finoraAccent = Color(hex: "#007B3C")
    static let finoraSecondary = Color(hex: "#E0E0E0")
}
