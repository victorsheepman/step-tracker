//
//  HealthMetric.swift
//  Step Tracker
//
//  Created by Victor Marquez on 25/5/24.
//

import Foundation

struct HealthMetric: Identifiable {
    let id = UUID()
    let date:  Date
    let value: Double
}
