//
//  WeightLineChartView.swift
//  Step Tracker
//
//  Created by Victor Marquez on 28/5/24.
//

import SwiftUI
import Charts

struct WeightLineChartView: View {
    
    var selectedStat: HealthMetricContext
    var chartData: [HealthMetric]
    
    var minValue: Double {
        chartData.map { $0.value }.min() ?? 0
    }
    
    var body: some View {
        VStack {
            NavigationLink(value: selectedStat) {
                HStack{
                    VStack(alignment:.leading){
                        Label("Weight", systemImage: "figure")
                            .font(.title3.bold())
                            .foregroundStyle(.indigo)
                        
                        Text("Avg:  180 lbs")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
                
            }
            .foregroundColor(.secondary)
            .padding(.bottom, 12)
            
            Chart {
                
                RuleMark(y: .value("Goal", 155))
                    .foregroundStyle(.mint)
                    .lineStyle(.init(lineWidth: 1, dash: [5]))
                    
                
                
                ForEach(chartData){ weights in
                    
                    AreaMark(
                        x:.value("Day", weights.date, unit: .day),
                        yStart: .value("Value", weights.value),
                        yEnd: .value("Min Value", minValue)
                    )
                    .foregroundStyle(Gradient(colors: [.indigo.opacity(0.5), .clear]))
                    .interpolationMethod(.catmullRom)
                 
                    LineMark(x: .value("Day", weights.date, unit: .day), y: .value("Value", weights.value))
                        .foregroundStyle(.indigo)
                        .interpolationMethod(.catmullRom)
                        .symbol(.circle)
                }
            }.frame(height: 150)
            .chartYScale(domain: .automatic(includesZero: false))
            .chartXAxis{
                AxisMarks {value in
                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                }
                    
            }
            .chartYAxis{
                AxisMarks {value in
                    AxisGridLine()
                        .foregroundStyle(Color.secondary.opacity(0.3))
                    
                    AxisValueLabel()
                }
            }
            
            
        }.padding()
         .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}

#Preview {
    WeightLineChartView(selectedStat: .weight, chartData: MockData.weights)
}
