//
//  AccountDetailsPage.swift
//  FundFolio
//
//  Created by Janhavi Jagtap on 28/8/2025.
//

import SwiftUI

/// View displaying detailed information about a single user bank account,
/// including current balance, deposit/withdrawal actions, and recent transactions.
struct AccountDetailsPage: View {
    @EnvironmentObject var dataManager: DataManager          // Shared data manager from environment
    @ObservedObject var myvm: AccountsViewModel               // Accounts list view model
    @ObservedObject var account: Accounts                      // The specific account being displayed
    @StateObject var currencyConverter = CurrencyConverter()  // Converter for handling currency operations
    
    @State private var showingAddTransaction = false          // Controls showing transaction form sheet
    @State private var transactionAmount = ""                  // Input for transaction amount
    @State private var transactionDescription = ""             // Input for transaction description
    @State private var isDeposit = true                         // Deposit or withdrawal toggle
    @State private var selectedCategory: TransactionCategory = .other  // Selected category for withdrawal
    
    var body: some View {
        VStack(spacing: 30) {
            // Account Header: showing bank name, currency, and balance prominently
            VStack(spacing: 10) {
                Text(account.bankName)
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 40)
                
                Text(account.currency)
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Text("\(account.amount, specifier: "%.2f")")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
            }
            
            // Buttons to trigger deposit or withdrawal transaction flow
            HStack(spacing: 20) {
                Button(action: {
                    isDeposit = true
                    showingAddTransaction = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Deposit")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                }
                
                Button(action: {
                    isDeposit = false
                    showingAddTransaction = true
                }) {
                    HStack {
                        Image(systemName: "minus.circle.fill")
                        Text("Withdraw")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                }
            }
            
            // Recent transactions list for this account
            VStack(alignment: .leading) {
                Text("Recent Transactions")
                    .font(.headline)
                    .padding(.horizontal)
                
                let accountTransactions = getAccountTransactions()
                if accountTransactions.isEmpty {
                    Text("No transactions yet")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(accountTransactions.prefix(5)) { transaction in
                        TransactionRowView(transaction: transaction)
                    }
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showingAddTransaction) {
            AddAccountTransactionView(
                account: account,
                isDeposit: $isDeposit,
                onTransactionAdded: { amount, description, category in
                    addTransaction(amount: amount, description: description, category: category)
                }
            )
        }
        .padding(20)
        .background(Color("LightYellow"))
    }
    
    /// Filters transactions related to this account by matching currency.
    /// Ideally, would filter by actual account linking in production.
    private func getAccountTransactions() -> [Transaction] {
        guard let accountCurrency = Currency(rawValue: account.currency) else { return [] }
        
        return dataManager.transactions.filter { transaction in
            transaction.currency == accountCurrency
        }.sorted { $0.date > $1.date }
    }
    
    /// Adds a new transaction to this account, updating balance and budgets accordingly.
    private func addTransaction(amount: Double, description: String, category: TransactionCategory) {
        guard let accountCurrency = Currency(rawValue: account.currency) else { return }

        if !isDeposit {
            // Withdrawal: check and deduct amount from balance
            if amount > account.amount {
                // Insufficient funds: silently ignore or handle appropriately
                return
            }
            account.amount -= amount

            // Update budget spent if category matches
            if let matchingBudget = dataManager.budgets.first(where: { $0.category == category }) {
                let convertedAmount = currencyConverter.convert(
                    amount: amount,
                    from: accountCurrency,
                    to: Currency(rawValue: matchingBudget.currency.rawValue) ?? accountCurrency
                )
                matchingBudget.spent += convertedAmount
            }
        } else {
            // Deposit: increase account balance
            account.amount += amount
        }

        // Add transaction record to global data manager
        let transaction = Transaction(
            amount: amount,
            currency: accountCurrency,
            category: isDeposit ? .income : category,
            description: description
        )
        _ = dataManager.addTransaction(amount: amount, transaction)
    }
}

/// View to add a deposit or withdrawal transaction to an account.
/// Validates inputs and calls callback on successful addition.
struct AddAccountTransactionView: View {
    @Environment(\.dismiss) var dismiss
    let account: Accounts
    @Binding var isDeposit: Bool
    let onTransactionAdded: (Double, String, TransactionCategory) -> Void
    
    @State private var amount = ""
    @State private var description = ""
    @State private var selectedCategory: TransactionCategory = .other
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("\(isDeposit ? "Deposit to" : "Withdraw from") \(account.bankName)")) {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    TextField("Description", text: $description)
                    
                    if !isDeposit {
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(TransactionCategory.allCases.filter { $0 != .income }) { category in
                                HStack {
                                    Image(systemName: category.icon)
                                        .foregroundColor(category.color)
                                    Text(category.rawValue)
                                }
                                .tag(category)
                            }
                        }
                    }
                }
            }
            .navigationTitle(isDeposit ? "Deposit" : "Withdraw")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let amountDouble = Double(amount), amountDouble > 0 else { return }
                        
                        if !isDeposit && amountDouble > account.amount {
                            errorMessage = "Insufficient funds!! Available balance is \(account.amount)."
                            showErrorAlert = true
                            return
                        }
                        
                        onTransactionAdded(amountDouble, description.isEmpty ? (isDeposit ? "Deposit" : "Withdrawal") : description, selectedCategory)
                        dismiss()
                    }
                    .alert("Error", isPresented: $showErrorAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text(errorMessage)
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

/// Row view to display a transaction details succinctly with icon, description, date, and amount.
struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            Image(systemName: transaction.category.icon)
                .foregroundColor(transaction.category.color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading) {
                Text(transaction.description)
                    .font(.body)
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(transaction.isIncome ? "+" : "-")\(transaction.currency.symbol)\(transaction.amount, specifier: "%.2f")")
                .font(.headline)
                .foregroundColor(transaction.isIncome ? .green : .red)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#Preview {
    AccountDetailsPage(
        myvm: AccountsViewModel(),
        account: Accounts(
            accountId: UUID(),
            bankName: "Sample Bank",
            currency: "AUD",
            amount: 1234.56
        )
    )
    .environmentObject(DataManager())
}
