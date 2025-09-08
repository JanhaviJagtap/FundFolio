//
//  Transactions.swift
//  FundFolio
//
//  Created by Janhavi Jagtap on 28/8/2025.
//

import Foundation
import SwiftUI

// Transaction represents a financial transaction
class Transaction: ObservableObject, TransactionProtocol, Identifiable, Codable {
    var id = UUID()
    var amount: Double
    var currency: Currency
    var date: Date
    var category: TransactionCategory
    var description: String
    
    // True if the transaction is income
    var isIncome: Bool { category == .income }
    
    init(amount: Double, currency: Currency, date: Date = Date(), category: TransactionCategory, description: String) {
        self.amount = amount
        self.currency = currency
        self.date = date
        self.category = category
        self.description = description
    }
}

// Budget represents a spending goal with a limit and progress tracking
class Budget: ObservableObject, BudgetProtocol, Identifiable, Codable {
    var id = UUID()
    var category: TransactionCategory
    var limit: Double
    var currency: Currency
    var period: BudgetPeriod
    var dueDate: Date?
    
    // Amount spent in this budget period; triggers updates on change
    var spent: Double {
        didSet {
            objectWillChange.send()
        }
    }
    
    // Amount remaining before reaching limit
    var remainingAmount: Double {
        max(0, limit - spent)
    }
    
    // Whether spending exceeded the budget limit
    var isOverBudget: Bool {
        spent > limit
    }
    
    init(category: TransactionCategory, limit: Double, currency: Currency, period: BudgetPeriod, dueDate: Date = Date(), spent: Double = 0.0) {
        self.category = category
        self.limit = limit
        self.currency = currency
        self.period = period
        self.dueDate = dueDate
        self.spent = spent
    }
}

// Reminder for payments or tasks with due dates and completion status
class Reminder: ObservableObject, ReminderProtocol, Identifiable, Codable {
    var id = UUID()
    var title: String
    var amount: Double?
    var dueDate: Date
    var isCompleted: Bool
    var reminderType: ReminderType
    
    // True if the reminder is overdue and not completed
    var isOverdue: Bool {
        !isCompleted && dueDate < Date()
    }
    
    // True if due within the next 7 days and not completed
    var isDueSoon: Bool {
        !isCompleted && dueDate <= Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    }
    
    init(title: String, amount: Double? = nil, dueDate: Date, reminderType: ReminderType) {
        self.title = title
        self.amount = amount
        self.dueDate = dueDate
        self.isCompleted = false
        self.reminderType = reminderType
    }
}

// CurrencyConverter handles conversion based on fixed exchange rates
class CurrencyConverter: ObservableObject, CurrencyConvertible {
    private let exchangeRates: [String: Double] = [
        "AUD_INR": 55.0,
        "INR_AUD": 0.018,
        "AUD_USD": 0.67,
        "USD_AUD": 1.49,
        "INR_USD": 0.012,
        "USD_INR": 83.0,
        "AUD_EUR": 0.61,
        "EUR_AUD": 1.64,
        "AUD_GBP": 0.53,
        "GBP_AUD": 1.89
    ]
    
    // Converts an amount from one currency to another
    func convert(amount: Double, from: Currency, to: Currency) -> Double {
        if from == to { return amount }
        
        let key = "\(from.rawValue)_\(to.rawValue)"
        let rate = exchangeRates[key] ?? 1.0
        return amount * rate
    }
    
    // Returns the exchange rate from one currency to another
    func getExchangeRate(from: Currency, to: Currency) -> Double {
        if from == to { return 1.0 }
        let key = "\(from.rawValue)_\(to.rawValue)"
        return exchangeRates[key] ?? 1.0
    }
}
