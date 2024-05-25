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
                    VStack {
                        NavigationLink(value: selectedStat) {
                            HStack{
                                VStack(alignment:.leading){
                                    Label("Steps", systemImage: "figure.walk")
                                        .font(.title3.bold())
                                        .foregroundStyle(.pink)
                                    
                                    Text("Avg: 10K Steps")
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
                    
                        Chart{
                            ForEach(hkManager.stepData){ step in
                                BarMark(
                                    x: .value("Date", step.date, unit: .day),
                                    y: .value("Steps", step.value)
                                )
                            }
                        }
                        .frame(height:150)
                        .foregroundStyle(.pink)
                        
                        
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
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
