//
//  AddDataView.swift
//  Step Tracker
//
//  Created by Victor Marquez on 25/11/24.
//

import SwiftUI

struct AddDataView: View {
    
    @Environment(HealthKitManager.self) private var hkManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var isShowingAlert: Bool     = false
    @State private var writeError: STError = .noData
    @State private var addDataDate: Date  = .now
    @State private var valueToAdd: String = ""
    
    var metric: HealthMetricContext
    
    @Binding var isShowingPermissionPriming: Bool
 
    var body: some View {
        NavigationStack {
            Form {
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
                errorAlertActions(for: writeError)
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
                                await fetchStepData(value)
                            } else {
                                await fetchWeightData(value)
                            }
                        }
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarLeading){
                    Button("Dismiss"){
                       dismiss()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func errorAlertActions(for error: STError) -> some View {
        switch error {
        case .authNotDetermined, .noData, .unableToCompleteRequest, .invalidValue:
            EmptyView()
        case .sharingDenied:
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func fetchStepData(_ value: Double) async{
        do {
            try await hkManager.addStepData(for: addDataDate, value: value)
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
    }
    
    private func fetchWeightData(_ value: Double) async {
        do {
           try await hkManager.addWeightData(for: addDataDate, value: value)
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
