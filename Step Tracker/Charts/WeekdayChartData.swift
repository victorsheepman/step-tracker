//
//  WeekdayChartData.swift
//  Step Tracker
//
//  Created by Victor Marquez on 26/5/24.
//

import Foundation

struct WeekdayChartData: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let value: Double
    
    
}
