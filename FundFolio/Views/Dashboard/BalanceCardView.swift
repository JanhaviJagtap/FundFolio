//
//  BalanceCardView.swift
//  testAssignment1
//
//  Created by Janhavi Jagtap on 3/9/2025.
//

import SwiftUI

/// A card view displaying total balance, income, and expenses in a selected currency
struct BalanceCardView: View {
    let totalBalance: Double      // Overall balance amount
    let income: Double            // Total income amount
    let expenses: Double          // Total expenses amount
    let currency: Currency        // Currency for display symbols
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Total Balance")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("\(currency.symbol)\(totalBalance, specifier: "%.2f")")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            HStack(spacing: 65) {
                VStack {
                    Text("Income")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(currency.symbol)\(income, specifier: "%.2f")")
                        .font(.headline)
                        .foregroundColor(Color(hue: 0.305, saturation: 1.0, brightness: 0.671)) // Greenish
                }
                
                VStack {
                    Text("Expenses")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(currency.symbol)\(expenses, specifier: "%.2f")")
                        .font(.headline)
                        .foregroundColor(Color(hue: 1.0, saturation: 0.972, brightness: 0.757)) // Reddish
                }
            }
        }
        .padding(30)
        .frame(width: 340)
        .background(Color(hue: 0.257, saturation: 0.275, brightness: 0.849)) // Light background
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    BalanceCardView(totalBalance: 4000, income: 150, expenses: 200, currency: .aud)
}
