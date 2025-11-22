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

// Move EmptyResponse to top level
struct EmptyResponse: Decodable {
    init() {}
}

// Helper to encode unknown Encodable
private struct AnyEncodable: Encodable {
    private let encodeClosure: (Encoder) throws -> Void
    init(_ encodable: Encodable) {
        self.encodeClosure = encodable.encode
    }
    func encode(to encoder: Encoder) throws { try encodeClosure(encoder) }
}

final class APIClient {
    static let shared = APIClient()
    private init() {}

    private let baseURL = URL(string: "https://dreamteller.pik-app.com")!

    func request<T: Decodable>(_ endpoint: Endpoint, token: String) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var req = URLRequest(url: url)
        req.timeoutInterval = 30.0
        req.httpMethod = endpoint.method.rawValue
        req.setValue(token, forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        
        Logger.log("Making request to: \(url)", level: .debug)
        Logger.log("Authorization header: \(token.prefix(20))...", level: .debug)
        
        if let body = endpoint.body {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try JSONEncoder().encode(AnyEncodable(body))
        }

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError.unknown }
        
        Logger.log("Response status: \(http.statusCode)", level: .debug)
        Logger.log("Response data: \(String(data: data, encoding: .utf8) ?? "nil")", level: .debug)
        
        switch http.statusCode {
        case 200...299:
            guard !data.isEmpty else {
                // Handle empty response for void operations
                if T.self == EmptyResponse.self {
                    return EmptyResponse() as! T
                }
                throw APIError.noData
            }
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                Logger.log("Decoding failed: \(error)", level: .error)
                throw APIError.decodingFailed
            }
        case 401:
            Logger.log("Unauthorized - check token validity", level: .error)
            throw APIError.unauthorized
        default:
            let message = String(data: data, encoding: .utf8) ?? "Server error"
            Logger.log("Server error \(http.statusCode): \(message)", level: .error)
            throw APIError.server(message)
        }
    }

    func requestNoContent(_ endpoint: Endpoint, token: String) async throws {
        let _: EmptyResponse = try await request(endpoint, token: token)
    }
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
        Logger.log("Auth token set: \(token ?? "nil")", level: .info)
        idToken = token
    }

    private func guardToken() throws -> String {
        guard let t = idToken, !t.isEmpty else {
            Logger.log("guardToken failed: unauthorized", level: .error)
            throw APIError.unauthorized
        }
        Logger.log("guardToken success", level: .debug)
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
        Logger.log("Loading dreams for date: \(selectedDate)", level: .info)
        dreams.removeAll()
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            let token = try guardToken()
            let key = dateKey(selectedDate)
            let ep = Endpoint(path: "api/dream/history/\(key)", method: .GET, body: nil)
            dreams = try await APIClient.shared.request(ep, token: token)
            Logger.log("Dreams loaded: \(dreams.count)", level: .info)
        } catch {
            errorMessage = mapError(error)
            Logger.log("Error loading dreams: \(errorMessage ?? "Unknown error")", level: .error)
        }
    }
    
    // MARK: Monthly entry status
    func loadMonthlyEntries(year: Int, month: Int) async {
        Logger.log("Loading monthly entries for: \(year)-\(month)", level: .info)
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        let monthStr = String(format: "%02d", month)
        do {
            let token = try guardToken()
            let ep = Endpoint(path: "api/dream/history/entryList/\(year)/\(monthStr)", method: .GET, body: nil)
            monthlyEntries = try await APIClient.shared.request(ep, token: token)
            Logger.log("Monthly entries loaded: \(monthlyEntries.count)", level: .info)
        } catch {
            errorMessage = mapError(error)
            Logger.log("Error loading monthly entries: \(errorMessage ?? "Unknown error")", level: .error)
        }
    }

    // MARK: Interpret (create) dream
    func submitDreamForInterpretation(input: String) async {
        Logger.log("Submitting dream for interpretation: \(input)", level: .info)
        errorMessage = nil
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            Logger.log("Input is empty, skipping submit", level: .warning)
            return
        }
        isLoading = true
        defer { isLoading = false }
        let key = dateKey(selectedDate)
        do {
            let token = try guardToken()
            let body = DreamRequest(dateKey: key, input: input)
            let ep = Endpoint(path: "api/dream/interpret", method: .POST, body: body)
            try await APIClient.shared.requestNoContent(ep, token: token)
            Logger.log("Dream submitted for interpretation", level: .info)
            await loadDreamsForSelectedDate()
        } catch {
            errorMessage = mapError(error)
            Logger.log("Error submitting dream: \(errorMessage ?? "Unknown error")", level: .error)
        }
    }

    // MARK: Fetch image
    func fetchDreamImage(dreamId: String) async {
        Logger.log("Fetching dream image for ID: \(dreamId)", level: .info)
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
            Logger.log("Dream image fetched", level: .info)
        } catch {
            errorMessage = mapError(error)
            Logger.log("Error fetching dream image: \(errorMessage ?? "Unknown error")", level: .error)
        }
    }

    // MARK: Notification subscriptions
    func loadSubscriptions() async {
        Logger.log("Loading notification subscriptions", level: .info)
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            let token = try guardToken()
            let ep = Endpoint(path: "api/notification/subscriptions", method: .GET, body: nil)
            subscriptions = try await APIClient.shared.request(ep, token: token)
            Logger.log("Subscriptions loaded: \(subscriptions != nil)", level: .info)
        } catch {
            errorMessage = mapError(error)
            Logger.log("Error loading subscriptions: \(errorMessage ?? "Unknown error")", level: .error)
        }
    }

    func updateSubscriptions(daily: Bool, interpretation: Bool) async {
        Logger.log("Updating subscriptions: daily=\(daily), interpretation=\(interpretation)", level: .info)
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            let token = try guardToken()
            let body = NotificationSubscription(daily: daily, interpretation: interpretation)
            let ep = Endpoint(path: "api/notification/subscriptions", method: .POST, body: body)
            try await APIClient.shared.requestNoContent(ep, token: token)
            subscriptions = body
            Logger.log("Subscriptions updated", level: .info)
        } catch {
            errorMessage = mapError(error)
            Logger.log("Error updating subscriptions: \(errorMessage ?? "Unknown error")", level: .error)
        }
    }

    // MARK: Update FCM token
    func updateFCMToken(_ fcm: String) async {
        Logger.log("Updating FCM token: \(fcm)", level: .info)
        guard !fcm.isEmpty else {
            Logger.log("FCM token is empty, skipping update", level: .warning)
            return
        }
        errorMessage = nil
        do {
            let token = try guardToken()
            let body = FCMRequest(fcmToken: fcm)
            let ep = Endpoint(path: "api/notification/fcm", method: .POST, body: body)
            try await APIClient.shared.requestNoContent(ep, token: token)
            Logger.log("FCM token updated", level: .info)
        } catch {
            errorMessage = mapError(error)
            Logger.log("Error updating FCM token: \(errorMessage ?? "Unknown error")", level: .error)
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
