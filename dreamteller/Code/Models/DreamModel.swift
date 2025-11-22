// Swift
// File: `dreamteller/Code/Models/DreamAPIModels.swift`

struct DreamEntry: Decodable {
    let dateKey: String   // YYYYMMDD
    let hasEntries: Bool
}

struct Dream: Decodable, Identifiable {
    let id: String
    let dateKey: String
    let input: String
    let title: String?        // optional per spec
    let interpretation: String?
}

struct DreamRequest: Encodable {
    let dateKey: String
    let input: String
}

struct NotificationSubscription: Codable {
    var daily: Bool
    var interpretation: Bool
}

struct FCMRequest: Encodable {
    let fcmToken: String
}
