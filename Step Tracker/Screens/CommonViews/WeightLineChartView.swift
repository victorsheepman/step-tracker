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
    
    var chartData: [DateValueChartData]
    
    var minValue: Double {
        chartData.map { $0.value }.min() ?? 0
    }
    
    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData, in: rawSelectedDate)
    }
    
    var body: some View {
        let config = ChartContainerConfiguration(
            title: "Weight",
            symbol: "figure",
            subTitle: "Avg:  180 lbs",
            isNav: true,
            context: .weight
        )
        ChartsContainer(config:config) {
            if chartData.isEmpty {
                ChartEmptyView(
                    systemImageName: "chart.xyaxis.line",
                    title: "No Data",
                    description: "There is no step count data from the Health App"
                )
            } else {
                Chart {
                    if let selectedData {
                        ChartAnnotationView(data: selectedData, context: .steps)
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
        }
         .sensoryFeedback(.selection, trigger: selectedDay)
         .onChange(of: rawSelectedDate) { oldValue, newValue in
             if oldValue?.weekdayInt != newValue?.weekdayInt {
                 selectedDay = newValue
             }
         }
    }
}

#Preview {
    WeightLineChartView(chartData:ChartHelper.convert(data: MockData.weights))
}
