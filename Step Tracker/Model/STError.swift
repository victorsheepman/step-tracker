//
//  STError.swift
//  Step Tracker
//
//  Created by Victor Marquez on 25/11/24.
//

import Foundation

enum STError: LocalizedError {
    case authNotDetermined
    case noData
    case unableToCompleteRequest
    case sharingDenied(quantityType: String)
    case invalidValue
    
    var errorDescription: String?{
        switch self {
            case .authNotDetermined:
                "Need Access to Health Data"
            case .sharingDenied(_):
                "No Write Access"
            case .noData:
                "No Data"
            case .unableToCompleteRequest:
                "unable to Complete Request"
            case .invalidValue:
                "Invalid Value"
        }
    }
    
    var failureReason: String {
        switch self {
            case .authNotDetermined:
                "You have not given access to your health data. Please go to Setting > Health > Data Access & Devices."
            case .sharingDenied(let quantity):
                "You denied"
            case .noData:
                "Three is not data"
            case .unableToCompleteRequest:
                "unable"
            case .invalidValue:
                "Invalid Value"
        }
    }
    
    
}
