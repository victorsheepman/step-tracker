//
//  HealthKitManager.swift
//  Step Tracker
//
//  Created by Victor Marquez on 22/5/24.
//

import Foundation
import HealthKit
import Observation



@Observable class HealthKitManager {
    
    let store = HKHealthStore()
    
    let types: Set = [HKQuantityType(.stepCount), HKQuantityType(.bodyMass)]
    
    var stepData:[HealthMetric] = []
    var weightData:[HealthMetric] = []
    var weightDiffData:[HealthMetric] = []
    
    //OBTENER LOS PASOS DE UN PERIODO DE 28 DIAS
    func fetchStepCount() async throws -> [HealthMetric] {
        
        guard store.authorizationStatus(for: HKQuantityType(.stepCount)) != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        let interval = createDateInterval(from: .now, daysBack: 28)
        
        let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.stepCount), predicate: queryPredicate)
        let stepsQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .cumulativeSum,
            anchorDate: interval.end,
            intervalComponents: .init(day:1)
        )
        
    
        
        do {
            let stepCounts = try! await stepsQuery.result(for: store)
            return stepCounts.statistics().map{ .init(date: $0.startDate, value:$0.sumQuantity()?.doubleValue(for: .count()) ?? 0) }
        } catch HKError.errorNoData {
            throw STError.noData
        } catch {
            throw STError.unableToCompleteRequest
        }
        
    }
    
    //OBTENER EL PESO DE UN PERIODO DE 28 DIAS
    func fetchWeights(daysBack: Int) async throws -> [HealthMetric] {

        guard store.authorizationStatus(for: HKQuantityType(.bodyMass)) != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        
        let interval = createDateInterval(from: .now, daysBack: daysBack)
        
        let queryPredicate  = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.bodyMass), predicate: queryPredicate)
        let weightQuery     = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .mostRecent,
            anchorDate: interval.end,
            intervalComponents: .init(day:1)
        )
        
        let weights = try! await weightQuery.result(for: store)
        return weights.statistics().map{ .init(date: $0.startDate, value: $0.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0) }
        
        do {
            let weights = try! await weightQuery.result(for: store)
            weightData = weights.statistics().map{ .init(date: $0.startDate, value: $0.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0) }

        } catch HKError.errorNoData {
            throw STError.noData
        } catch {
            throw STError.unableToCompleteRequest
        }
    }
    

    
    func addStepData(for date: Date, value: Double) async throws {
        

        
        let status = store.authorizationStatus(for: HKQuantityType(.stepCount))
        
        switch status {
        case .notDetermined:
            throw STError.authNotDetermined
        case .sharingDenied:
            throw STError.sharingDenied(quantityType: "Step Count")
        case .sharingAuthorized:
            break
        @unknown default:
            break
        }
        
        
        let stepQuantity = HKQuantity(unit: .count(), doubleValue: value)
        let stepSample = HKQuantitySample(type: HKQuantityType(.stepCount), quantity: stepQuantity, start: date, end: date)
        
       
        
        do {
            try await store.save(stepSample)
        } catch {
            throw STError.unableToCompleteRequest
        }
        
    }
    
    func addWeightData(for date: Date, value: Double) async throws{
        
        let status = store.authorizationStatus(for: HKQuantityType(.bodyMass))
        
        switch status {
        case .notDetermined:
            throw STError.authNotDetermined
        case .sharingDenied:
            throw STError.sharingDenied(quantityType: "Weight")
        case .sharingAuthorized:
            break
        @unknown default:
            break
        }
        
        
        let weightQuantity = HKQuantity(unit:  .pound(), doubleValue: value)
        let weightSample = HKQuantitySample(type: HKQuantityType(.bodyMass), quantity: weightQuantity, start: date, end: date)
       
        
        do {
            try await store.save(weightSample)
        } catch  {
            throw STError.unableToCompleteRequest
        }
    }
    
    private func createDateInterval(from date: Date, daysBack: Int) -> DateInterval {
        let calendar       = Calendar.current
        let startOfEndDate = calendar.startOfDay(for:date)
        let endDate        = calendar.date(byAdding: .day,value: 1, to: startOfEndDate)!
        let startDate      = calendar.date(byAdding: .day,value: daysBack, to: endDate)!
        
        return .init(start: startDate, end: endDate)
        
        
    }
    
    //AGREGAR DATA SIMULADA A NUESTRA APP DE HEALTHKIT
    func addSimulatorData() async{
        var mockSamples: [HKQuantitySample] = []
        
        for i in 0..<28{
            
            let stepQuantity = HKQuantity(unit: .count(), doubleValue: .random(in: 4_000...20_000))
            let weightQuantity = HKQuantity(unit: .pound(), doubleValue: .random(in: (160 + Double(i/3)...165 + Double(i/3))))
            
            let startDate = Calendar.current.date(byAdding: .day, value: -i, to: .now)!
            let endDate = Calendar.current.date(byAdding: .second, value: 1, to: startDate)!
            
            let stepSample = HKQuantitySample(type: HKQuantityType(.stepCount), quantity: stepQuantity, start: startDate, end: endDate)
            let weightSample = HKQuantitySample(type: HKQuantityType(.bodyMass), quantity: weightQuantity, start: startDate, end: endDate)
            
            mockSamples.append(stepSample)
            mockSamples.append(weightSample)
        }
        
        try! await store.save(mockSamples)
        print("Dummy Data sent up")
    }
}

