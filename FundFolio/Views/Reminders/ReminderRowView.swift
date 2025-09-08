//
//  ReminderRowView.swift
//  testAssignment1
//
//  Created by Janhavi Jagtap on 3/9/2025.
//
import SwiftUI

struct ReminderRowView: View {
    @ObservedObject var reminder: Reminder
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        HStack {
            // Reminder icon colored red if overdue, else orange
            Image(systemName: reminder.reminderType.icon)
                .foregroundColor(reminder.isOverdue ? .red : .orange)
                .frame(width: 24, height: 24)
            
            // Title and optional amount
            VStack(alignment: .leading) {
                Text(reminder.title)
                    .font(.body)
                if let amount = reminder.amount {
                    Text("Amount: $\(amount, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Due date and overdue status
            VStack(alignment: .trailing) {
                Text(reminder.dueDate, style: .date)
                    .font(.caption)
                    .foregroundColor(reminder.isOverdue ? .red : .secondary)
                if reminder.isOverdue {
                    Text("Overdue")
                        .font(.caption)
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        // Toggle completion state on tap
        .onTapGesture {
            dataManager.toggleReminderCompletion(reminder)
        }
    }
}

#Preview {
    // ReminderRowView(reminder: Reminder(...))
}
