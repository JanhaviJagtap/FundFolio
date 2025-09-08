//
//  AccountsViewModel.swift
//  FundFolio
//
//  Created by Janhavi Jagtap on 28/8/2025.
//

import Foundation
import SwiftUI

/// Singleton manager for saving and loading user data to UserDefaults
class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private let accountsKey = "userAccounts"
    private let loansKey = "userLoans"
    private let remindersKey = "userReminders"
    private let goalsKey = "userGoals"

    private init() {}

    // Save and load accounts
    func saveAccounts(_ accounts: [Accounts]) {
        if let data = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(data, forKey: accountsKey)
        }
    }
    
    func loadAccounts() -> [Accounts] {
        guard let data = UserDefaults.standard.data(forKey: accountsKey) else { return [] }
        return (try? JSONDecoder().decode([Accounts].self, from: data)) ?? []
    }

    // Save and load loans
    func saveLoans(_ loans: [LoanAccount]) {
        if let data = try? JSONEncoder().encode(loans) {
            UserDefaults.standard.set(data, forKey: loansKey)
        }
    }
    
    func loadLoans() -> [LoanAccount] {
        guard let data = UserDefaults.standard.data(forKey: loansKey) else { return [] }
        return (try? JSONDecoder().decode([LoanAccount].self, from: data)) ?? []
    }
    
    // Save and load reminders
    func saveReminders(_ reminders: [Reminder]) {
        if let data = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(data, forKey: remindersKey)
        }
    }
    
    func loadReminders() -> [Reminder] {
        guard let data = UserDefaults.standard.data(forKey: remindersKey) else { return [] }
        return (try? JSONDecoder().decode([Reminder].self, from: data)) ?? []
    }
    
    // Save and load budgets/goals
    func saveGoals(_ budgets: [Budget]) {
        if let data = try? JSONEncoder().encode(budgets) {
            UserDefaults.standard.set(data, forKey: goalsKey)
        }
    }
    
    func loadGoals() -> [Budget] {
        guard let data = UserDefaults.standard.data(forKey: goalsKey) else { return [] }
        return (try? JSONDecoder().decode([Budget].self, from: data)) ?? []
    }
}

// View model managing user accounts; synchronizes with UserDefaults
class AccountsViewModel: ObservableObject {
    @Published var myAccounts: [Accounts] = [] {
        didSet { UserDefaultsManager.shared.saveAccounts(myAccounts) }
    }
    
    init() {
        myAccounts = UserDefaultsManager.shared.loadAccounts()
        if myAccounts.isEmpty {
            loadSampleAccounts()
        }
    }
    
    private func loadSampleAccounts() {
        myAccounts = [
            Accounts(bankName: "SBI", currency: "INR", amount: 100000.00),
            Accounts(bankName: "HDFC", currency: "INR", amount: 200000.00),
            Accounts(bankName: "Standard Chartered", currency: "INR", amount: 20000.00),
            Accounts(bankName: "Commonwealth Bank", currency: "AUD", amount: 4000.00),
            Accounts(bankName: "Westpac Bank", currency: "AUD", amount: 640.00)
        ]
    }
    
    func addAccount(_ account: Accounts) {
        myAccounts.append(account)
    }
    
    func removeAccount(_ account: Accounts) {
        myAccounts.removeAll { $0.accountId == account.accountId }
    }
    
    func getAccount(by id: UUID) -> Accounts? {
        return myAccounts.first { $0.accountId == id }
    }
}

// ViewModel for dashboard data aggregation and conversion
class DashboardViewModel: ObservableObject {
    @Published var selectedCurrency: Currency = .aud
    var dataManager: DataManager
    var accountsViewModel: AccountsViewModel
    
    private let currencyConverter = CurrencyConverter()
    
    init(dataManager: DataManager, accountsViewModel: AccountsViewModel) {
        self.dataManager = dataManager
        self.accountsViewModel = accountsViewModel
    }
    
    /// Total balance as sum of account balances and transactions converted to selected currency
    var totalBalance: Double {
        let accountBalance = getTotalAccountBalance(in: selectedCurrency)
        let transactionBalance = dataManager.getTotalBalance(in: selectedCurrency)
        return accountBalance + transactionBalance
    }
    
    var totalIncome: Double {
        dataManager.getIncomeAmount(in: selectedCurrency)
    }
    
    var totalExpenses: Double {
        dataManager.getExpenseAmount(in: selectedCurrency)
    }
    
    var upcomingReminders: [Reminder] {
        dataManager.getUpcomingReminders()
    }
    
    var recentTransactions: [Transaction] {
        Array(dataManager.transactions.sorted { $0.date > $1.date }.prefix(5))
    }
    
    // Calculate total balance of all linked bank accounts converted to selected currency
    private func getTotalAccountBalance(in currency: Currency) -> Double {
        return accountsViewModel.myAccounts.reduce(0.0) { total, account in
            guard let accountCurrency = Currency(rawValue: account.currency) else { return total }
            let convertedAmount = currencyConverter.convert(
                amount: account.amount,
                from: accountCurrency,
                to: currency
            )
            return total + convertedAmount
        }
    }
    
    func getAccountBalance(in currency: Currency) -> Double {
        getTotalAccountBalance(in: currency)
    }
}

// View model managing loan accounts and payment logic
class LoanAccountsViewModel: ObservableObject {
    @Published var loans: [LoanAccount] = [] {
        didSet { UserDefaultsManager.shared.saveLoans(loans) }
    }
    
    private var bankAccounts: [Accounts]
    
    init(bankAccounts: [Accounts]) {
        self.bankAccounts = bankAccounts
        loans = UserDefaultsManager.shared.loadLoans()
        if loans.isEmpty {
            loadSampleLoans()
        }
    }
    
    private func loadSampleLoans() {
        loans = [
            LoanAccount(
                bankName: "ICICI Bank",
                currency: "INR",
                loanAmount: 4000000,
                interestRate: 9.5,
                tenureMonths: 60,
                emiPaidCount: 12
            )
        ]
    }
    
    func addLoanAccount(_ account: LoanAccount) {
        loans.append(account)
    }
    
    func removeAccount(_ account: LoanAccount) {
        loans.removeAll { $0.accountId == account.accountId }
    }
    
    /// Pays next EMI by deducting from linked bank account if sufficient funds
    /// Returns true if payment succeeded
    func payNextEmi(for loan: LoanAccount, using accountsViewModel: AccountsViewModel) -> Bool {
        guard loan.emiLeft > 0 else { return false }
        
        if let linkedAccountId = loan.linkedBankAccountId,
           let linkedAccount = accountsViewModel.getAccount(by: linkedAccountId) {
            guard linkedAccount.amount >= loan.emiAmount else { return false }
            linkedAccount.amount -= loan.emiAmount
        }
        
        loan.emiPaidCount += 1
        return true
    }
}
