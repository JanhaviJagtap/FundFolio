//
//  AddReminderView.swift
//
//  Created by Janhavi Jagtap on 3/9/2025.
//

import SwiftUI

struct AddReminderView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var amount = ""
    @State private var dueDate = Date()
    @State private var selectedType: ReminderType = .rent
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Reminder Details")) {
                    TextField("Title", text: $title)  // Title input
                    
                    Picker("Type", selection: $selectedType) {
                        ForEach(ReminderType.allCases) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.rawValue)
                            }.tag(type)
                        }
                    } // Reminder type picker
                    
                    HStack {
                        Text("Amount (Optional):")
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                    } // Optional amount input
                    
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute]) // Date and time picker
                }
            }
            .navigationTitle("Add Reminder")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }, trailing: Button("Save") {
                    saveReminder()
                }
            )
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // Validate and save reminder
    private func saveReminder() {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "Please enter a title for the reminder"
            showingAlert = true
            return
        }
        
        let amountDouble: Double? = {
            guard !amount.isEmpty, let value = Double(amount), value > 0 else {
                return nil
            }
            return value
        }()
        
        let reminder = Reminder(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: amountDouble,
            dueDate: dueDate,
            reminderType: selectedType
        )
        
        dataManager.addReminder(reminder)
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    AddReminderView()
}
