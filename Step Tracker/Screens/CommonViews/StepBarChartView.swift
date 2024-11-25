//
//  StepBarChartView.swift
//  Step Tracker
//
//  Created by Victor Marquez on 26/5/24.
//

import SwiftUI
import Charts

struct StepBarChartView: View {
    @State private var rawSelectedDate:Date?
    @State private var selectedDay: Date?

    var chartData: [DateValueChartData]
    
    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData, in: rawSelectedDate)
    }
    

    var body: some View {
        let config = ChartContainerConfiguration(
            title: "Steps",
            symbol: "figure.walk",
            subTitle: "Avg: \(Int(ChartHelper.averageValue(for: chartData))) steps",
            isNav: true,
            context: .steps
        )
        ChartsContainer(config: config) {
            if chartData.isEmpty {
                ChartEmptyView(
                    systemImageName: "chart.bar",
                    title: "No Data",
                    description: "There is no step count data from the Health App"
                )
            } else {
                
                Chart{
                    if let selectedData {
                        ChartAnnotationView(data: selectedData, context: .steps)
                    }
                    RuleMark(y: .value("Average", ChartHelper.averageValue(for: chartData)))
                        .foregroundStyle(Color.secondary)
                        .lineStyle(.init(lineWidth:1, dash: [5]))
                    ForEach(chartData){ step in
                        BarMark(
                            x: .value("Date", step.date, unit: .day),
                            y: .value("Steps", step.value)
                        )
                        .foregroundStyle(.pink.gradient)
                        .opacity(rawSelectedDate == nil || step.date == selectedData?.date ? 1.0 : 0.3)
                    }
                }
                .frame(height:150)
                .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
                .chartXAxis{
                    AxisMarks {value in
                        AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                    }
                }
                .chartYAxis{
                    AxisMarks {value in
                        AxisGridLine()
                            .foregroundStyle(Color.secondary.opacity(0.3))
                        
                        AxisValueLabel((value.as(Double.self) ?? 0).formatted(.number.notation(.compactName)))
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
    StepBarChartView( chartData: [])
}
