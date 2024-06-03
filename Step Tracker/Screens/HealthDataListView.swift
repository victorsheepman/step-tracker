//
//  HealthDataListView.swift
//  Step Tracker
//
//  Created by Victor Marquez on 21/5/24.
//

import SwiftUI

struct HealthDataListView: View {
    
    @Environment(HealthKitManager.self) private var hkManager
    
    @State private var isShowingAddData   = false
    @State private var addDataDate: Date  = .now
    @State private var valueToAdd: String = ""
    
    var metric: HealthMetricContext
    
    var listData: [HealthMetric] {
        metric == .steps ? hkManager.stepData : hkManager.weightData
    }
    
    var body: some View {
        List(listData.reversed()) { data in
            HStack{
                Text(data.date, format:.dateTime.month().day().year())
                Spacer()
                Text(data.value,  format: .number.precision(.fractionLength(metric == .steps ? 0 : 1)))
            }
        }
        .navigationTitle(metric.title)
        .sheet(isPresented: $isShowingAddData) {
            addDataView
        }
        .toolbar{
            Button("Add Data", systemImage: "plus") {
                isShowingAddData = true
            }
        }

    }
    
    var addDataView: some View {
        NavigationStack{
            Form{
                DatePicker("Date", selection: $addDataDate, displayedComponents: .date)
                
                HStack{
                    Text(metric.title)
                    Spacer()
                    TextField("Value", text: $valueToAdd)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 140)
                        .keyboardType(metric == .steps ? .numberPad : .decimalPad)
                }
                
            }
            .navigationTitle(metric.title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    Button("Add Data"){
                        Task {
                            if metric == .steps {
                                await hkManager.addStepData(for: addDataDate, value: Double(valueToAdd)!)
                                await hkManager.fetchStepCount()
                                isShowingAddData = false
                            } else {
                                await hkManager.addWeightData(for: addDataDate, value: Double(valueToAdd)!)
                                await hkManager.fetchWeightsDiff()
                                await hkManager.fetchWeights()
                                isShowingAddData = false
                            }
                        }
                    }
                }
                ToolbarItem(placement: .topBarLeading){
                    Button("Dismiss"){
                        isShowingAddData = false
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack{
        HealthDataListView(metric: .steps)
            .environment(HealthKitManager())
    }
}
