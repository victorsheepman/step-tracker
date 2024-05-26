//
//  ChartMath.swift
//  Step Tracker
//
//  Created by Victor Marquez on 26/5/24.
//

import Foundation
import Algorithms
struct ChartMath {
    
    static func averageWeekdauCount(for metric: [HealthMetric]) -> [WeekdayChartData] {
        
        let sortedByWeekday = metric.sorted { $0.date.weekdayInt < $1.date.weekdayInt }
        let weekdayArray = sortedByWeekday.chunked { $0.date.weekdayInt == $1.date.weekdayInt }
        
        var weekdayChartData:[WeekdayChartData] = []
        
        for array in weekdayArray {
            guard let firstValue = array.first else { continue }
            let total = array.reduce(0) { $0 + $1.value }
            let avgSteps = total/Double(array.count)
            
            weekdayChartData.append(.init(date: firstValue.date, value: avgSteps))
        }
        
    

        return weekdayChartData
    }
}
