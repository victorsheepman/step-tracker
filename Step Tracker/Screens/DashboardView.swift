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
    @State private var rawSelectedDate:Date?
    @State private var selectedStat:HealthMetricContext = .steps
    var isStep: Bool {selectedStat == .steps}
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing:20) {
                    Picker("Selected Stat", selection: $selectedStat) {
                        ForEach(HealthMetricContext.allCases){
                            Text($0.title)
                        }
                    }.pickerStyle(.segmented)
                    
                    switch selectedStat {
                    case .steps:
                        StepBarChartView(selectedStat: selectedStat, chartData: hkManager.stepData)
                        StepPieChartView(chartData: ChartMath.averageWeekdauCount(for: hkManager.stepData))
                    case .weight:
                        WeightLineChartView(selectedStat: selectedStat, chartData: hkManager.weightData)
                    }
                    
                    
                   
                }
            }
            .padding()
            .task{
                await hkManager.fetchStepCount()
                await hkManager.fetchWeights()
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
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
