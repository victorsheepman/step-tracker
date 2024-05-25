//
//  ContentView.swift
//  Step Tracker
//
//  Created by Victor Marquez on 20/5/24.
//

import SwiftUI
import Charts

enum HealthMetricContext: CaseIterable, Identifiable{
    case steps, weight
    var id: Self { self }
    var title: String{
        switch self {
        case .steps:
            return "Steps"
        case .weight:
            return "Weight"
        }
    }
}

struct DashboardView: View {
    @Environment(HealthKitManager.self) private var hkManager
    @AppStorage("hasSeenPermissionPriming") private var hasSeenPermissionPriming = false
    @State private var isShowingPermissionPrimingSheet = false
    @State private var selectedStat: HealthMetricContext = .steps
    @State private var rawSelectedDate:Date?
    var isStep: Bool {selectedStat == .steps}
    
    var avgStepCount: Double {
        guard !hkManager.stepData.isEmpty else {return 0}
        let totalStep = hkManager.stepData.reduce(0) { $0 + $1.value }
        return totalStep/Double(hkManager.stepData.count)
    }
    
    var selectedHealthMetric: HealthMetric? {
        guard let rawSelectedDate else { return nil}
        let selectedMetric = hkManager.stepData.first{
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
        
        return selectedMetric
    }
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing:20) {
                    Picker("Selected Stat", selection: $selectedStat) {
                        ForEach(HealthMetricContext.allCases){
                            Text($0.title)
                        }
                    }.pickerStyle(.segmented)
                    VStack {
                        NavigationLink(value: selectedStat) {
                            HStack{
                                VStack(alignment:.leading){
                                    Label("Steps", systemImage: "figure.walk")
                                        .font(.title3.bold())
                                        .foregroundStyle(.pink)
                                    
                                    Text("Avg: \(Int(avgStepCount)) Steps")
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
                            RuleMark(y: .value("Average", avgStepCount))
                                .foregroundStyle(Color.secondary)
                                .lineStyle(.init(lineWidth:1, dash: [5]))
                            ForEach(hkManager.stepData){ step in
                                BarMark(
                                    x: .value("Date", step.date, unit: .day),
                                    y: .value("Steps", step.value)
                                )
                                .foregroundStyle(.pink.gradient)
                                .opacity(rawSelectedDate == nil || step.date == selectedHealthMetric?.date ? 1.0 : 0.3)
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
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                    
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
                        
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(.secondary)
                            .frame(height:240)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                }
            }
            .padding()
            .task{
                await hkManager.fetchStepCount()
                isShowingPermissionPrimingSheet = !hasSeenPermissionPriming
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .sheet(isPresented: $isShowingPermissionPrimingSheet, onDismiss:{
                
            }, content:{
                HealthKitPermissionPrimingView(hasSeen: $hasSeenPermissionPriming)
            })
            
        }.tint( isStep ? .pink : .indigo)
        
    }
    
    var annotationView: some View{
        VStack(alignment:.leading){
            Text(selectedHealthMetric?.date ?? .now, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.footnote.bold())
                .foregroundStyle(.secondary)
            Text(selectedHealthMetric?.value ?? 0, format: .number.precision(.fractionLength(0)))
                .fontWeight(.heavy)
                .foregroundStyle(.pink)
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
    DashboardView()
        .environment(HealthKitManager())
}
