//
//  ContentView.swift
//  Step Tracker
//
//  Created by Victor Marquez on 20/5/24.
//

import SwiftUI
import Charts



struct DashboardView: View {
    
    @Environment(HealthKitManager.self) private var hkManager
    
    @State private var isShowingPermissionPrimingSheet: Bool = false
    @State private var rawSelectedDate: Date?
    @State private var selectedStat: HealthMetricContext = .steps
    @State private var isShowingAlert: Bool = false
    @State private var fetchError: STError = .noData
    
    var isStep: Bool {
        selectedStat == .steps
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
                    switch selectedStat {
                    case .steps:
                        StepBarChartView(chartData: ChartHelper.convert(data: hkManager.stepData ))
                        StepPieChartView(chartData: ChartMath.averageWeekdauCount(for: hkManager.stepData))
                    case .weight:
                        WeightLineChartView(chartData: ChartHelper.convert(data:  hkManager.weightData))
                        WeightBarChartView(chartData: ChartMath.averageDailyWeightDiffs(for: hkManager.weightDiffData))
                    }
                }
            }
            .padding()
            .task {
                do {
                    try await hkManager.fetchStepCount()
                    try await hkManager.fetchWeights()
                    try await hkManager.fetchWeightsDiff()
                 // try await hkManager.addSimulatorData()
                } catch STError.authNotDetermined {
                    isShowingPermissionPrimingSheet = true
                } catch STError.noData {
                    fetchError = .noData
                    isShowingAlert = true
                } catch {
                    fetchError = .unableToCompleteRequest
                    isShowingAlert = true
                }
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(isShowingPermissionPriming: $isShowingPermissionPrimingSheet, metric: metric)
            }
            .sheet(isPresented: $isShowingPermissionPrimingSheet) {
                HealthKitPermissionPrimingView()
            }
            .alert(isPresented: $isShowingAlert, error: fetchError) { fetchError in
                
            } message: { fetchError in
                Text(fetchError.localizedDescription)
            }
            
        }.tint( isStep ? .pink : .indigo)
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
