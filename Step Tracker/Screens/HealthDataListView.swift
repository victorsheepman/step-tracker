//
//  HealthDataListView.swift
//  Step Tracker
//
//  Created by Victor Marquez on 21/5/24.
//

import SwiftUI

struct HealthDataListView: View {
    
    @Environment(HealthKitManager.self) private var hkManager
    @Environment(\.dismiss) private var dismiss

    @State private var isShowingAddData: Bool   = false
    @State private var isShowingAlert: Bool     = false
    @State private var writeError: STError = .noData
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
            AddDataView(metric: metric, isShowingPermissionPriming: $isShowingPermissionPriming)
        }
        .toolbar{
            Button("Add Data", systemImage: "plus") {
                isShowingAddData = true
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
