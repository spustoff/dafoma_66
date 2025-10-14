//
//  DashboardView.swift
//  dafoma_66
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var dataManager: DataManager
    @State private var showingAddIncome = false
    @State private var showingAddExpense = false
    @State private var showingStatistics = false
    @State private var showingMiniGame = false
    @State private var showingSettings = false
    @State private var animateCards = false
    @State private var animateBalance = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with balance
                    balanceCard
                    
                    // Monthly overview
                    monthlyOverviewCard
                    
                    // Progress section
                    progressCard
                    
                    // Action buttons
                    actionButtons
                    
                    // Recent transactions
                    recentTransactionsCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .background(Color.finoraBackground.ignoresSafeArea())
            .navigationTitle("Finora")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.finoraPrimary)
                    }
                }
            }
        }
        .onAppear {
            startAnimations()
        }
        .sheet(isPresented: $showingAddIncome) {
            AddTransactionView(dataManager: dataManager, transactionType: .income)
        }
        .sheet(isPresented: $showingAddExpense) {
            AddTransactionView(dataManager: dataManager, transactionType: .expense)
        }
        .sheet(isPresented: $showingStatistics) {
            StatisticsView(dataManager: dataManager)
        }
        .sheet(isPresented: $showingMiniGame) {
            MiniGameView(dataManager: dataManager)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(dataManager: dataManager)
        }
    }
    
    private var balanceCard: some View {
        VStack(spacing: 16) {
            Text("Current Balance")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("$\(dataManager.currentBalance, specifier: "%.2f")")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.finoraPrimary)
                .scaleEffect(animateBalance ? 1.0 : 0.8)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateBalance)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(animateCards ? 1.0 : 0.9)
        .opacity(animateCards ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.1), value: animateCards)
    }
    
    private var monthlyOverviewCard: some View {
        VStack(spacing: 16) {
            Text("This Month")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.green)
                        Text("Income")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Text("$\(dataManager.monthlyIncome, specifier: "%.2f")")
                        .font(.title2)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 40)
                
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.red)
                        Text("Expenses")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Text("$\(dataManager.monthlyExpenses, specifier: "%.2f")")
                        .font(.title2)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
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
    
    private var progressCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Savings Goal")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text("$\(dataManager.budget.currentSavings, specifier: "%.0f") / $\(dataManager.budget.monthlyGoal, specifier: "%.0f")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: dataManager.budget.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .finoraPrimary))
                .scaleEffect(y: 2)
            
            Text("\(Int(dataManager.budget.progress * 100))% Complete")
                .font(.caption)
                .foregroundColor(.finoraPrimary)
                .fontWeight(.medium)
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
    
    private var actionButtons: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
            ActionButton(
                title: "Add Income",
                icon: "plus.circle.fill",
                color: .green,
                action: { showingAddIncome = true }
            )
            
            ActionButton(
                title: "Add Expense",
                icon: "minus.circle.fill",
                color: .red,
                action: { showingAddExpense = true }
            )
            
            ActionButton(
                title: "Statistics",
                icon: "chart.bar.fill",
                color: .finoraPrimary,
                action: { showingStatistics = true }
            )
            
            ActionButton(
                title: "Mini-Game",
                icon: "gamecontroller.fill",
                color: .finoraAccent,
                action: { showingMiniGame = true }
            )
        }
        .scaleEffect(animateCards ? 1.0 : 0.9)
        .opacity(animateCards ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.4), value: animateCards)
    }
    
    private var recentTransactionsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Transactions")
                .font(.headline)
                .foregroundColor(.primary)
            
            if dataManager.transactions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundColor(.finoraSecondary)
                    Text("No transactions yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Add your first income or expense to get started")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(dataManager.transactions.suffix(5).reversed().enumerated()), id: \.element.id) { index, transaction in
                        TransactionRow(transaction: transaction)
                            .opacity(animateCards ? 1.0 : 0.0)
                            .offset(x: animateCards ? 0 : 50)
                            .animation(.easeOut(duration: 0.4).delay(0.5 + Double(index) * 0.1), value: animateCards)
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
        .scaleEffect(animateCards ? 1.0 : 0.9)
        .opacity(animateCards ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.5), value: animateCards)
    }
    
    private func startAnimations() {
        withAnimation {
            animateCards = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                animateBalance = true
            }
        }
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: transaction.category.icon)
                .font(.system(size: 20))
                .foregroundColor(transaction.category.color)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(transaction.category.color.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(transaction.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(transaction.type == .income ? "+" : "-")$\(transaction.amount, specifier: "%.2f")")
                    .font(.subheadline)
                    .font(.headline)
                    .foregroundColor(transaction.type == .income ? .green : .red)
                
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    DashboardView(dataManager: DataManager())
}
