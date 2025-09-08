//
//  DashboardView.swift
//  testAssignment1
//
//  Created by Janhavi Jagtap on 28/8/2025.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject var viewModel: DashboardViewModel
    var myvm: AccountsViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Currency selector dropdown
                    HStack {
                        Text("Currency:")
                        Picker("Currency", selection: $viewModel.selectedCurrency) {
                            ForEach(Currency.allCases) { currency in
                                Text(currency.symbol).tag(currency)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Summary balance card
                    BalanceCardView(
                        totalBalance: viewModel.totalBalance,
                        income: viewModel.totalIncome,
                        expenses: viewModel.totalExpenses,
                        currency: viewModel.selectedCurrency
                    )
                    
                    Spacer()
                    
                    // List of upcoming reminders
                    UpcomingRemindersView()
                        .padding(.vertical, 50)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .background(Color("LightYellow"))
        }
    }
}

#Preview {
    DashboardView(
        viewModel: DashboardViewModel(
            dataManager: DataManager(),
            accountsViewModel: AccountsViewModel()
        ),
        myvm: AccountsViewModel()
    )
    .environmentObject(DataManager())
}
