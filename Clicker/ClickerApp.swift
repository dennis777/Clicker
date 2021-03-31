//
//  ClickerApp.swift
//  Clicker
//
//  Created by Dennis Litvinenko on 3/31/21.
//

import SwiftUI

@main
struct ClickerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
