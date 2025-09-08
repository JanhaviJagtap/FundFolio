//
//  LoanViews.swift
//  FundFolio
//
//  Created by Janhavi Jagtap on 7/9/2025.
//

import SwiftUI
import Foundation

/// Displays list of loans with option to add or delete loans.
struct LoanListPage: View {
    @EnvironmentObject var accountsViewModel: AccountsViewModel          // Provides user bank accounts
    @StateObject private var loanVM: LoanAccountsViewModel               // Manages loan data
    @State private var showingAddLoan = false                            // Controls Add Loan modal visibility
    
    init(bankAccounts: [Accounts]) {
        _loanVM = StateObject(wrappedValue: LoanAccountsViewModel(bankAccounts: bankAccounts))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("LightYellow").ignoresSafeArea()                  // Background color
                
                List {
                    ForEach(loanVM.loans) { loan in
                        NavigationLink(destination: LoanDetailPage(loan: loan, loanVM: loanVM)) {
                            LoanRowView(loan: loan)
                        }
                    }
                    .onDelete(perform: deleteLoans)                      // Enable swipe to delete loans
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Education Loans")
            .toolbar {
                Button(action: { showingAddLoan = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddLoan) {
                AddLoanView(bankAccounts: accountsViewModel.myAccounts, loanVM: loanVM)
            }
        }
    }
    
    /// Deletes loans at specified indices from the list.
    private func deleteLoans(offsets: IndexSet) {
        for index in offsets {
            loanVM.removeAccount(loanVM.loans[index])
        }
    }
}

/// Shows summary info for a loan: bank name, loan amount, EMI, and payment progress.
struct LoanRowView: View {
    @ObservedObject var loan: LoanAccount
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(loan.bankName)
                    .font(.headline)
                Spacer()
                Text("\(loan.currency) \(loan.loanAmount, specifier: "%.0f")")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("EMI: \(loan.currency) \(loan.emiAmount, specifier: "%.0f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(loan.emiPaidCount)/\(loan.tenureMonths) paid")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: Double(loan.emiPaidCount), total: Double(loan.tenureMonths))
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
        }
        .padding(.vertical, 4)
    }
}

/// Detailed loan view showing loan info, progress, linked account, and EMI payment button.
struct LoanDetailPage: View {
    @EnvironmentObject var accountsViewModel: AccountsViewModel
    @ObservedObject var loan: LoanAccount
    @ObservedObject var loanVM: LoanAccountsViewModel
    @State private var showingAlert = false
    @State private var alertMessage = ""

    /// Retrieves the linked bank account if one is assigned.
    var linkedAccount: Accounts? {
        guard let id = loan.linkedBankAccountId else { return nil }
        return accountsViewModel.getAccount(by: id)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text(loan.bankName)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Education Loan")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Loan details card with important loan info
                VStack(spacing: 16) {
                    LoanDetailRow(title: "Loan Amount", value: "\(loan.currency) \(loan.loanAmount)")
                    LoanDetailRow(title: "Interest Rate", value: "\(loan.interestRate)%")
                    LoanDetailRow(title: "Tenure", value: "\(loan.tenureMonths) months")
                    LoanDetailRow(title: "EMI Amount", value: "\(loan.currency) \(loan.emiAmount)")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // EMI payment progress section
                VStack(spacing: 12) {
                    Text("Progress").font(.headline)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("EMIs Paid")
                            Spacer()
                            Text("\(loan.emiPaidCount) / \(loan.tenureMonths)")
                        }
                        
                        ProgressView(value: Double(loan.emiPaidCount), total: Double(loan.tenureMonths))
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        
                        HStack {
                            Text("Outstanding Amount")
                            Spacer()
                            Text("\(loan.currency) \(loan.outstanding, specifier: "%.2f")")
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Displays linked bank account info
                if let account = linkedAccount {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Linked Account")
                            .font(.headline)
                        HStack {
                            Text(account.bankName)
                            Spacer()
                            Text("\(account.currency) \(account.amount, specifier: "%.2f")")
                                .fontWeight(.medium)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Pay next EMI button, disabled if no EMIs left
                Button(action: payNextEmi) {
                    HStack {
                        Image(systemName: "creditcard")
                        Text("Pay Next EMI")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(loan.emiLeft > 0 ? Color.blue : Color.gray)
                    .cornerRadius(10)
                }
                .disabled(loan.emiLeft == 0)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Loan Details")
        .alert("EMI Payment", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    /// Handles payment of next EMI and sets appropriate alert message.
    private func payNextEmi() {
        if loanVM.payNextEmi(for: loan, using: accountsViewModel) {
            alertMessage = "EMI payment successful!"
        } else {
            alertMessage = loan.emiLeft == 0 ? "All EMIs have been paid." : "Insufficient funds in linked account."
        }
        showingAlert = true
    }
}

/// Simple reusable view showing a title and value in a row for loan details.
struct LoanDetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title).foregroundColor(.secondary)
            Spacer()
            Text(value).fontWeight(.medium)
        }
    }
}

/// Form view to add a new loan with input validation and saving to loan view model.
struct AddLoanView: View {
    @Environment(\.dismiss) var dismiss
    let bankAccounts: [Accounts]
    @ObservedObject var loanVM: LoanAccountsViewModel
    
    @State private var bankName = ""
    @State private var loanAmount = ""
    @State private var interestRate = ""
    @State private var tenureMonths = ""
    @State private var selectedCurrency = "INR"
    @State private var selectedLinkedAccount: Accounts?
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Loan Details")) {
                    TextField("Bank Name", text: $bankName)
                    TextField("Loan Amount", text: $loanAmount)
                        .keyboardType(.decimalPad)
                    TextField("Interest Rate (%)", text: $interestRate)
                        .keyboardType(.decimalPad)
                    TextField("Tenure (Months)", text: $tenureMonths)
                        .keyboardType(.numberPad)
                    
                    Picker("Currency", selection: $selectedCurrency) {
                        Text("INR").tag("INR")
                        Text("AUD").tag("AUD")
                        Text("USD").tag("USD")
                    }
                }
                
                Section(header: Text("Link Bank Account (Optional)")) {
                    Picker("Select Account", selection: $selectedLinkedAccount) {
                        Text("None").tag(nil as Accounts?)
                        ForEach(bankAccounts) { account in
                            Text("\(account.bankName) - \(account.currency)").tag(account as Accounts?)
                        }
                    }
                }
            }
            .navigationTitle("Add Loan")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveLoan() }
                        .disabled(!isFormValid)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .scrollContentBackground(.hidden)
    }
    
    /// Validates form inputs before allowing save.
    private var isFormValid: Bool {
        !bankName.isEmpty &&
        Double(loanAmount) != nil &&
        Double(interestRate) != nil &&
        Int(tenureMonths) != nil
    }
    
    /// Creates a new LoanAccount and stores it via loan view model.
    private func saveLoan() {
        guard let amount = Double(loanAmount),
              let rate = Double(interestRate),
              let tenure = Int(tenureMonths) else { return }
        
        let loan = LoanAccount(
            bankName: bankName,
            currency: selectedCurrency,
            loanAmount: amount,
            interestRate: rate,
            tenureMonths: tenure,
            linkedBankAccountId: selectedLinkedAccount?.accountId
        )
        
        loanVM.addLoanAccount(loan)
        dismiss()
    }
}

#Preview {
    LoanListPage(bankAccounts: [
        Accounts(bankName: "SBI", currency: "INR", amount: 100000.00)
    ])
}
