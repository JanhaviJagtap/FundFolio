//
//  DataManager.swift
//  FundFolio
//
//  Created by Janhavi Jagtap on 4/9/2025.
//

import Foundation
import SwiftUI

/// Central data manager for the app handling transactions, budgets, reminders.
/// Observes and publishes changes to update the UI dynamically.
class DataManager: ObservableObject {
    /// List of financial transactions
    @Published var transactions: [Transaction] = []
    
    /// List of budgets set by the user
    @Published var budgets: [Budget] = []
    
    /// List of reminders; saving automatically triggers persistence
    @Published var reminders: [Reminder] = [] {
        didSet { UserDefaultsManager.shared.saveReminders(reminders) }
    }
    
    /// Currency converter instance for currency conversion calculations
    private let currencyConverter = CurrencyConverter()
    
    /// Initializes DataManager by loading persisted data or sample if none exists
    init() {
        loadPersistedData()
        if transactions.isEmpty { loadSampleData() }
    }
    
    // MARK: - Data Persistence
    
    /// Loads reminders from user defaults persistence
    private func loadPersistedData() {
        reminders = UserDefaultsManager.shared.loadReminders()
    }
    
    // MARK: - Transaction Management
    
    /// Adds a new transaction if amount is positive, notifies UI
    func addTransaction(amount: Double, _ transaction: Transaction) -> Bool {
        guard amount > 0 else { return false }
        transactions.append(transaction)
        objectWillChange.send() // Notify UI for update
        return true
    }

    /// Deletes a transaction by matching its id
    func deleteTransaction(_ transaction: Transaction) {
        transactions.removeAll { $0.id == transaction.id }
    }
    
    /// Updates a transaction's details if it exists
    func updateTransaction(_ transaction: Transaction) {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions[index] = transaction
        }
    }
    
    // MARK: - Budget Management
    
    /// Adds a budget and triggers UI update
    func addBudget(_ budget: Budget) {
        budgets.append(budget)
        objectWillChange.send()
    }
    
    /// Deletes a budget by id
    func deleteBudget(_ budget: Budget) {
        budgets.removeAll { $0.id == budget.id }
    }
    
    /// Calculates total spent amount for a budget category and period, converted to budget currency
    func getSpentAmount(for category: TransactionCategory, in period: BudgetPeriod, currency: Currency) -> Double {
        let relevantTransactions = transactions.filter { transaction in
            transaction.category == category && isInCurrentPeriod(transaction.date, period: period)
        }
        
        let totalSpent = relevantTransactions.reduce(0.0) { sum, transaction in
            let convertedAmount = currencyConverter.convert(
                amount: transaction.amount,
                from: transaction.currency,
                to: currency
            )
            return sum + (transaction.isIncome ? 0 : convertedAmount)
        }
        
        return totalSpent
    }
    
    // MARK: - Reminder Management
    
    /// Adds a reminder asynchronously (on main queue)
    func addReminder(_ reminder: Reminder) {
        DispatchQueue.main.async {
            self.reminders.append(reminder)
        }
    }
    
    /// Deletes a reminder by id
    func deleteReminder(_ reminder: Reminder) {
        reminders.removeAll { $0.id == reminder.id }
    }
    
    /// Toggles the completion status of a reminder
    func toggleReminderCompletion(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index].isCompleted.toggle()
        }
    }
    
    // MARK: - Analytics
    
    /// Calculates total net balance = income - expenses in given currency
    func getTotalBalance(in currency: Currency) -> Double {
        let income = getIncomeAmount(in: currency)
        let expenses = getExpenseAmount(in: currency)
        return income - expenses
    }
    
    /// Sums income transaction amounts converted to given currency
    func getIncomeAmount(in currency: Currency) -> Double {
        return transactions.filter { $0.isIncome }.reduce(0.0) { sum, transaction in
            sum + currencyConverter.convert(amount: transaction.amount, from: transaction.currency, to: currency)
        }
    }
    
    /// Sums expense transaction amounts converted to given currency
    func getExpenseAmount(in currency: Currency) -> Double {
        return transactions.filter { !$0.isIncome }.reduce(0.0) { sum, transaction in
            sum + currencyConverter.convert(amount: transaction.amount, from: transaction.currency, to: currency)
        }
    }
    
    /// Returns top 3 upcoming incomplete reminders sorted by due date
    func getUpcomingReminders() -> [Reminder] {
        return reminders
            .filter { !$0.isCompleted && $0.isDueSoon }
            .sorted { $0.dueDate < $1.dueDate }
            .prefix(3)
            .map { $0 }
    }
    
    // MARK: - Helper Methods
    
    /// Checks if a date falls within the current budgeting period (week, month, year)
    private func isInCurrentPeriod(_ date: Date, period: BudgetPeriod) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case .weekly:
            return calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
        case .monthly:
            return calendar.isDate(date, equalTo: now, toGranularity: .month)
        case .yearly:
            return calendar.isDate(date, equalTo: now, toGranularity: .year)
        }
    }
    
    /// Loads sample data for initial app state or testing
    private func loadSampleData() {
        // Sample transactions
        transactions = [
            Transaction(amount: 50.0, currency: .aud, category: .food, description: "Grocery shopping"),
            Transaction(amount: 25.0, currency: .aud, category: .transport, description: "Bus fare"),
            Transaction(amount: 2000.0, currency: .aud, category: .income, description: "Part-time job"),
            Transaction(amount: 800.0, currency: .aud, category: .accommodation, description: "Rent"),
        ]
        
        // Sample budgets
        budgets = [
            Budget(category: .food, limit: 200.0, currency: .aud, period: .weekly),
            Budget(category: .transport, limit: 100.0, currency: .aud, period: .weekly),
        ]
        
        // Sample reminders (only if empty)
        if reminders.isEmpty {
            reminders = [
                Reminder(title: "Monthly Rent", amount: 800.0, dueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(), reminderType: .rent),
                Reminder(title: "Tuition Fee", amount: 5000.0, dueDate: Calendar.current.date(byAdding: .day, value: 15, to: Date()) ?? Date(), reminderType: .tuition),
            ]
        }
    }
}
