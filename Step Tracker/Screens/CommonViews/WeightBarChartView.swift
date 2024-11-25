//
//  WeightBarChartView.swift
//  Step Tracker
//
//  Created by Victor Marquez on 30/5/24.
//

import SwiftUI
import Charts


struct WeightBarChartView: View {

    @State private var rawSelectedDate:Date?
    @State private var selectedDay: Date?
    
    var chartData: [DateValueChartData]

    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData, in: rawSelectedDate)
    }
    
    var body: some View {
        let config = ChartContainerConfiguration(
            title: "Average Weight Change",
            symbol: "figure",
            subTitle: "Per Weekday (Last 28 Days)",
            isNav: true,
            context: .weight
        )
        
        ChartsContainer(config:config) {
            if chartData.isEmpty {
                ChartEmptyView(
                    systemImageName: "chart.bar",
                    title: "No Data",
                    description: "There is no step weight data from the Health App"
                )
            } else {
                //GRAFICO
                Chart{
                    if let selectedData {
                        ChartAnnotationView(data: selectedData, context: .weight)
                        
                    }
                    ForEach(chartData){ weight in
                        BarMark(
                            x: .value("Date",  weight.date, unit: .day),
                            y: .value("Steps", weight.value)
                        )
                        .foregroundStyle(weight.value > 0 ? Color.indigo.gradient : Color.mint.gradient)
                        .opacity(rawSelectedDate == nil || weight.date == selectedData?.date ? 1.0 : 0.3)
                    }
                }
                .frame(height:150)
                .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
                .chartXAxis{
                    AxisMarks(values: .stride(by: .day)){
                        AxisValueLabel(format: .dateTime.weekday(), centered: true)
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
    WeightBarChartView(chartData: MockData.weightsDiff)
}
