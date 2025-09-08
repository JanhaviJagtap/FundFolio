//
//  SwiftUIView.swift
//  FundFolio
//
//  Created by Janhavi Jagtap on 7/9/2025.
//
import SwiftUI

struct GoalsRowView: View {
    @ObservedObject var goal: Budget

    // Calculate progress as spent/limit
    var progress: Double {
        goal.limit > 0 ? goal.spent / goal.limit : 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(goal.category.rawValue.capitalized)
                        .font(.headline)
                    
                    // Show due date if set, else show warning text
                    if goal.dueDate != nil {
                        Text("Due: \(goal.dueDate!, style: .date)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("No due date set")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    // Show spent and limit values
                    Text("$\(goal.spent, specifier: "%.2f") / $\(goal.limit, specifier: "%.2f")")
                        .font(.body)
                    // Show progress percentage with color coding
                    Text("\(progress * 100, specifier: "%.0f")%")
                        .font(.caption)
                        .foregroundColor(progress >= 1 ? .green : .primary)
                }
            }
            // Progress bar with color indicating status
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: progress >= 1 ? .green : .blue))
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    GoalsRowView(goal: Budget(category: .food, limit: 500, currency: .aud, period: .weekly))
}
