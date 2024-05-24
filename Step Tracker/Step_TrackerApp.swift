//
//  Step_TrackerApp.swift
//  Step Tracker
//
//  Created by Victor Marquez on 20/5/24.
//

import SwiftUI

@main
struct Step_TrackerApp: App {
    
    let hkManager = HealthKitManager()
    
    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(hkManager)
        }
    }
}
