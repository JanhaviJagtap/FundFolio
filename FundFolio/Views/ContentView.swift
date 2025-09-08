//
//  ContentView.swift
//  FundFolio
//
//  Created by Janhavi Jagtap on 26/8/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager()
    @StateObject private var accountsViewModel = AccountsViewModel()
    @StateObject private var dashboardViewModel: DashboardViewModel
    @StateObject private var loanAccountsViewModel: LoanAccountsViewModel
    
    init() {
        let tempAccountsVM = AccountsViewModel()
        let tempDataManager = DataManager()
        _dashboardViewModel = StateObject(wrappedValue: DashboardViewModel(dataManager: tempDataManager, accountsViewModel: tempAccountsVM))
        _loanAccountsViewModel = StateObject(wrappedValue: LoanAccountsViewModel(bankAccounts: tempAccountsVM.myAccounts))
    }
    
    var body: some View {
        TabView {
            // Dashboard Tab
            DashboardView(viewModel: dashboardViewModel, myvm: accountsViewModel)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
            
            // Accounts Tab
            AccountsPage(myvm: accountsViewModel)
                .tabItem {
                    Image(systemName: "creditcard.fill")
                    Text("Accounts")
                }
            
            // Loans Tab
            LoanListPage(bankAccounts: accountsViewModel.myAccounts)
                .tabItem {
                    Image(systemName: "banknote.fill")
                    Text("Loans")
                }
            
            // Goals & Budgets Tab
            GoalsPage()
                .tabItem {
                    Image(systemName: "target")
                    Text("Goals")
                }
            
            // Reminders Tab
            RemindersView()
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text("Reminders")
                }
        }
        .environmentObject(dataManager)
        .environmentObject(accountsViewModel)
        .environmentObject(loanAccountsViewModel)
        .onAppear {
            dashboardViewModel.dataManager = dataManager
            dashboardViewModel.accountsViewModel = accountsViewModel
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DataManager())
}
