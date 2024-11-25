//
//  ChartAnnotationView.swift
//  Step Tracker
//
//  Created by Victor Marquez on 9/7/24.
//

import SwiftUI
import Charts

struct ChartAnnotationView: ChartContent {
    let data: DateValueChartData
    let context: HealthMetricContext
    
    var body: some ChartContent {
        RuleMark(x: .value("Selected Metric", data.date, unit:.day))
            .foregroundStyle(.secondary.opacity(0.3))
            .offset(y:-10)
            .annotation(position: .top,
                        spacing: 40,
                        overflowResolution: .init(x:.fit(to:.chart), y:.disabled)
            ){
                annotationView
            }
    
    }
    
    var annotationView: some View {
        VStack(alignment:.leading){
            Text(data.date, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.footnote.bold())
                .foregroundStyle(.secondary)
            Text(data.value, format: .number.precision(.fractionLength(context == .steps ? 0 : 1)))
                .fontWeight(.heavy)
                .foregroundStyle(context == .steps ? .pink : .indigo)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.secondarySystemBackground))
                .shadow(color:.secondary.opacity(0.3), radius: 2, x: 2, y: 2)
        )
    }
}

#Preview {
    ChartAnnotationView(data: .init(date: .now, value: 1000), context: .steps) as! any View
}
