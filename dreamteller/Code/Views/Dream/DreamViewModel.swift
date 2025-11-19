//
//  DreamViewModel.swift
//  dreamteller
//
//  Created by suha.isik on 31.10.2025.
//
import Foundation
import FirebaseFirestore
import SwiftUI

@MainActor
final class DreamViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var dreams: [Dream] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let db = Firestore.firestore()
    private var userId: String?

    func setUser(id: String?) {
        userId = id
        Task { await loadForSelectedDate() }
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = .init(identifier: .gregorian)
        f.locale = .init(identifier: "en_US_POSIX")
        f.dateFormat = "yyyyMMdd"
        return f
    }()

    private func key(for date: Date) -> String { Self.dateFormatter.string(from: date) }

    func changeDate(to date: Date) {
        selectedDate = date
        Task { await loadForSelectedDate() }
    }

    func loadForSelectedDate() async {
        guard let uid = userId else { return }
        isLoading = true
        defer { isLoading = false }
        let dateKey = key(for: selectedDate)
        do {
            let snap = try await db.collection("users").document(uid).collection(dateKey).order(by: "createdAt", descending: true).getDocuments()
            dreams = snap.documents.compactMap { doc -> Dream? in
                let data = doc.data()
                guard let input = data["input"] as? String,
                      let title = data["title"] as? String,
                      let imageName = data["imageName"] as? String,
                      let ts = data["createdAt"] as? Timestamp else { return nil }
                return Dream(id: doc.documentID,
                             dateKey: dateKey,
                             input: input,
                             interpretation: data["interpretation"] as? String,
                             title: title,
                             imageName: imageName)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addDream(title: String, input: String, interpretation: String?, imageName: String = "dream1") async {
        guard let uid = userId else { return }
        errorMessage = nil
        let dateKey = key(for: selectedDate)
        let dream = Dream(id: UUID().uuidString,
                          dateKey: dateKey,
                          input: input,
                          interpretation: interpretation,
                          title: title,
                          imageName: imageName)
        isLoading = true
        defer { isLoading = false }
        do {
            try await db.collection("users").document(uid).collection(dateKey).document(dream.id).setData([
                "dateKey": dream.dateKey,
                "input": dream.input,
                "interpretation": dream.interpretation as Any,
                "title": dream.title,
                "imageName": dream.imageName
            ])
            dreams.insert(dream, at: 0)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteDream(_ dream: Dream) async {
        guard let uid = userId else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await db.collection("users").document(uid).collection(dream.dateKey).document(dream.id).delete()
            dreams.removeAll { $0.id == dream.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
