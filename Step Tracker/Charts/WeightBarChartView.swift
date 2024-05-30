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
    
    var chartData: [WeekdayChartData]

    var selectedHealthMetric: WeekdayChartData? {
        guard let rawSelectedDate else { return nil}
        let selectedMetric = chartData.first{
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
        
        return selectedMetric
    }
    
    var body: some View {
        VStack {
                HStack{
                    VStack(alignment:.leading){
                        Label("Average Weight Change", systemImage: "figure")
                            .font(.title3.bold())
                            .foregroundStyle(.indigo)
                        
                        Text("Per Weekday (Last 28 Days)")
                            .font(.caption)
                           
                    }
                    Spacer()
                }
                
            .foregroundColor(.secondary)
            .padding(.bottom, 12)
            
            //GRAFICO
            Chart{
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
                ForEach(chartData){ weight in
                    BarMark(
                        x: .value("Date",  weight.date, unit: .day),
                        y: .value("Steps", weight.value)
                    )
                    .foregroundStyle(weight.value > 0 ? Color.indigo.gradient : Color.mint.gradient)
                    .opacity(rawSelectedDate == nil || weight.date == selectedHealthMetric?.date ? 1.0 : 0.3)
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
            
        }.padding()
         .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
    var annotationView: some View{
        VStack(alignment:.leading){
            Text(selectedHealthMetric?.date ?? .now, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.footnote.bold())
                .foregroundStyle(.secondary)
            Text(selectedHealthMetric?.value ?? 0, format: .number.precision(.fractionLength(2)))
                .fontWeight(.heavy)
                .foregroundStyle((selectedHealthMetric?.value ?? 0) >= 0 ? Color.indigo : Color.mint)
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
    WeightBarChartView(chartData: MockData.weightsDiff)
}
