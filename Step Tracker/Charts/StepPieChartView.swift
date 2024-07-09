//
//  StepPieChartView.swift
//  Step Tracker
//
//  Created by Victor Marquez on 26/5/24.
//

import SwiftUI
import Charts

struct StepPieChartView: View {
    
    var chartData: [DateValueChartData] = []
    
    @State private var rawSelectedChartValue: Double? = 0
    @State private var selectedDay: Date?
    
    var selectedWeekday: DateValueChartData? {
        guard let rawSelectedChartValue else { return nil }
        var total = 0.0
        return chartData.first {
            total += $0.value
            return rawSelectedChartValue <= total
        }
    }
    
    var body: some View {
        ChartsContainer(title:"Averages", symbol: "calendar", subTitle: "Last 20 days", isNav: true, context: .steps) {
            
            if chartData.isEmpty {
                ChartEmptyView(systemImageName: "chart.pie", title: "No Dat", description: "There is no step count data from the Health App")
            } else {
                Chart{
                    ForEach(chartData) { weekday in
                        SectorMark(
                            angle: .value("Average Steps", weekday.value),
                            innerRadius: .ratio(0.610),
                            outerRadius: selectedWeekday?.date.weekdayInt == weekday.date.weekdayInt ? 140 : 110,
                            angularInset: 1
                        )
                        .foregroundStyle(.pink.gradient)
                        .cornerRadius(6)
                        .opacity(selectedWeekday?.date.weekdayInt == weekday.date.weekdayInt ? 1.0 : 0.3)
                       
                        
                            
                    }
                }
                .chartAngleSelection(value: $rawSelectedChartValue.animation(.easeInOut))
                .frame(height: 240)
                .chartBackground { proxy in
                    GeometryReader { geo in
                        if let plotFrame = proxy.plotFrame {
                            let frame = geo[plotFrame]
                            if let selectedWeekday {
                                VStack{
                                    Text(selectedWeekday.date.weekdayTitle)
                                        .font(.title3.bold())
                                    
                                    Text(selectedWeekday.value, format: .number.precision(.fractionLength(0)))
                                        .fontWeight(.medium)
                                        .foregroundStyle(.secondary)
                                        .contentTransition(.numericText())
                                }
                                .position(x:frame.midX, y: frame.midY)
                            }
                        }
                        
                    }
                }
                
            }
            

            
            
            
        }
        .sensoryFeedback(.selection, trigger: selectedDay)
        .onChange(of:selectedWeekday){ oldValue, newValue in
            guard let oldValue, let newValue else { return }
            if oldValue.date.weekdayInt != newValue.date.weekdayInt {
                selectedDay = newValue.date
            }
        }
    }
}

#Preview {
    StepPieChartView(chartData: ChartMath.averageWeekdauCount(for: MockData.steps))
}
