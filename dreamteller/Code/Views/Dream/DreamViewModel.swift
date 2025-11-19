//
//  DreamViewModel.swift
//  dreamteller
//
//  Created by suha.isik on 31.10.2025.
//
import Foundation
enum APIError: Error {
    case invalidURL
    case noData
    case decodingFailed
    case unauthorized
    case server(String)
    case unknown
}


