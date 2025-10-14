//
//  StatisticsView.swift
//  dafoma_66
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI

struct StatisticsView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var animateCharts = false
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Overview cards
                    overviewCards
                    
                    // Category breakdown
                    categoryBreakdown
                    
                    // Monthly trend (simple bar chart)
                    monthlyTrend
                    
                    // Reset section
                    resetSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .background(Color.finoraBackground.ignoresSafeArea())
            .navigationTitle("Statistics")
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
            startAnimations()
        }
        .alert("Reset Progress", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                dataManager.resetAllData()
            }
        } message: {
            Text("Are you sure you want to reset all your financial data? This action cannot be undone.")
        }
    }
    
    private var overviewCards: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
            StatCard(
                title: "Total Income",
                value: dataManager.transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount },
                icon: "arrow.up.circle.fill",
                color: .green,
                animate: animateCharts
            )
            
            StatCard(
                title: "Total Expenses",
                value: dataManager.transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount },
                icon: "arrow.down.circle.fill",
                color: .red,
                animate: animateCharts
            )
            
            StatCard(
                title: "Net Savings",
                value: dataManager.currentBalance,
                icon: "banknote.fill",
                color: .finoraPrimary,
                animate: animateCharts
            )
            
            StatCard(
                title: "Transactions",
                value: Double(dataManager.transactions.count),
                icon: "list.bullet",
                color: .finoraAccent,
                animate: animateCharts,
                isCount: true
            )
        }
        .opacity(animateCharts ? 1.0 : 0.0)
        .offset(y: animateCharts ? 0 : 20)
        .animation(.easeOut(duration: 0.6).delay(0.1), value: animateCharts)
    }
    
    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Expenses by Category")
                .font(.headline)
                .foregroundColor(.primary)
            
            let expensesByCategory = dataManager.expensesByCategory()
            
            if expensesByCategory.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 40))
                        .foregroundColor(.finoraSecondary)
                    Text("No expense data yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                // Simple progress bars for categories
                VStack(spacing: 12) {
                    let totalExpenses = expensesByCategory.values.reduce(0, +)
                    
                    ForEach(Array(expensesByCategory.sorted { $0.value > $1.value }.enumerated()), id: \.element.key) { index, item in
                        CategoryProgressRow(
                            category: item.key,
                            amount: item.value,
                            percentage: totalExpenses > 0 ? item.value / totalExpenses : 0,
                            animate: animateCharts,
                            delay: 0.3 + Double(index) * 0.1
                        )
                    }
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
        .scaleEffect(animateCharts ? 1.0 : 0.9)
        .opacity(animateCharts ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.2), value: animateCharts)
    }
    
    private var monthlyTrend: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Overview")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("This Month")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 4) {
                        HStack {
                            Rectangle()
                                .fill(.green)
                                .frame(width: 12, height: max(4, dataManager.monthlyIncome / 100))
                                .scaleEffect(y: animateCharts ? 1.0 : 0.1, anchor: .bottom)
                                .animation(.easeOut(duration: 0.8).delay(0.4), value: animateCharts)
                            
                            Rectangle()
                                .fill(.red)
                                .frame(width: 12, height: max(4, dataManager.monthlyExpenses / 100))
                                .scaleEffect(y: animateCharts ? 1.0 : 0.1, anchor: .bottom)
                                .animation(.easeOut(duration: 0.8).delay(0.5), value: animateCharts)
                        }
                        
                        HStack(spacing: 8) {
                            Text("Income")
                                .font(.caption2)
                                .foregroundColor(.green)
                            Text("Expenses")
                                .font(.caption2)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    HStack {
                        Image(systemName: "arrow.up")
                            .foregroundColor(.green)
                        Text("$\(dataManager.monthlyIncome, specifier: "%.0f")")
                            .font(.headline)
                    }
                    .font(.subheadline)
                    
                    HStack {
                        Image(systemName: "arrow.down")
                            .foregroundColor(.red)
                        Text("$\(dataManager.monthlyExpenses, specifier: "%.0f")")
                            .font(.headline)
                    }
                    .font(.subheadline)
                    
                    Divider()
                        .frame(width: 60)
                    
                    HStack {
                        Image(systemName: "equal")
                            .foregroundColor(.finoraPrimary)
                        Text("$\(dataManager.monthlySavings, specifier: "%.0f")")
                            .font(.headline)
                            .foregroundColor(.finoraPrimary)
                    }
                    .font(.subheadline)
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
        .scaleEffect(animateCharts ? 1.0 : 0.9)
        .opacity(animateCharts ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.3), value: animateCharts)
    }
    
    private var resetSection: some View {
        VStack(spacing: 16) {
            Text("Danger Zone")
                .font(.headline)
                .foregroundColor(.red)
            
            Button(action: { showingResetAlert = true }) {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Reset All Progress")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(.red)
                .cornerRadius(12)
            }
            .buttonStyle(ScaleButtonStyle())
            
            Text("This will permanently delete all your transactions, budget data, and achievements.")
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
        .scaleEffect(animateCharts ? 1.0 : 0.9)
        .opacity(animateCharts ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.4), value: animateCharts)
    }
    
    private func startAnimations() {
        withAnimation {
            animateCharts = true
        }
    }
}

struct StatCard: View {
    let title: String
    let value: Double
    let icon: String
    let color: Color
    let animate: Bool
    let isCount: Bool
    
    init(title: String, value: Double, icon: String, color: Color, animate: Bool, isCount: Bool = false) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
        self.animate = animate
        self.isCount = isCount
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .scaleEffect(animate ? 1.0 : 0.8)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animate)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                if isCount {
                    Text("\(Int(value))")
                        .font(.title3)
                        .font(.headline)
                        .foregroundColor(.primary)
                } else {
                    Text("$\(value, specifier: "%.0f")")
                        .font(.title3)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

struct CategoryProgressRow: View {
    let category: TransactionCategory
    let amount: Double
    let percentage: Double
    let animate: Bool
    let delay: Double
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.system(size: 16))
                .foregroundColor(category.color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(category.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("$\(amount, specifier: "%.0f")")
                        .font(.subheadline)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                ProgressView(value: animate ? percentage : 0)
                    .progressViewStyle(LinearProgressViewStyle(tint: category.color))
                    .scaleEffect(y: 1.5)
                    .animation(.easeOut(duration: 0.8).delay(delay), value: animate)
                
                Text("\(Int(percentage * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .opacity(animate ? 1.0 : 0.0)
        .offset(x: animate ? 0 : -20)
        .animation(.easeOut(duration: 0.4).delay(delay), value: animate)
    }
}

#Preview {
    StatisticsView(dataManager: DataManager())
}
