//
//  StepPieChartView.swift
//  Step Tracker
//
//  Created by Victor Marquez on 26/5/24.
//

import SwiftUI
import Charts

struct StepPieChartView: View {
    
    var chartData: [WeekdayChartData] = []
    
    var body: some View {
        VStack(alignment:.leading){
            
            VStack(alignment:.leading){
                Label("Averages", systemImage: "calendar")
                    .font(.title3.bold())
                    .foregroundStyle(.pink)
                
                Text("Last 20 days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            .padding(.bottom, 12)
            
            Chart{
                ForEach(chartData) { weekday in
                    SectorMark(
                        angle: .value("Average Steps", weekday.value),
                        innerRadius: .ratio(0.610),
                        angularInset: 1
                    )
                    .foregroundStyle(.pink.gradient)
                    .cornerRadius(6)
                    .annotation(position:.overlay) {
                        Text(weekday.value, format:.number.notation(.compactName))
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                    }
                    
                        
                }
            }
            .frame(height: 240)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}

#Preview {
    StepPieChartView(chartData: ChartMath.averageWeekdauCount(for: HealthMetric.mockData))
}
