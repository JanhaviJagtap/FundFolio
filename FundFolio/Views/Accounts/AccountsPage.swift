//
//  AccountsPage.swift
//  FundFolio
//
//  Created by Janhavi Jagtap on 26/8/2025.
//

import SwiftUI

struct AccountsPage: View {
    @EnvironmentObject var dataManager: DataManager
    @ObservedObject var myvm: AccountsViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    
                    // List all accounts with navigation to details
                    ForEach(myvm.myAccounts) { myAccount in
                        NavigationLink(destination: AccountDetailsPage(myvm: myvm, account: myAccount)) {
                            HStack(spacing: 16) {
                                // Show currency icon if available, else default icon
                                if let currencyEnum = Currency(rawValue: myAccount.currency) {
                                    Image(systemName: currencyEnum.icon)
                                        .font(.system(size: 20))
                                        .frame(width: 25)
                                        .foregroundColor(.black)
                                } else {
                                    Image(systemName: "dollarsign")
                                        .font(.system(size: 25))
                                        .foregroundColor(.black)
                                }
                                
                                // Display bank name and currency code
                                VStack(alignment: .leading) {
                                    Text(myAccount.bankName)
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.leading)
                                    Text("\(myAccount.currency)")
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                }
                                
                                Spacer()
                                
                                // Show currency symbol and formatted amount
                                Text("\(myAccount.currency) \(myAccount.amount, specifier: "%.2f")")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .bold()
                            }
                            .padding()
                            .background(Color(hue: 0.257, saturation: 0.275, brightness: 0.849))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .navigationTitle("Accounts")
            .background(Color("LightYellow"))
        }
    }
}

#Preview {
    AccountsPage(myvm: AccountsViewModel())
}
