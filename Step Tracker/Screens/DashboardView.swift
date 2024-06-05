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
                        WeightBarChartView(chartData: ChartMath.averageDailyWeightDiffs(for: hkManager.weightDiffData))
                    }
                    
                    
                   
                }
            }
            .padding()
            .task{
                
                do {
                    try await hkManager.fetchStepCount()
                    try await hkManager.fetchWeights()
                    try await hkManager.fetchWeightsDiff()
                } catch STError.authNotDetermined{
                    isShowingPermissionPrimingSheet = true
                } catch STError.noData {
                    print("no data error")
                } catch {
                    print("unable complete request")
                }
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(isShowingPermissionPriming: $isShowingPermissionPrimingSheet, metric: metric)
            }
            .sheet(isPresented: $isShowingPermissionPrimingSheet, onDismiss:{
                
            }, content:{
                HealthKitPermissionPrimingView()
            })
            
        }.tint( isStep ? .pink : .indigo)
        
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
