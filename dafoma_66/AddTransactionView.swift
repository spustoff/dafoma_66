//
//  AddTransactionView.swift
//  dafoma_66
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI

struct AddTransactionView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    let transactionType: TransactionType
    
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var selectedCategory: TransactionCategory = .other
    @State private var date = Date()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var animateForm = false
    
    private var availableCategories: [TransactionCategory] {
        switch transactionType {
        case .income:
            return [.salary, .freelance, .other]
        case .expense:
            return [.food, .transport, .entertainment, .other]
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Form
                    formSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color.finoraBackground.ignoresSafeArea())
            .navigationTitle(transactionType == .income ? "Add Income" : "Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.finoraPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTransaction()
                    }
                    .foregroundColor(.finoraPrimary)
                    .font(.headline)
                }
            }
        }
        .onAppear {
            selectedCategory = availableCategories.first ?? .other
            startAnimation()
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: transactionType == .income ? "plus.circle.fill" : "minus.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(transactionType == .income ? .green : .red)
                .scaleEffect(animateForm ? 1.0 : 0.8)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateForm)
            
            Text(transactionType == .income ? "Add New Income" : "Add New Expense")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .opacity(animateForm ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: animateForm)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(animateForm ? 1.0 : 0.9)
        .opacity(animateForm ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.1), value: animateForm)
    }
    
    private var formSection: some View {
        VStack(spacing: 20) {
            // Amount input
            VStack(alignment: .leading, spacing: 8) {
                Text("Amount")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Text("$")
                        .font(.title2)
                        .font(.headline)
                        .foregroundColor(.finoraPrimary)
                    
                    TextField("0.00", text: $amount)
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
            .opacity(animateForm ? 1.0 : 0.0)
            .offset(x: animateForm ? 0 : -50)
            .animation(.easeOut(duration: 0.6).delay(0.3), value: animateForm)
            
            // Description input
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField("Enter description...", text: $description)
                    .font(.body)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.finoraSecondary.opacity(0.3))
                    )
            }
            .opacity(animateForm ? 1.0 : 0.0)
            .offset(x: animateForm ? 0 : -50)
            .animation(.easeOut(duration: 0.6).delay(0.4), value: animateForm)
            
            // Category selection
            VStack(alignment: .leading, spacing: 12) {
                Text("Category")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    ForEach(availableCategories, id: \.self) { category in
                        CategoryButton(
                            category: category,
                            isSelected: selectedCategory == category,
                            action: { selectedCategory = category }
                        )
                    }
                }
            }
            .opacity(animateForm ? 1.0 : 0.0)
            .offset(x: animateForm ? 0 : -50)
            .animation(.easeOut(duration: 0.6).delay(0.5), value: animateForm)
            
            // Date picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Date")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                DatePicker("Transaction Date", selection: $date, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.finoraSecondary.opacity(0.3))
                    )
            }
            .opacity(animateForm ? 1.0 : 0.0)
            .offset(x: animateForm ? 0 : -50)
            .animation(.easeOut(duration: 0.6).delay(0.6), value: animateForm)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(animateForm ? 1.0 : 0.9)
        .opacity(animateForm ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.2), value: animateForm)
    }
    
    private func startAnimation() {
        withAnimation {
            animateForm = true
        }
    }
    
    private func saveTransaction() {
        // Validate input
        guard !amount.isEmpty else {
            alertMessage = "Please enter an amount"
            showingAlert = true
            return
        }
        
        guard let amountValue = Double(amount), amountValue > 0 else {
            alertMessage = "Please enter a valid amount greater than 0"
            showingAlert = true
            return
        }
        
        guard !description.isEmpty else {
            alertMessage = "Please enter a description"
            showingAlert = true
            return
        }
        
        // Create transaction
        let transaction = Transaction(
            amount: amountValue,
            description: description,
            category: selectedCategory,
            date: date,
            type: transactionType
        )
        
        // Add to data manager
        dataManager.addTransaction(transaction)
        
        // Dismiss view
        dismiss()
    }
}

struct CategoryButton: View {
    let category: TransactionCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : category.color)
                
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? category.color : Color.finoraSecondary.opacity(0.3))
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    AddTransactionView(dataManager: DataManager(), transactionType: .income)
}
