//
//  AccountData.swift
//  FundFolio
//
//  Created by Janhavi Jagtap on 28/8/2025.
//

import Foundation

// Represents a bank account with unique ID, bank name, currency, and a mutable balance amount.
// Supports observation through `ObservableObject` and persistence via `Codable`.
class Accounts: Identifiable, Codable, ObservableObject, Hashable {
    var accountId: UUID = UUID()              // Unique identifier for the account
    let bankName: String                      // Bank name (immutable)
    let currency: String                      // Currency code (immutable)
    @Published var amount: Double             // Account balance; publishes changes for UI updates
    
    init(accountId: UUID = UUID(), bankName: String, currency: String, amount: Double) {
        self.accountId = accountId
        self.bankName = bankName
        self.currency = currency
        self.amount = amount
    }
    
    // Codable conformance for decoding from storage or JSON
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accountId = try container.decode(UUID.self, forKey: .accountId)
        bankName = try container.decode(String.self, forKey: .bankName)
        currency = try container.decode(String.self, forKey: .currency)
        amount = try container.decode(Double.self, forKey: .amount)
    }
    
    // Codable conformance for encoding to storage or JSON
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accountId, forKey: .accountId)
        try container.encode(bankName, forKey: .bankName)
        try container.encode(currency, forKey: .currency)
        try container.encode(amount, forKey: .amount)
    }
    
    enum CodingKeys: CodingKey {
        case accountId, bankName, currency, amount
    }

    // Hashable conformance for use in sets or dictionaries
    func hash(into hasher: inout Hasher) {
        hasher.combine(accountId)
        hasher.combine(bankName)
        hasher.combine(currency)
        hasher.combine(amount)
    }

    // Equatable conformance for comparing account objects
    static func == (lhs: Accounts, rhs: Accounts) -> Bool {
        return lhs.accountId == rhs.accountId &&
               lhs.bankName == rhs.bankName &&
               lhs.currency == rhs.currency &&
               lhs.amount == rhs.amount
    }
    
    /// Errors related to account operations
    enum AccountError: Error, LocalizedError {
        case insufficientFunds(available: Double, attempted: Double)
        
        var errorDescription: String? {
            switch self {
            case .insufficientFunds(let available, let attempted):
                return "Insufficient funds. Tried to withdraw \(attempted), but only \(available) is available."
            }
        }
    }

    /// Attempts to withdraw the requested amount from the account.
    /// Throws an error if funds are insufficient.
    /// - Parameter withdrawAmount: Amount to withdraw
    func withdraw(amount withdrawAmount: Double) throws {
        guard withdrawAmount <= amount else {
            throw AccountError.insufficientFunds(available: amount, attempted: withdrawAmount)
        }
        amount -= withdrawAmount
    }
}

/// Represents a savings or financial goal with title, target, amount saved, and deadline.
struct Goal: Identifiable, Codable {
    var id = UUID()
    let title: String
    let targetAmount: Double
    var savedAmount: Double
    let deadline: Date
}

/// Represents a loan account inheriting from Accounts, including loan-specific data and computations.
class LoanAccount: Accounts {
    let loanAmount: Double                   // Original loan amount
    let interestRate: Double                 // Annual interest rate as percentage
    let tenureMonths: Int                    // Duration of loan in months
    @Published var emiPaidCount: Int         // Number of EMIs paid so far
    var linkedBankAccountId: UUID?           // Optional linked bank account ID for payment
    
    init(
        accountId: UUID = UUID(),
        bankName: String,
        currency: String,
        loanAmount: Double,
        interestRate: Double,
        tenureMonths: Int,
        emiPaidCount: Int = 0,
        linkedBankAccountId: UUID? = nil
    ) {
        self.loanAmount = loanAmount
        self.interestRate = interestRate
        self.tenureMonths = tenureMonths
        self.emiPaidCount = emiPaidCount
        self.linkedBankAccountId = linkedBankAccountId
        super.init(accountId: accountId, bankName: bankName, currency: currency, amount: loanAmount)
    }
    
    // Codable init for loan-specific properties along with inherited ones
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: LoanCodingKeys.self)
        loanAmount = try container.decode(Double.self, forKey: .loanAmount)
        interestRate = try container.decode(Double.self, forKey: .interestRate)
        tenureMonths = try container.decode(Int.self, forKey: .tenureMonths)
        emiPaidCount = try container.decode(Int.self, forKey: .emiPaidCount)
        linkedBankAccountId = try container.decodeIfPresent(UUID.self, forKey: .linkedBankAccountId)
        try super.init(from: decoder)
    }
    
    // Codable encode for loan-specific properties along with inherited ones
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: LoanCodingKeys.self)
        try container.encode(loanAmount, forKey: .loanAmount)
        try container.encode(interestRate, forKey: .interestRate)
        try container.encode(tenureMonths, forKey: .tenureMonths)
        try container.encode(emiPaidCount, forKey: .emiPaidCount)
        try container.encodeIfPresent(linkedBankAccountId, forKey: .linkedBankAccountId)
        try super.encode(to: encoder)
    }
    
    enum LoanCodingKeys: CodingKey {
        case loanAmount, interestRate, tenureMonths, emiPaidCount, linkedBankAccountId
    }
    
    /// Computed EMI amount per month based on loan details and interest
    var emiAmount: Double {
        let r = interestRate / 12.0 / 100.0
        let n = Double(tenureMonths)
        guard r > 0 else { return loanAmount / n }
        return (loanAmount * r * pow(1 + r, n)) / (pow(1 + r, n) - 1)
    }
    
    /// Remaining number of EMIs to be paid
    var emiLeft: Int { max(0, tenureMonths - emiPaidCount) }
    
    /// Total amount paid so far (EMI count multiplied by EMI amount)
    var paidAmount: Double { Double(emiPaidCount) * emiAmount }
    
    /// Outstanding amount based on paid and total EMIs
    var outstanding: Double { max(0, emiAmount * Double(tenureMonths) - paidAmount) }
}
