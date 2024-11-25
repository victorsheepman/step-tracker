//
//  HealthMetricContext.swift
//  Step Tracker
//
//  Created by Victor Marquez on 25/11/24.
//

import Foundation

enum HealthMetricContext: CaseIterable, Identifiable{
    case steps, weight
    var id: Self { self }
    var title: String {
        switch self {
        case .steps:
            return "Steps"
        case .weight:
            return "Weight"
        }
    }
}
