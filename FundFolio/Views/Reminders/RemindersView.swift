//
//  RemindersView.swift
//  testAssignment1
//
//  Created by Janhavi Jagtap on 3/9/2025.
//
import SwiftUI

struct RemindersView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddReminder = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("LightYellow") // Background color
                    .ignoresSafeArea()
                
                // List of reminders sorted by due date
                List {
                    ForEach(dataManager.reminders.sorted(by: { $0.dueDate < $1.dueDate })) { reminder in
                        ReminderRowView(reminder: reminder)
                    }
                    .onDelete(perform: deleteReminders)
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Reminders")
                .toolbar {
                    Button(action: { showingAddReminder = true }) {
                        Image(systemName: "plus") // Add reminder button
                    }
                }
                .sheet(isPresented: $showingAddReminder) {
                    AddReminderView() // Sheet to add new reminder
                }
            }
        }
    }
    
    // Delete reminders at selected offsets
    func deleteReminders(offsets: IndexSet) {
        let sortedReminders = dataManager.reminders.sorted { $0.dueDate < $1.dueDate }
        for index in offsets {
            dataManager.deleteReminder(sortedReminders[index])
        }
    }
}

#Preview {
    RemindersView()
        .environmentObject(DataManager())
}
