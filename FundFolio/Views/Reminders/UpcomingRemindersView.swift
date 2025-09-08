//
//  UpcomingRemindersView.swift
//  testAssignment1
//
//  Created by Janhavi Jagtap on 3/9/2025.
//

import SwiftUI

struct UpcomingRemindersView: View {
    @EnvironmentObject var dataManager: DataManager
    
    //let reminders: [Reminder]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Upcoming Reminders")
                    .font(.title)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                Spacer()
                NavigationLink("See All", destination: RemindersView())
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            if dataManager.reminders.isEmpty {
                Text("No upcoming reminders")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                LazyVStack {
                    ForEach(dataManager.reminders) { reminder in
                        ReminderRowView(reminder: reminder)
                    }
                }
            }
        }
    }
}

#Preview {
    UpcomingRemindersView()
}
