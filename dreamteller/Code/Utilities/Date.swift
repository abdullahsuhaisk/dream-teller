//
//  Date.swift
//  dreamteller
//
//  Created by suha.isik on 19.11.2025.
//

import Foundation

extension Date {
    func y() -> Int { Calendar.current.component(.year, from: self) }
    func m() -> Int { Calendar.current.component(.month, from: self) }
}
