//
//  DreamModel.swift
//  dreamteller
//
//  Created by suha.isik on 31.10.2025.
//
import Foundation
import FirebaseFirestore

struct Dream: Identifiable, Codable {
    var id: String
    var dateKey: String          // yyyyMMdd string (e.g. 20251118)
    var input: String            // Raw dream text
    var interpretation: String?  // Optional interpretation
    var title: String            // Display title
    var imageName: String        // Asset name for preview image

    init(id: String = UUID().uuidString,
         dateKey: String,
         input: String,
         interpretation: String? = nil,
         title: String,
         imageName: String) {
        self.id = id
        self.dateKey = dateKey
        self.input = input
        self.interpretation = interpretation
        self.title = title
        self.imageName = imageName
    }

    init?(doc: DocumentSnapshot) {
        guard let data = doc.data(),
              let dateKey = data["dateKey"] as? String,
              let input = data["input"] as? String,
              let title = data["title"] as? String,
              let imageName = data["imageName"] as? String else { return nil }
        self.id = doc.documentID
        self.dateKey = dateKey
        self.input = input
        self.interpretation = data["interpretation"] as? String
        self.title = title
        self.imageName = imageName
    }

    var asFirestore: [String: Any] {
        [
            "dateKey": dateKey,
            "input": input,
            "interpretation": interpretation as Any,
            "title": title,
            "imageName": imageName
        ]
    }
}
