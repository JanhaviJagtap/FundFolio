//
//  AppProtocols.swift
//  FundFolio
//
//  Created by Janhavi Jagtap on 28/8/2025.
//

import SwiftUI
import Foundation

// MARK: - Protocols

/// Protocol defining common requirements for financial transactions.
/// Includes properties for identifiers, amount, currency, date, category, and description.
protocol TransactionProtocol {
    var id: UUID { get }
    var amount: Double { get set }
    var currency: Currency { get set }
    var date: Date { get set }
    var category: TransactionCategory { get set }
    var description: String { get set }
}

/// Protocol defining requirements for a budget category.
/// Includes budget limit, spent amount, currency, and budgeting period.
protocol BudgetProtocol {
    var id: UUID { get }
    var category: TransactionCategory { get set }
    var limit: Double { get set }
    var spent: Double { get }
    var currency: Currency { get set }
    var period: BudgetPeriod { get set }
}

/// Protocol defining properties for financial reminders.
/// Includes title, optional amount, due date, completion status, and reminder type.
protocol ReminderProtocol {
    var id: UUID { get }
    var title: String { get set }
    var amount: Double? { get set }
    var dueDate: Date { get set }
    var isCompleted: Bool { get set }
    var reminderType: ReminderType { get set }
}

/// Protocol defining currency conversion capability.
protocol CurrencyConvertible {
    func convert(amount: Double, from: Currency, to: Currency) -> Double
}

// MARK: - Enum Definitions

/// Supported currencies with raw string values.
/// Provides identifiers, symbols, full names, and SF Symbols icons.
enum Currency: String, CaseIterable, Identifiable, Codable {
    case aud = "AUD"
    case inr = "INR"
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .aud: return "A$"
        case .inr: return "₹"
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        }
    }

    var name: String {
        switch self {
        case .aud: return "Australian Dollar"
        case .inr: return "Indian Rupee"
        case .usd: return "US Dollar"
        case .eur: return "Euro"
        case .gbp: return "British Pound"
        }
    }

    var icon: String {
        switch self {
        case .aud: return "australiandollarsign"
        case .inr: return "indianrupeesign"
        case .usd: return "dollarsign"
        case .eur: return "eurosign"
        case .gbp: return "sterlingsign"
        }
    }
}

// Categories for transactions, provides icons and colors for UI.
enum TransactionCategory: String, CaseIterable, Identifiable, Codable {
    case food = "Food"
    case transport = "Transport"
    case accommodation = "Accommodation"
    case education = "Education"
    case entertainment = "Entertainment"
    case income = "Income"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car"
        case .accommodation: return "house"
        case .education: return "book"
        case .entertainment: return "gamecontroller"
        case .income: return "plus.circle"
        case .other: return "questionmark.circle"
        }
    }

    var color: Color {
        switch self {
        case .food: return .orange
        case .transport: return .blue
        case .accommodation: return .green
        case .education: return .purple
        case .entertainment: return .pink
        case .income: return .mint
        case .other: return .gray
        }
    }
}

// Budgeting period options for budgets.
enum BudgetPeriod: String, CaseIterable, Identifiable, Codable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"

    var id: String { rawValue }
}

// Types of financial reminders with icons.
enum ReminderType: String, CaseIterable, Identifiable, Codable {
    case rent = "Rent"
    case tuition = "Tuition"
    case emi = "EMI"
    case bill = "Bill"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .rent: return "house.fill"
        case .tuition: return "graduationcap.fill"
        case .emi: return "creditcard.fill"
        case .bill: return "doc.text.fill"
        case .other: return "bell.fill"
        }
    }
}
