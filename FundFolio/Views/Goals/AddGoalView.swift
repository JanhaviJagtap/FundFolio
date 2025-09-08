//
//  AddGoalView.swift
//  FundFolio
//
//  Created by Janhavi Jagtap on 8/9/2025.
//

import SwiftUI

/// View to add a new budget with category, limit, currency, period and due date selection
struct AddBudgetView: View {
    @Environment(\.dismiss) var dismiss               // Environment value to dismiss the view
    @EnvironmentObject var dataManager: DataManager    // Shared data manager for adding budgets

    @State private var selectedCategory: TransactionCategory = .food  // Selected expense category
    @State private var limitAmount = ""                                 // User input limit amount as text
    @State private var selectedCurrency: Currency = .aud               // Selected currency for budget
    @State private var selectedPeriod: BudgetPeriod = .monthly         // Budget period selection
    @State private var dueDate: Date = Date()                          // Budget due date (not used in Budget model here)

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Budget Details")) {
                    // Category picker excluding "Income"
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(TransactionCategory.allCases.filter { $0 != .income }) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                Text(category.rawValue)
                            }.tag(category)
                        }
                    }

                    // Limit amount input with decimal keyboard
                    TextField("Limit Amount", text: $limitAmount)
                        .keyboardType(.decimalPad)

                    // Currency picker
                    Picker("Currency", selection: $selectedCurrency) {
                        ForEach(Currency.allCases) { currency in
                            Text(currency.name).tag(currency)
                        }
                    }

                    // Budget period picker (weekly, monthly, yearly)
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(BudgetPeriod.allCases) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }

                    // Due date picker (currently not persisted in Budget model)
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Budget")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    // Save button adds new budget and dismisses form
                    Button("Save") {
                        guard let limit = Double(limitAmount), limit > 0 else { return }

                        let budget = Budget(
                            category: selectedCategory,
                            limit: limit,
                            currency: selectedCurrency,
                            period: selectedPeriod
                        )
                        // If Budget supports dueDate, set here: budget.dueDate = dueDate

                        dataManager.addBudget(budget)
                        dismiss()
                    }
                    .disabled(limitAmount.isEmpty || Double(limitAmount) == nil)  // Disable if invalid input
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }  // Cancel button dismisses form
                }
            }
        }
    }
}

#Preview {
    AddBudgetView()
}
