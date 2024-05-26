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
                    StepBarChartView(selectedStat: selectedStat, chartData: hkManager.stepData)
                    
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
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
