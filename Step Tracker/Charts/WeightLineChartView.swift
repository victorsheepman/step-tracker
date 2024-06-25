//
//  WeightLineChartView.swift
//  Step Tracker
//
//  Created by Victor Marquez on 28/5/24.
//

import SwiftUI
import Charts

struct WeightLineChartView: View {
    
    @State private var rawSelectedDate: Date?
    @State private var selectedDay: Date?
    
    var selectedStat: HealthMetricContext
    var chartData: [HealthMetric]
    
    var minValue: Double {
        chartData.map { $0.value }.min() ?? 0
    }
    
    var selectedHealthMetric: HealthMetric? {
        guard let rawSelectedDate else { return nil }
        return chartData.first {
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
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
                if let selectedHealthMetric {
                    RuleMark(x: .value("Selected Metric", selectedHealthMetric.date, unit:.day))
                        .foregroundStyle(.secondary.opacity(0.3))
                        .offset(y:-10)
                        .annotation(position: .top,
                                    spacing: 40,
                                    overflowResolution: .init(x:.fit(to:.chart), y:.disabled)
                        ){
                            annotationView
                        }
                }
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
            .chartXSelection(value: $rawSelectedDate)
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
            
            
        }
         .padding()
         .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
         .sensoryFeedback(.selection, trigger: selectedDay)
         .onChange(of: rawSelectedDate) { oldValue, newValue in
             if oldValue?.weekdayInt != newValue?.weekdayInt {
                 selectedDay = newValue
             }
         }
    }
    var annotationView: some View{
        VStack(alignment:.leading){
            Text(selectedHealthMetric?.date ?? .now, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.footnote.bold())
                .foregroundStyle(.secondary)
            Text(selectedHealthMetric?.value ?? 0, format: .number.precision(.fractionLength(1)))
                .fontWeight(.heavy)
                .foregroundStyle(.indigo)
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
    WeightLineChartView(selectedStat: .weight, chartData: MockData.weights)
}
