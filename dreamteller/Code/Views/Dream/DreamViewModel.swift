//
//  DreamViewModel.swift
//  dreamteller
//
//  Created by suha.isik on 31.10.2025.
//
import Foundation
import SwiftUI
import UIKit

enum APIError: Error {
    case invalidURL
    case noData
    case decodingFailed
    case unauthorized
    case server(String)
    case unknown
}

struct Endpoint {
    let path: String
    let method: HTTPMethod
    let body: Encodable?
}

final class APIClient {
    static let shared = APIClient()
    private init() {}

    private let baseURL = URL(string: "https://dreamteller.pik-app.com")!

    func request<T: Decodable>(_ endpoint: Endpoint, token: String) async throws -> T {
        var url = baseURL.appendingPathComponent(endpoint.path)
        var req = URLRequest(url: url)
        req.httpMethod = endpoint.method.rawValue
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        if let body = endpoint.body {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try JSONEncoder().encode(AnyEncodable(body))
        }

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError.unknown }
        switch http.statusCode {
        case 200...299:
            guard !data.isEmpty else {
                // For endpoints returning no body
                return (try ({}() as! T))
            }
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw APIError.decodingFailed
            }
        case 401: throw APIError.unauthorized
        default:
            let message = String(data: data, encoding: .utf8) ?? "Server error"
            throw APIError.server(message)
        }
    }

    func requestNoContent(_ endpoint: Endpoint, token: String) async throws {
        struct Empty: Decodable {}
        _ = try await request(endpoint, token: token) as Empty
    }
}

// Helper to encode unknown Encodable
private struct AnyEncodable: Encodable {
    private let encodeClosure: (Encoder) throws -> Void
    init(_ encodable: Encodable) {
        self.encodeClosure = encodable.encode
    }
    func encode(to encoder: Encoder) throws { try encodeClosure(encoder) }
}

enum ImageDecode {
    static func uiImage(fromBase64 base64: String) -> UIImage? {
        guard let data = Data(base64Encoded: base64) else { return nil }
        return UIImage(data: data)
    }
}

@MainActor
final class DreamViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var dreams: [Dream] = []
    @Published var monthlyEntries: [DreamEntry] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var fetchedImage: UIImage? = nil
    @Published var subscriptions: NotificationSubscription? = nil

    private var idToken: String?

    func setAuthToken(_ token: String?) {
        idToken = token
    }

    private func guardToken() throws -> String {
        guard let t = idToken, !t.isEmpty else { throw APIError.unauthorized }
        return t
    }

    private static let dfKey: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd"
        f.calendar = .init(identifier: .gregorian)
        f.locale = .init(identifier: "en_US_POSIX")
        return f
    }()

    private func dateKey(_ date: Date) -> String { Self.dfKey.string(from: date) }

    // MARK: Load dream list for selected date
    func loadDreamsForSelectedDate() async {
        dreams.removeAll()
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            let token = try guardToken()
            let key = dateKey(selectedDate)
            let ep = Endpoint(path: "api/dream/\(key)", method: .GET, body: nil)
            dreams = try await APIClient.shared.request(ep, token: token)
        } catch {
            errorMessage = mapError(error)
        }
    }

    // MARK: Monthly entry status
    func loadMonthlyEntries(year: Int, month: Int) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        let monthStr = String(format: "%02d", month)
        do {
            let token = try guardToken()
            let ep = Endpoint(path: "api/dream/entryList/\(year)/\(monthStr)", method: .GET, body: nil)
            monthlyEntries = try await APIClient.shared.request(ep, token: token)
        } catch {
            errorMessage = mapError(error)
        }
    }

    // MARK: Interpret (create) dream
    func submitDreamForInterpretation(input: String) async {
        errorMessage = nil
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        let key = dateKey(selectedDate)
        do {
            let token = try guardToken()
            let body = DreamRequest(dateKey: key, input: input)
            let ep = Endpoint(path: "api/dream/interpret", method: .POST, body: body)
            try await APIClient.shared.requestNoContent(ep, token: token)
            // After posting, optionally reload dreams
            await loadDreamsForSelectedDate()
        } catch {
            errorMessage = mapError(error)
        }
    }

    // MARK: Fetch image
    func fetchDreamImage(dreamId: String) async {
        fetchedImage = nil
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            let token = try guardToken()
            let ep = Endpoint(path: "api/dream/image/\(dreamId)", method: .GET, body: nil)
            struct ImageResponse: Decodable { let base64: String }
            let res: ImageResponse = try await APIClient.shared.request(ep, token: token)
            fetchedImage = ImageDecode.uiImage(fromBase64: res.base64)
        } catch {
            errorMessage = mapError(error)
        }
    }

    // MARK: Notification subscriptions
    func loadSubscriptions() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            let token = try guardToken()
            let ep = Endpoint(path: "api/notification/subscriptions", method: .GET, body: nil)
            subscriptions = try await APIClient.shared.request(ep, token: token)
        } catch {
            errorMessage = mapError(error)
        }
    }

    func updateSubscriptions(daily: Bool, interpretation: Bool) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            let token = try guardToken()
            let body = NotificationSubscription(daily: daily, interpretation: interpretation)
            let ep = Endpoint(path: "api/notification/subscriptions", method: .POST, body: body)
            try await APIClient.shared.requestNoContent(ep, token: token)
            subscriptions = body
        } catch {
            errorMessage = mapError(error)
        }
    }

    // MARK: Update FCM token
    func updateFCMToken(_ fcm: String) async {
        guard !fcm.isEmpty else { return }
        errorMessage = nil
        do {
            let token = try guardToken()
            let body = FCMRequest(fcmToken: fcm)
            let ep = Endpoint(path: "api/notification/fcm", method: .POST, body: body)
            try await APIClient.shared.requestNoContent(ep, token: token)
        } catch {
            errorMessage = mapError(error)
        }
    }

    private func mapError(_ err: Error) -> String {
        switch err {
        case APIError.invalidURL: return "Invalid URL"
        case APIError.noData: return "No data"
        case APIError.decodingFailed: return "Decode error"
        case APIError.unauthorized: return "Unauthorized"
        case APIError.server(let msg): return msg
        default: return "Unknown error"
        }
    }
}
