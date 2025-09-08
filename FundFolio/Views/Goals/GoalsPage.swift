//
//  GoalsPage.swift
//  FundFolio
//
//  Created by Janhavi Jagtap on 26/8/2025.
//
import Foundation
import SwiftUI

struct GoalsPage: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddBudget = false
    @State private var showingAddGoal = false
    @State private var selectedSegment = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("LightYellow") // Background color
                    .ignoresSafeArea()

                VStack {
                    GoalsListView() // List of goals/budgets
                }
                .background(Color("LightYellow"))
                .navigationTitle("Goals")
                .toolbar {
                    Button(action: {
                        showingAddGoal = true // Show AddBudget sheet
                    }) {
                        Image(systemName: "plus")
                    }
                }
                .sheet(isPresented: $showingAddGoal) {
                    AddBudgetView() // Sheet to add a new budget/goal
                }
                .scrollContentBackground(.hidden) // Remove default scroll background
            }
        }
    }
    
    // Delete budgets from DataManager
    func deleteBudgets(offsets: IndexSet) {
        for index in offsets {
            dataManager.deleteBudget(dataManager.budgets[index])
        }
    }
}

struct GoalsListView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        VStack {
            List {
                ForEach(dataManager.budgets) { goal in
                    GoalsRowView(goal: goal) // Render budget row
                }
                .onDelete(perform: deleteGoals)
            }
            .background(Color("LightYellow"))
        }
    }
    
    // Delete goals from data manager
    private func deleteGoals(offsets: IndexSet) {
        offsets.forEach { index in
            dataManager.deleteBudget(dataManager.budgets[index])
        }
    }
}

#Preview {
    GoalsPage()
        .environmentObject(DataManager())
}
