//
//  FundFolioApp.swift
//  FundFolio
//
//  Created by Janhavi Jagtap on 26/8/2025.
//

import SwiftUI

@main
struct FundFolioApp: App {
    @StateObject private var dataManager = DataManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
        }
    }
}
