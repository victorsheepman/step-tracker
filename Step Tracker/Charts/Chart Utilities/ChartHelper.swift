//
//  ChartHelper.swift
//  Step Tracker
//
//  Created by Victor Marquez on 9/7/24.
//

import Foundation

struct ChartHelper {
    static func convert(data:[HealthMetric]) -> [DateValueChartData] {
       data.map { DateValueChartData(date: $0.date, value: $0.value) }
    }
    
    static func averageValue(for data:[DateValueChartData]) -> Double {
        guard !data.isEmpty else { return 0 }
        let totalSteps = data.reduce(0) { $0 + $1.value }
        return totalSteps/Double(data.count)
    }
    
    static func parseSelectedData(from data:[DateValueChartData], in selectedDate:Date?)->DateValueChartData? {
        guard let selectedDate else { return nil}
        return data.first{
            Calendar.current.isDate(selectedDate, inSameDayAs: $0.date)
        }
    }
}
