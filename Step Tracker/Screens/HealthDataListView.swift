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
    @State private var isShowingAlert     = false
    @State private var writeError:STError = .noData
    @State private var addDataDate: Date  = .now
    @State private var valueToAdd: String = ""
    
    @Binding var isShowingPermissionPriming: Bool
    
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
            .alert(isPresented: $isShowingAlert, error: writeError) { writeError in
                switch writeError {
                case .authNotDetermined, .noData, .unableToCompleteRequest, .invalidValue:
                        EmptyView()
                case .sharingDenied(_):
                    Button("Setting"){
                        UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                    }
                    Button("Cancel", role: .cancel){}
                }
            } message: { writeError in
                Text(writeError.failureReason)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    Button("Add Data"){
                        guard let value = Double(valueToAdd) else {
                            writeError = .invalidValue
                            valueToAdd = ""
                            isShowingAlert = true
                            return
                        }
                        Task {
                            if metric == .steps {
                                
                                do {
                                    try await hkManager.addStepData(for: addDataDate, value: Double(valueToAdd)!)
                                    try await hkManager.fetchStepCount()
                                } catch STError.authNotDetermined {
                                    isShowingPermissionPriming = true
                                } catch STError.sharingDenied(let quantity){
                                    writeError = .sharingDenied(quantityType: quantity)
                                    isShowingAlert = true
                                } catch {
                                    writeError = .unableToCompleteRequest
                                    isShowingAlert = true
                                }
                                
                                isShowingAddData = false
                            } else {
                                
                                do {
                                   try await hkManager.addWeightData(for: addDataDate, value: Double(valueToAdd)!)
                                   try await hkManager.fetchWeightsDiff()
                                   try await hkManager.fetchWeights()
                                }catch STError.authNotDetermined {
                                    isShowingPermissionPriming = true
                                } catch STError.sharingDenied(let quantity){
                                    writeError = .sharingDenied(quantityType: quantity)
                                    isShowingAlert = true
                                } catch {
                                    writeError = .unableToCompleteRequest
                                    isShowingAlert = true
                                }
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
        HealthDataListView(isShowingPermissionPriming: .constant(false), metric: .steps)
            .environment(HealthKitManager())
    }
}
