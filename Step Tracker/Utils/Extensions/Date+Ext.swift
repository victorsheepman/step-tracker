//
//  Date+Ext.swift
//  Step Tracker
//
//  Created by Victor Marquez on 26/5/24.
//

import Foundation

extension Date {
    var weekdayInt: Int {
        Calendar.current.component(.weekday, from: self)
    }
    var weekdayTitle: String {
        self.formatted(.dateTime.weekday(.wide))
    }
}
